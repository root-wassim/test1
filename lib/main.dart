import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/player_provider.dart';
import 'config/theme.dart';
import 'screens/biometric_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => PlayerProvider(),
      child: const SoundWaveApp(),
    ),
  );
}

class SoundWaveApp extends StatelessWidget {
  const SoundWaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoundWave',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const BiometricScreen(),
    );
  }
}
