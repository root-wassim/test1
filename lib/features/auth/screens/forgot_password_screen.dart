import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:projet/core/constants/app_colors.dart';
import 'package:projet/core/constants/app_strings.dart';
import 'package:projet/core/constants/app_theme.dart';
import 'package:projet/core/utils/auth_error_mapper.dart';
import 'package:projet/core/utils/validators.dart';
import 'package:projet/features/auth/providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).resetPassword(_emailCtrl.text);
      if (mounted) setState(() => _sent = true);
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
                    child: const Icon(Icons.vpn_key_rounded,
                        color: AppColors.onPrimary, size: 28),
                  ),
                  const SizedBox(height: 24),

                  Text(AppStrings.resetAccess,
                      style: AppTheme.headlineMd, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(AppStrings.resetDescription,
                      style: AppTheme.bodyMd, textAlign: TextAlign.center),
                  const SizedBox(height: 32),

                  if (_sent) ...[
                    // ── Success state ──
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.mark_email_read_rounded,
                              color: AppColors.primary, size: 48),
                          const SizedBox(height: 16),
                          Text(AppStrings.resetLinkSent,
                              style: AppTheme.bodyMd
                                  .copyWith(color: AppColors.primary),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: () => context.pop(),
                        child: Text(AppStrings.backToLogin,
                            style: AppTheme.buttonText),
                      ),
                    ),
                  ] else ...[
                    // ── Email input ──
                    Text(AppStrings.emailAddress, style: AppTheme.labelMd),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                      style:
                          AppTheme.bodyMd.copyWith(color: AppColors.onSurface),
                      decoration: InputDecoration(
                        hintText: AppStrings.emailPlaceholder,
                        hintStyle: AppTheme.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant
                                .withValues(alpha: 0.4)),
                        prefixIcon: const Icon(Icons.email_outlined,
                            color: AppColors.onSurfaceVariant, size: 20),
                        filled: true,
                        fillColor: AppColors.surfaceHigh,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color:
                              AppColors.errorContainer.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(_error!,
                            style: AppTheme.bodySm
                                .copyWith(color: AppColors.error)),
                      ),

                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _loading ? null : _sendReset,
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.onPrimary),
                              )
                            : Text(AppStrings.sendResetLink,
                                style: AppTheme.buttonText),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => context.pop(),
                        child: Text(AppStrings.backToLogin,
                            style: AppTheme.bodyMd
                                .copyWith(color: AppColors.primary)),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // ── Encryption badge ──
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shield_outlined,
                            color: AppColors.primary, size: 14),
                        const SizedBox(width: 6),
                        Text(AppStrings.encryptionActive,
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
      ),
    );
  }
}
