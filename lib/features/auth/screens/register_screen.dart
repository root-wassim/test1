import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:projet/core/constants/app_colors.dart';
import 'package:projet/core/constants/app_strings.dart';
import 'package:projet/core/constants/app_theme.dart';
import 'package:projet/core/utils/auth_error_mapper.dart';
import 'package:projet/core/utils/validators.dart';
import 'package:projet/features/auth/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  DateTime? _dateOfBirth;
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1920),
      lastDate: now,
      helpText: AppStrings.dateOfBirth,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surfaceContainer,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate age
    final ageError = Validators.minimumAge13(_dateOfBirth);
    if (ageError != null) {
      setState(() => _error = ageError);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref.read(authServiceProvider).register(
            email: _emailCtrl.text,
            password: _passCtrl.text,
            firstName: _firstNameCtrl.text,
            lastName: _lastNameCtrl.text,
            dateOfBirth: _dateOfBirth!,
          );
      // GoRouter redirect will handle navigation to /home
    } catch (e) {
      if (mounted) setState(() => _error = mapAuthError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return AppStrings.dateOfBirthHint;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
                    child: const Icon(Icons.person_add_alt_1_rounded,
                        color: AppColors.onPrimary, size: 28),
                  ),
                  const SizedBox(height: 24),

                  Text(AppStrings.createIdentity,
                      style: AppTheme.headlineMd, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(AppStrings.completeProfile,
                      style: AppTheme.bodyMd, textAlign: TextAlign.center),
                  const SizedBox(height: 28),

                  // ── First Name ──
                  Text(AppStrings.firstName, style: AppTheme.labelMd),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _firstNameCtrl,
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                        Validators.requiredField(v, AppStrings.firstName),
                    style: AppTheme.bodyMd.copyWith(color: AppColors.onSurface),
                    decoration: _inputDecoration(
                        hint: 'Jean', icon: Icons.person_outline_rounded),
                  ),
                  const SizedBox(height: 16),

                  // ── Last Name ──
                  Text(AppStrings.lastName, style: AppTheme.labelMd),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _lastNameCtrl,
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                        Validators.requiredField(v, AppStrings.lastName),
                    style: AppTheme.bodyMd.copyWith(color: AppColors.onSurface),
                    decoration: _inputDecoration(
                        hint: 'Dupont', icon: Icons.badge_outlined),
                  ),
                  const SizedBox(height: 16),

                  // ── Date of Birth ──
                  Text(AppStrings.dateOfBirth, style: AppTheme.labelMd),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _pickDateOfBirth,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(14),
                        border: _dateOfBirth == null
                            ? null
                            : Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              color: AppColors.onSurfaceVariant, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            _formatDate(_dateOfBirth),
                            style: AppTheme.bodyMd.copyWith(
                              color: _dateOfBirth != null
                                  ? AppColors.onSurface
                                  : AppColors.onSurfaceVariant
                                      .withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Email ──
                  Text(AppStrings.emailAddress, style: AppTheme.labelMd),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    style: AppTheme.bodyMd.copyWith(color: AppColors.onSurface),
                    decoration: _inputDecoration(
                        hint: AppStrings.emailPlaceholder,
                        icon: Icons.email_outlined),
                  ),
                  const SizedBox(height: 16),

                  // ── Password ──
                  Text(AppStrings.masterKey, style: AppTheme.labelMd),
                  const SizedBox(height: 6),
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
                  const SizedBox(height: 12),

                  // ── Security Note ──
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_rounded,
                            color: AppColors.primary, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(AppStrings.securityNote,
                              style: AppTheme.bodySm
                                  .copyWith(color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

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
                          style:
                              AppTheme.bodySm.copyWith(color: AppColors.error)),
                    ),

                  // ── Register Button ──
                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: _loading ? null : _register,
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.onPrimary),
                            )
                          : Text(AppStrings.createAccount,
                              style: AppTheme.buttonText),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Login Link ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppStrings.alreadyHaveAccount,
                          style: AppTheme.bodyMd),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text(AppStrings.signIn,
                            style: AppTheme.bodyMd.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
