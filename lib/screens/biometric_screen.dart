import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/biometric_service.dart';
import '../config/theme.dart';
import 'auth_gate.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});
  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> {
  String _status = 'Place your finger on the sensor';
  bool _failed = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _authenticate() async {
    setState(() { _checking = true; _failed = false; _status = 'Verifying...'; });

    final available = await BiometricService.isAvailable();
    if (!available) {
      setState(() { _status = 'Biometrics not available on this device'; _failed = true; _checking = false; });
      return;
    }

    final hasFingerprint = await BiometricService.hasBiometrics();
    if (!hasFingerprint) {
      setState(() { _status = 'No fingerprint enrolled. Please set one up in Settings.'; _failed = true; _checking = false; });
      return;
    }

    final success = await BiometricService.authenticate(
      reason: 'Authenticate to access SoundWave',
    );

    if (success) {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthGate()));
      }
    } else {
      setState(() { _status = 'Authentication failed. Try again.'; _failed = true; _checking = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 30, spreadRadius: 5)],
                ),
                child: const Icon(Icons.music_note, color: Colors.white, size: 50),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

              const SizedBox(height: 24),
              const Text('SoundWave', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1))
                  .animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 8),
              const Text('Secure Music Player', style: TextStyle(color: Colors.white38, fontSize: 14))
                  .animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 60),

              // Fingerprint icon
              GestureDetector(
                onTap: _checking ? null : _authenticate,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _failed ? AppTheme.accent.withOpacity(0.15) : AppTheme.primary.withOpacity(0.15),
                    border: Border.all(
                      color: _failed ? AppTheme.accent : AppTheme.primary,
                      width: 2,
                    ),
                  ),
                  child: _checking
                      ? const SizedBox(width: 48, height: 48, child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2))
                      : Icon(Icons.fingerprint, size: 64, color: _failed ? AppTheme.accent : AppTheme.primary),
                ),
              ).animate().scale(delay: 500.ms, duration: 500.ms, curve: Curves.elasticOut),

              const SizedBox(height: 24),
              Text(
                _status,
                style: TextStyle(color: _failed ? AppTheme.accent : Colors.white54, fontSize: 14),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 600.ms),

              if (_failed) ...[
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: _authenticate,
                  icon: const Icon(Icons.refresh, color: AppTheme.primary),
                  label: const Text('Try Again', style: TextStyle(color: AppTheme.primary)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
