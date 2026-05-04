import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../config/theme.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  Future<void> _send() async {
    setState(() { _loading = true; _error = null; });
    final err = await AuthService.resetPassword(_emailCtrl.text.trim());
    if (mounted) setState(() { _loading = false; _error = err; _sent = err == null; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Reset Password'), leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context))),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: _sent
            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.mark_email_read, color: AppTheme.secondary, size: 80),
                const SizedBox(height: 24),
                const Text('Email Sent!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('Check your inbox at ${_emailCtrl.text}', style: const TextStyle(color: Colors.white54), textAlign: TextAlign.center),
                const SizedBox(height: 32),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back to Login', style: TextStyle(color: AppTheme.primary))),
              ])
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text('Forgot Password?', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("Enter your email and we'll send a reset link", style: TextStyle(color: Colors.white38)),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailCtrl,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.email_outlined, color: Colors.white38, size: 20),
                      filled: true, fillColor: AppTheme.card,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primary)),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: AppTheme.accent)),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity, height: 54,
                    child: DecoratedBox(
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFF8B5CF6)]), borderRadius: BorderRadius.circular(14)),
                      child: ElevatedButton(
                        onPressed: _loading ? null : _send,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                        child: _loading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Text('Send Reset Link', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
