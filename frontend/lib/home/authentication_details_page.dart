import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/l10n/app_localizations.dart';

import '../auth/auth_validators.dart';
import '../core/errors/api_error.dart';
import '../core/ui/app_shimmer.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/models/partner.dart';
import '../features/auth/presentation/partner_profile_provider.dart';
import '../theme/app_styles.dart';

class AuthenticationDetailsPage extends ConsumerStatefulWidget {
  const AuthenticationDetailsPage({super.key});

  @override
  ConsumerState<AuthenticationDetailsPage> createState() =>
      _AuthenticationDetailsPageState();
}

class _AuthenticationDetailsPageState
    extends ConsumerState<AuthenticationDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  String? _boundPartnerId;
  bool _saving = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _bind(Partner partner) {
    if (_boundPartnerId == partner.id) return;
    _email.text = partner.email ?? '';
    _boundPartnerId = partner.id;
  }

  String? _emailValidator(String? value, AppLocalizations l10n) {
    return validateOptionalEmail(value);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await ref.read(authRepositoryProvider).updateMe(
            email: _email.text.trim(),
          );
      ref.invalidate(partnerProfileProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.changesSaved)));
    } catch (e) {
      if (!mounted) return;
      final message = e is ApiError ? e.error : e.toString();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final asyncPartner = ref.watch(partnerProfileProvider);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authenticationDetails)),
      body: asyncPartner.when(
        skipLoadingOnReload: true,
        loading: () => const ProfileSkeleton(),
        error: (error, _) {
          final message =
              error is ApiError ? error.error : 'Something went wrong';
          return Center(child: Text(message));
        },
        data: (partner) {
          _bind(partner);
          return Form(
            key: _formKey,
            child: ListView(
              padding: AppStyles.detailPadding,
              children: [
                InputDecorator(
                  decoration: InputDecoration(labelText: l10n.mobileNumber),
                  child: Text(
                    '+91 ${partner.phoneNumber}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  l10n.phoneCannotChange,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: muted,
                      ),
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'Email (optional)',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) => _emailValidator(v, l10n),
                ),
                SizedBox(height: 24.h),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? SizedBox(
                          width: 22.r,
                          height: 22.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(l10n.saveChanges),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
