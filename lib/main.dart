import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:projet/core/constants/app_colors.dart';
import 'package:projet/core/services/offline_sync_queue.dart';
import 'package:projet/core/services/quran_audio_handler.dart';
import 'package:projet/features/player/providers/player_provider.dart';
import 'package:projet/firebase_options.dart';

import 'package:projet/features/auth/screens/forgot_password_screen.dart';
import 'package:projet/features/auth/screens/login_screen.dart';
import 'package:projet/features/auth/screens/register_screen.dart';
import 'package:projet/features/biometric/screens/biometric_gate_screen.dart';
import 'package:projet/features/explore/models/surah_model.dart';
import 'package:projet/features/explore/screens/azkar_screen.dart';
import 'package:projet/features/explore/screens/duas_screen.dart';
import 'package:projet/features/explore/screens/laylat_alqadr_screen.dart';
import 'package:projet/features/explore/screens/mushaf_screen.dart';
import 'package:projet/features/explore/screens/surah_detail_screen.dart';
import 'package:projet/features/explore/screens/surah_index_screen.dart';
import 'package:projet/features/downloads/screens/downloads_screen.dart';
import 'package:projet/features/favorites/screens/favorites_screen.dart';
import 'package:projet/features/home/screens/home_screen.dart';
import 'package:projet/features/player/screens/player_screen.dart';
import 'package:projet/features/profile/screens/profile_screen.dart';
import 'package:projet/shared/widgets/app_bottom_nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ── Initialize Audio Service (media notification support) ──
  final audioHandler = await AudioService.init<QuranAudioHandler>(
    builder: () => QuranAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.quranplay.audio',
      androidNotificationChannelName: 'QuranPlay',
      androidNotificationOngoing: false,
      androidStopForegroundOnPause: true,
      notificationColor: Color(0xFF4EDEA3), // AppColors.primary
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidShowNotificationBadge: true,
    ),
  );

  // ✅ Flush offline queue in background — doesn't block the UI thread
  Future.microtask(() => OfflineSyncQueue().flush());

  runApp(
    ProviderScope(
      overrides: [
        // Inject the singleton audio handler into Riverpod
        audioHandlerProvider.overrideWithValue(audioHandler),
      ],
      child: const QuranPlayApp(),
    ),
  );
}

/// Session flag: true = biometric already passed this session (resets on app kill).
final biometricPassedProvider = NotifierProvider<_BiometricPassedNotifier, bool>(
  _BiometricPassedNotifier.new,
);

class _BiometricPassedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void pass() => state = true;
}

/// Listenable wrapper around Firebase auth state for GoRouter refreshListenable.
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable() {
    _sub = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<User?> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}


final _routerProvider = Provider<GoRouter>((ref) {
  // ✅ Router is created ONCE. Never rebuilt on auth change.
  // refreshListenable re-runs redirect without recreating the router.
  final listenable = _AuthStateListenable();

  final router = GoRouter(
    initialLocation: '/biometric',
    refreshListenable: listenable,
    routes: [
      GoRoute(path: '/biometric', builder: (context, state) => const BiometricGateScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      ShellRoute(
        builder: (context, state, child) => AppBottomNav(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/player', builder: (context, state) => const PlayerScreen()),
          GoRoute(path: '/downloads', builder: (context, state) => const DownloadsScreen()),
          GoRoute(path: '/favorites', builder: (context, state) => const FavoritesScreen()),
          GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
          // ── Explore routes ──
          GoRoute(path: '/explore/surahs', builder: (context, state) => const SurahIndexScreen()),
          GoRoute(path: '/explore/surah-index', builder: (context, state) => const SurahIndexScreen()),
          GoRoute(
            path: '/explore/surah/:id',
            builder: (context, state) {
              final surah = state.extra as SurahModel?;
              if (surah != null) return SurahDetailScreen(surah: surah);
              return SurahDetailScreen(
                surah: SurahModel(
                  id: int.tryParse(state.pathParameters['id'] ?? '1') ?? 1,
                  number: int.tryParse(state.pathParameters['id'] ?? '1') ?? 1,
                  nameAr: '',
                  nameEn: '',
                  type: 'Meccan',
                  ayatCount: 0,
                ),
              );
            },
          ),
          GoRoute(path: '/explore/azkar', builder: (context, state) => const AzkarScreen()),
          GoRoute(path: '/explore/duas', builder: (context, state) => const DuasScreen()),
          GoRoute(path: '/explore/mushaf', builder: (context, state) => const MushafScreen()),
          GoRoute(path: '/explore/laylat-alqadr', builder: (context, state) => const LaylatAlQadrScreen()),
        ],
      ),
    ],
    redirect: (_, state) {
      final biometricPassed = ref.read(biometricPassedProvider);

      // ✅ Read Firebase auth state DIRECTLY — always up-to-date.
      // The Riverpod StreamProvider may lag behind the actual Firebase event
      // because it's a separate subscription that processes asynchronously.
      final loggedIn = FirebaseAuth.instance.currentUser != null;

      final onBiometric = state.fullPath == '/biometric';
      final onAuthPage = state.fullPath == '/login' ||
          state.fullPath == '/register' ||
          state.fullPath == '/forgot-password';
      final onProtectedPage = !onBiometric && !onAuthPage;

      // 🏠 Step 1 (PRIORITY): Already logged in → always go home from auth/biometric pages.
      // This MUST come first so a newly-authenticated user is never sent back to /biometric.
      if (loggedIn && (onAuthPage || onBiometric)) return '/home';

      // 🚪 Step 2: Not logged in + on a protected page → go to login
      if (!loggedIn && onProtectedPage) return '/login';

      // 🔑 Step 3: Not logged in, on auth page, but biometric not yet passed → biometric gate
      // Only applies to unauthenticated users who skipped the biometric (e.g. deep link).
      if (!loggedIn && !biometricPassed && onAuthPage) return '/biometric';

      return null;
    },
  );

  ref.onDispose(() {
    listenable.dispose();
    router.dispose();
  });

  return router;
});

class QuranPlayApp extends ConsumerWidget {
  const QuranPlayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'QuranPlay',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          surface: AppColors.surface,
          primary: AppColors.primary,
          tertiary: AppColors.tertiary,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.surfaceContainer,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surfaceContainer,
          indicatorColor: AppColors.primary.withValues(alpha: 0.15),
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: AppColors.surfaceContainerHighest,
          contentTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.onSurface,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        fontFamily: 'Inter',
      ),
      routerConfig: router,
    );
  }
}
