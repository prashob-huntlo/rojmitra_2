import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/errors/api_error.dart';
import '../core/ui/app_logo.dart';
import '../features/auth/presentation/auth_notifier.dart';
import '../home/profile_helpers.dart';
import '../pages/auth/registration_state.dart';
import '../pages/auth/signup_channel.dart';
import '../workers/address_fields.dart';
import 'auth_fields.dart';
import 'auth_validators.dart';

class _PartnerRole {
  const _PartnerRole(this.id, this.label, this.profileFields);

  final String id;
  final String label;
  final List<PartnerProfileField> profileFields;
}

List<_PartnerRole> get _roles => [
      _PartnerRole('csc', 'CSC Centres', partnerProfileFieldsForRole('csc')),
      _PartnerRole(
        'cmc',
        'Community Mobilizers',
        partnerProfileFieldsForRole('cmc'),
      ),
      _PartnerRole(
        'anganwadi',
        'Anganwadi Centres',
        partnerProfileFieldsForRole('anganwadi'),
      ),
      _PartnerRole(
        'gov_ngo',
        'Govt / NGO Partners',
        partnerProfileFieldsForRole('gov_ngo'),
      ),
    ];

_PartnerRole _roleForChannel(SignupChannel channel) {
  final id = channel.apiRole;
  return _roles.firstWhere((role) => role.id == id, orElse: () => _roles.first);
}

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();

  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _otp = TextEditingController();
  final _permanentAddress = AddressControllers();
  final _presentAddress = AddressControllers();

  final Map<String, TextEditingController> _profileControllers = {};

  late _PartnerRole _role;
  bool _sameAsPermanent = true;
  bool _awaitingOtp = false;
  bool _submitting = false;
  bool _missingChannel = false;

  @override
  void initState() {
    super.initState();
    final channel = ref.read(registrationProvider).channel;
    if (channel == null) {
      _missingChannel = true;
      _role = _roles.first;
    } else {
      _role = _roleForChannel(channel);
    }
    _rebuildProfileControllers(_role);
    _permanentAddress.addListener(_syncPresentFromPermanent);
    if (_missingChannel) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/signup');
        }
      });
    }
  }

  void _syncPresentFromPermanent() {
    if (!_sameAsPermanent) return;
    _presentAddress.copyFrom(_permanentAddress);
  }

  @override
  void dispose() {
    _permanentAddress.removeListener(_syncPresentFromPermanent);
    _fullName.dispose();
    _phone.dispose();
    _email.dispose();
    _otp.dispose();
    _permanentAddress.dispose();
    _presentAddress.dispose();
    for (final c in _profileControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _rebuildProfileControllers(_PartnerRole role) {
    for (final c in _profileControllers.values) {
      c.dispose();
    }
    _profileControllers
      ..clear()
      ..addEntries([
        for (final field in role.profileFields)
          MapEntry(field.key, TextEditingController()),
      ]);
  }

  String? _required(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) return l10n.requiredField;
    return null;
  }

  String? _profileValidator(PartnerProfileField field, String? value, AppLocalizations l10n) {
    if (field.isPhone) {
      return validateOtherMobile(value, _phone.text, l10n);
    }
    if (!field.required) {
      return null;
    }
    return _required(value, l10n);
  }

  void _showError(Object error) {
    final message = error is ApiError ? error.error : error.toString();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submitSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_sameAsPermanent) {
      _presentAddress.copyFrom(_permanentAddress);
    }

    final email = _email.text.trim();
    final body = <String, dynamic>{
      'role': _role.id,
      'fullName': _fullName.text.trim(),
      'phoneNumber': _phone.text.trim(),
      if (email.isNotEmpty) 'email': email,
      'permanentAddress': _permanentAddress.toAddress().toApiJson(),
      'presentSameAsPermanent': _sameAsPermanent,
      if (!_sameAsPermanent)
        'presentAddress': _presentAddress.toAddress().toApiJson(),
      'profile': {
        for (final field in _role.profileFields)
          field.key: _profileControllers[field.key]!.text.trim(),
      },
    };

    setState(() => _submitting = true);
    try {
      await ref.read(authNotifierProvider.notifier).signup(body);
      if (!mounted) return;
      setState(() {
        _awaitingOtp = true;
        _otp.clear();
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.newOtpReady)),
        );
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (!_otpFormKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      await ref.read(authNotifierProvider.notifier).submitOtp(
            phoneNumber: _phone.text.trim(),
            otp: _otp.text.trim(),
            purpose: 'signup',
          );
      if (!mounted) return;
      final state = ref.read(authNotifierProvider);
      switch (state) {
        case AwaitingApproval():
          context.go('/pending');
        case Rejected():
          context.go('/rejected');
        case Authenticated():
          context.go('/home');
        default:
          context.go('/pending');
      }
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _submitting = true);
    try {
      await ref.read(authNotifierProvider.notifier).sendOtp(
            _phone.text.trim(),
            'signup',
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.newOtpReady)),
        );
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_missingChannel) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final busy = _submitting || ref.watch(authNotifierProvider) is Loading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: busy
              ? null
              : () {
                  if (_awaitingOtp) {
                    setState(() => _awaitingOtp = false);
                    return;
                  }
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/signup');
                  }
                },
        ),
      ),
      body: AuthPageFrame(
        child: _awaitingOtp
            ? _buildOtpStep(l10n, textTheme, busy)
            : _buildForm(l10n, textTheme, busy),
      ),
    );
  }

  Widget _buildForm(AppLocalizations l10n, TextTheme textTheme, bool busy) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: AppLogo.hero(width: 180)),
          const SizedBox(height: 28),
          Text(l10n.createAccount, style: textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            l10n.signupBody,
            style: textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Register as',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            child: Text(_role.label, style: textTheme.titleMedium),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _fullName,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.fullName,
              prefixIcon: const Icon(Icons.person_outline),
            ),
            validator: (v) => _required(v, l10n),
          ),
          const SizedBox(height: 12),
          PhoneField(controller: _phone),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Email (optional)',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: validateOptionalEmail,
          ),
          const SizedBox(height: 16),
          Text(l10n.permanentAddress, style: textTheme.titleSmall),
          const SizedBox(height: 8),
          AddressFields(
            controllers: _permanentAddress,
            enabled: true,
            validator: (v) => _required(v, l10n),
          ),
          const SizedBox(height: 16),
          Text(l10n.currentAddress, style: textTheme.titleSmall),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(l10n.sameAsPermanent),
            value: _sameAsPermanent,
            onChanged: (value) {
              setState(() {
                _sameAsPermanent = value ?? false;
                if (_sameAsPermanent) {
                  _presentAddress.copyFrom(_permanentAddress);
                }
              });
            },
          ),
          AddressFields(
            controllers: _presentAddress,
            enabled: !_sameAsPermanent,
            validator: (v) => _required(v, l10n),
          ),
          const SizedBox(height: 16),
          Text('Role details', style: textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final field in _role.profileFields) ...[
            TextFormField(
              controller: _profileControllers[field.key],
              keyboardType:
                  field.isPhone ? TextInputType.phone : TextInputType.text,
              textInputAction: TextInputAction.next,
              inputFormatters: field.isPhone
                  ? [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ]
                  : null,
              decoration: InputDecoration(
                labelText: field.label,
                prefixText: field.isPhone ? '+91 ' : null,
              ),
              validator: (v) => _profileValidator(field, v, l10n),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          FilledButton(
            onPressed: busy ? null : _submitSignup,
            child: busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.submitForApproval),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: busy
                ? null
                : () {
                    if (context.canPop()) {
                      context.pop();
                      if (context.canPop()) context.pop();
                    } else {
                      context.go('/login');
                    }
                  },
            child: Text(l10n.logIn),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpStep(AppLocalizations l10n, TextTheme textTheme, bool busy) {
    final phone = _phone.text.trim();
    return Form(
      key: _otpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: AppLogo.hero(width: 180)),
          const SizedBox(height: 28),
          Text(l10n.verifyOtp, style: textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            l10n.enterOtpForPhone(phone),
            style: textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _otp,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: InputDecoration(
              labelText: l10n.otp,
              prefixIcon: const Icon(Icons.lock_outline),
            ),
            validator: (v) => validateOtp(v, l10n),
            onFieldSubmitted: (_) => busy ? null : _verifyOtp(),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: busy ? null : _verifyOtp,
            child: busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.verifyOtp),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: busy ? null : _resendOtp,
            child: Text(l10n.resendOtp),
          ),
        ],
      ),
    );
  }
}
