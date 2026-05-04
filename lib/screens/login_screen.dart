import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';
import '../config/theme.dart';
import 'register_screen.dart';
import 'reset_password_screen.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    final err = await AuthService.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (mounted) {
      setState(() { _loading = false; _error = err; });
      if (err == null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
                    boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 20)],
                  ),
                  child: const Icon(Icons.music_note, color: Colors.white, size: 40),
                ),
              ).animate().scale(duration: 500.ms),
              const SizedBox(height: 32),
              const Text('Welcome back', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))
                  .animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
              const SizedBox(height: 6),
              const Text('Sign in to continue', style: TextStyle(color: Colors.white38, fontSize: 14))
                  .animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 40),

              _buildField('Email', _emailCtrl, Icons.email_outlined, false),
              const SizedBox(height: 16),
              _buildField('Password', _passCtrl, Icons.lock_outlined, _obscure,
                  suffix: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white38, size: 20),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    const Icon(Icons.error_outline, color: AppTheme.accent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!, style: const TextStyle(color: AppTheme.accent, fontSize: 13))),
                  ]),
                ),
              ],

              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResetPasswordScreen())),
                  child: const Text('Forgot password?', style: TextStyle(color: AppTheme.primary)),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFF8B5CF6)]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(color: Colors.white38)),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    child: const Text('Sign Up', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, bool obscure, {Widget? suffix}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppTheme.card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primary)),
      ),
    );
  }
}
