import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/errors/api_error.dart';
import '../features/auth/data/auth_repository.dart';
import 'auth_fields.dart';
import 'auth_validators.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key, this.initialPhone = ''});

  final String initialPhone;

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController;
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _otpSent = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showError(Object e) {
    final message = e is ApiError ? e.error : e.toString();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).requestOtp(
            phoneNumber: _phoneController.text.trim(),
            purpose: 'reset',
          );
      if (!mounted) return;
      setState(() => _otpSent = true);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.newOtpReady)),
        );
    } catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).resetPassword(
            phoneNumber: _phoneController.text.trim(),
            otp: _otpController.text.trim(),
            newPassword: _passwordController.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.passwordUpdated)));
      context.pop();
    } catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.resetPassword)),
      body: AuthPageFrame(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.forgotPasswordTitle, style: textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                _otpSent
                    ? l10n.forgotPasswordOtpBody(_phoneController.text.trim())
                    : l10n.forgotPasswordBody,
                style: textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              PhoneField(
                controller: _phoneController,
                // Lock phone after OTP is sent so reset matches the OTP purpose.
                enabled: !_otpSent && !_busy,
              ),
              const SizedBox(height: 16),
              if (_otpSent) ...[
                TextFormField(
                  key: const Key('reset-otp-field'),
                  controller: _otpController,
                  enabled: !_busy,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.otp,
                    prefixIcon: const Icon(Icons.pin_outlined),
                  ),
                  validator: (value) => validateOtp(value, l10n),
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _passwordController,
                  label: l10n.newPassword,
                  fieldKey: const Key('new-password-field'),
                  obscureText: _obscurePassword,
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.next,
                  onToggleVisibility: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  validator: (value) => validateNewPassword(value, l10n),
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _confirmController,
                  label: l10n.confirmPassword,
                  fieldKey: const Key('confirm-password-field'),
                  obscureText: _obscureConfirm,
                  autofillHints: const [AutofillHints.newPassword],
                  onToggleVisibility: () {
                    setState(() => _obscureConfirm = !_obscureConfirm);
                  },
                  validator: (value) => validateConfirmPassword(
                    value,
                    _passwordController.text,
                    l10n,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _busy ? null : _sendOtp,
                  child: Text(l10n.resendOtp),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _busy ? null : _updatePassword,
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.updatePassword),
                ),
              ] else
                FilledButton(
                  onPressed: _busy ? null : _sendOtp,
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.sendOtp),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
