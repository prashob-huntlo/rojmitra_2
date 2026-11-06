import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/errors/api_error.dart';
import '../core/ui/app_logo.dart';
import '../features/auth/presentation/auth_notifier.dart';
import '../l10n/language_picker.dart';
import 'auth_fields.dart';
import 'auth_validators.dart';

enum _LoginMethod { password, otp }

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  _LoginMethod _method = _LoginMethod.password;
  bool _otpSent = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _showError(Object error) {
    final message = error is ApiError ? error.error : error.toString();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _setMethod(_LoginMethod method) {
    if (_method == method) return;
    setState(() {
      _method = method;
      _otpSent = false;
      _otpController.clear();
    });
  }

  Future<void> _signInWithPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    try {
      await ref.read(authNotifierProvider.notifier).loginWithPassword(
            phoneNumber: phone,
            password: password,
          );
      if (!mounted) return;
      _navigateForAuthState(ref.read(authNotifierProvider));
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    try {
      await ref.read(authNotifierProvider.notifier).sendOtp(phone, 'login');
      if (!mounted) return;
      setState(() => _otpSent = true);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.newOtpReady)));
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    final otp = _otpController.text.trim();
    try {
      await ref.read(authNotifierProvider.notifier).submitOtp(
            phoneNumber: phone,
            otp: otp,
            purpose: 'login',
          );
      if (!mounted) return;
      _navigateForAuthState(ref.read(authNotifierProvider));
    } catch (e) {
      _showError(e);
    }
  }

  void _navigateForAuthState(AuthState state) {
    switch (state) {
      case AwaitingApproval():
        context.go('/pending');
      case Rejected():
        context.go('/rejected');
      case Authenticated():
        context.go('/home');
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is Loading;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: l10n.language,
            onPressed: isLoading ? null : () => showLanguagePicker(context, ref),
            icon: const Icon(Icons.language),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          child: Align(
            alignment: Alignment.center,
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.newHere,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: isLoading ? null : () => context.push('/signup'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      maximumSize: const Size.fromHeight(52),
                    ),
                    child: Text(l10n.signUp),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: AuthPageFrame(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: AppLogo.hero(width: 180)),
              const SizedBox(height: 28),
              Text(l10n.welcomeBack, style: textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                l10n.signInWithMobile,
                style: textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              PhoneField(controller: _phoneController),
              const SizedBox(height: 16),
              if (_method == _LoginMethod.password) ...[
                PasswordField(
                  controller: _passwordController,
                  label: l10n.password,
                  fieldKey: const Key('password-field'),
                  obscureText: _obscurePassword,
                  autofillHints: const [AutofillHints.password],
                  onToggleVisibility: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  validator: (value) => validatePassword(value, l10n),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            final phone = _phoneController.text.trim();
                            final path = phone.isEmpty
                                ? '/forgot-password'
                                : '/forgot-password?phone=$phone';
                            context.push(path);
                          },
                    child: Text(l10n.forgotPassword),
                  ),
                ),
                FilledButton(
                  onPressed: isLoading ? null : _signInWithPassword,
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.signIn),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => _setMethod(_LoginMethod.otp),
                  child: Text(l10n.loginWithOtpInstead),
                ),
              ] else ...[
                if (!_otpSent)
                  FilledButton(
                    onPressed: isLoading ? null : _sendOtp,
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.sendOtp),
                  )
                else ...[
                  Text(
                    l10n.enterOtpForPhone(_phoneController.text.trim()),
                    style: textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('otp-field'),
                    controller: _otpController,
                    enabled: !isLoading,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: InputDecoration(
                      labelText: l10n.otp,
                      prefixIcon: const Icon(Icons.pin_outlined),
                    ),
                    validator: (value) => validateOtp(value, l10n),
                    onFieldSubmitted: (_) {
                      if (!isLoading) _verifyOtp();
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isLoading ? null : _sendOtp,
                      child: Text(l10n.resendOtp),
                    ),
                  ),
                  FilledButton(
                    onPressed: isLoading ? null : _verifyOtp,
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.verifyOtp),
                  ),
                ],
                const SizedBox(height: 8),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => _setMethod(_LoginMethod.password),
                  child: Text(l10n.loginWithPasswordInstead),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
