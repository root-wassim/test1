import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:projet/core/constants/app_colors.dart';
import 'package:projet/core/constants/app_strings.dart';
import 'package:projet/core/constants/app_theme.dart';
import 'package:projet/core/services/biometric_service.dart';
import 'package:projet/main.dart';

class BiometricGateScreen extends ConsumerStatefulWidget {
  const BiometricGateScreen({super.key});

  @override
  ConsumerState<BiometricGateScreen> createState() =>
      _BiometricGateScreenState();
}

class _BiometricGateScreenState extends ConsumerState<BiometricGateScreen>
    with SingleTickerProviderStateMixin {
  final _biometricService = BiometricService(LocalAuthentication());
  bool _authenticating = false;
  bool _success = false;
  String? _error;
  bool _noFingerprintEnrolled = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 0.8, end: 1.0).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (_authenticating) return;
    setState(() {
      _authenticating = true;
      _error = null;
      _noFingerprintEnrolled = false;
    });

    final result = await _biometricService.authenticate();

    if (!mounted) return;

    if (result.ok) {
      // Play success sound
      await SystemSound.play(SystemSoundType.click);

      setState(() {
        _success = true;
        _authenticating = false;
      });

      // Mark biometric as passed
      ref.read(biometricPassedProvider.notifier).pass();

      // Brief delay for success animation, then navigate
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) context.go('/login');
    } else {
      // Check if the error is about no fingerprint enrolled
      final msg = result.message ?? '';
      final isNotEnrolled = msg.contains('paramètres') ||
          msg.contains('configurée') ||
          msg.contains('enregistrée');

      setState(() {
        _authenticating = false;
        _error = result.message;
        _noFingerprintEnrolled = isNotEnrolled;
      });
    }
  }

  void _openSettings() {
    AppSettings.openAppSettings(type: AppSettingsType.security);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Fingerprint Icon ──
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _success ? 1.2 : _pulseAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: _success
                              ? AppTheme.vaultGlow
                              : null,
                          color: _success
                              ? null
                              : AppColors.surfaceContainer,
                          border: Border.all(
                            color: _success
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.3),
                            width: 2,
                          ),
                          boxShadow: _success
                              ? AppTheme.vaultGlowShadow
                              : null,
                        ),
                        child: Icon(
                          _success
                              ? Icons.check_rounded
                              : Icons.fingerprint_rounded,
                          size: 56,
                          color: _success
                              ? AppColors.onPrimary
                              : AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // ── Status ──
                if (_success) ...[
                  Text(AppStrings.success,
                      style: AppTheme.headlineMd
                          .copyWith(color: AppColors.primary)),
                  const SizedBox(height: 8),
                  Text(AppStrings.secureConnectionValidated,
                      style: AppTheme.bodyMd, textAlign: TextAlign.center),
                ] else if (_authenticating) ...[
                  Text(AppStrings.authenticating,
                      style: AppTheme.headlineSm),
                  const SizedBox(height: 8),
                  Text(AppStrings.fingerprintDetected,
                      style: AppTheme.bodyMd, textAlign: TextAlign.center),
                ] else ...[
                  Text(AppStrings.secureAccessRequired,
                      style: AppTheme.headlineMd,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Text(AppStrings.scanFingerprint,
                      style: AppTheme.bodyMd, textAlign: TextAlign.center),
                ],

                const SizedBox(height: 32),

                // ── Error ──
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(_error!,
                        style:
                            AppTheme.bodySm.copyWith(color: AppColors.error),
                        textAlign: TextAlign.center),
                  ),
                ],

                // ── Settings Button (if no fingerprint enrolled) ──
                if (_noFingerprintEnrolled) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _openSettings,
                      icon: const Icon(Icons.settings, size: 20),
                      label: Text(AppStrings.systemSettings),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.tertiary,
                        side: BorderSide(
                            color: AppColors.tertiary.withValues(alpha: 0.4)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Authenticate Button ──
                if (!_success)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: _authenticating ? null : _authenticate,
                      icon: Icon(
                          _authenticating
                              ? Icons.hourglass_top
                              : Icons.fingerprint_rounded,
                          size: 20),
                      label: Text(
                        _authenticating
                            ? AppStrings.authenticating
                            : AppStrings.authenticate,
                        style: AppTheme.buttonText,
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // ── System Status ──
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(AppStrings.systemReady,
                          style: AppTheme.labelSm
                              .copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
