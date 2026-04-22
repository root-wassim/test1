import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:projet/core/constants/app_colors.dart';
import 'package:projet/core/constants/app_strings.dart';
import 'package:projet/core/constants/app_theme.dart';
import 'package:projet/core/utils/auth_error_mapper.dart';
import 'package:projet/core/utils/validators.dart';
import 'package:projet/features/auth/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).login(
            _emailCtrl.text,
            _passCtrl.text,
          );
      // GoRouter redirect will handle navigation to /home
    } catch (e) {
      if (mounted) setState(() => _error = mapAuthError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Logo ──
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.vaultGlow,
                      boxShadow: AppTheme.vaultGlowShadow,
                    ),
                    child: const Icon(Icons.lock_outline_rounded,
                        color: AppColors.onPrimary, size: 28),
                  ),
                  const SizedBox(height: 28),

                  // ── Title ──
                  Text(AppStrings.welcomeBack,
                      style: AppTheme.headlineMd, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(AppStrings.enterCredentials,
                      style: AppTheme.bodyMd, textAlign: TextAlign.center),
                  const SizedBox(height: 32),

                  // ── Email ──
                  Text(AppStrings.emailAddress, style: AppTheme.labelMd),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    style: AppTheme.bodyMd.copyWith(color: AppColors.onSurface),
                    decoration: _inputDecoration(
                      hint: AppStrings.emailPlaceholder,
                      icon: Icons.email_outlined,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Password ──
                  Text(AppStrings.password, style: AppTheme.labelMd),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    validator: Validators.password,
                    style: AppTheme.bodyMd.copyWith(color: AppColors.onSurface),
                    decoration: _inputDecoration(
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      suffix: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.onSurfaceVariant,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Forgot Password ──
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      child: Text(AppStrings.forgotPassword,
                          style: AppTheme.bodySm
                              .copyWith(color: AppColors.primary)),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Error ──
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(_error!,
                          style: AppTheme.bodySm
                              .copyWith(color: AppColors.error)),
                    ),

                  // ── Login Button ──
                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onPrimary,
                              ),
                            )
                          : Text(AppStrings.login,
                              style: AppTheme.buttonText),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Register Link ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppStrings.noAccount, style: AppTheme.bodyMd),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        child: Text(AppStrings.createAccount,
                            style: AppTheme.bodyMd.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTheme.bodyMd
          .copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
      prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.surfaceHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
