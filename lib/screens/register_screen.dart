import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../config/theme.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  DateTime? _birthDate;
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (c, child) => Theme(
        data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: AppTheme.primary)),
        child: child!,
      ),
    );
    if (d != null) setState(() => _birthDate = d);
  }

  Future<void> _register() async {
    if (_passCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    if (_birthDate == null) {
      setState(() => _error = 'Please select your birth date');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final err = await AuthService.register(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      firstName: _firstCtrl.text.trim(),
      lastName: _lastCtrl.text.trim(),
      birthDate: _birthDate!,
    );
    if (mounted) {
      if (err == null) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainScreen()), (_) => false);
      } else {
        setState(() { _loading = false; _error = err; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Create Account'), leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(children: [
              Expanded(child: _field('First Name', _firstCtrl, Icons.person_outline)),
              const SizedBox(width: 12),
              Expanded(child: _field('Last Name', _lastCtrl, Icons.person_outline)),
            ]),
            const SizedBox(height: 14),
            _field('Email', _emailCtrl, Icons.email_outlined),
            const SizedBox(height: 14),
            // Birth date picker
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  const Icon(Icons.cake_outlined, color: Colors.white38, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    _birthDate != null ? DateFormat('MMM dd, yyyy').format(_birthDate!) : 'Date of Birth',
                    style: TextStyle(color: _birthDate != null ? Colors.white : Colors.white38),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 14),
            _field('Password', _passCtrl, Icons.lock_outlined, obscure: _obscure),
            const SizedBox(height: 14),
            _field('Confirm Password', _confirmCtrl, Icons.lock_outlined, obscure: _obscure),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                child: Text(_obscure ? 'Show passwords' : 'Hide passwords', style: const TextStyle(color: AppTheme.primary, fontSize: 12)),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 8),
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

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFF8B5CF6)]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))],
                ),
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Create Account', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: AppTheme.card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primary)),
      ),
    );
  }
}
