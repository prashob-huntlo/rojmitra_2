import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../workers/address_fields.dart';
import 'profile_helpers.dart';

class PersonalDetailsPage extends ConsumerStatefulWidget {
  const PersonalDetailsPage({super.key});

  @override
  ConsumerState<PersonalDetailsPage> createState() =>
      _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends ConsumerState<PersonalDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  AddressControllers? _permanent;
  AddressControllers? _present;
  final Map<String, TextEditingController> _profileControllers = {};

  String? _boundPartnerId;
  bool _sameAsPermanent = true;
  bool _saving = false;

  @override
  void dispose() {
    _permanent?.removeListener(_syncPresent);
    _fullName.dispose();
    _permanent?.dispose();
    _present?.dispose();
    for (final c in _profileControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncPresent() {
    if (!_sameAsPermanent) return;
    _present?.copyFrom(_permanent!);
  }

  String? _required(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) return l10n.requiredField;
    return null;
  }

  String? _profileValidator(
    Partner partner,
    PartnerProfileField field,
    String? value,
    AppLocalizations l10n,
  ) {
    if (field.isPhone) {
      return validateOtherMobile(value, partner.phoneNumber, l10n);
    }
    if (!field.required) return null;
    return _required(value, l10n);
  }

  void _bind(Partner partner) {
    if (_boundPartnerId == partner.id) return;

    _permanent?.removeListener(_syncPresent);
    _permanent?.dispose();
    _present?.dispose();
    for (final c in _profileControllers.values) {
      c.dispose();
    }
    _profileControllers.clear();

    _fullName.text = partner.fullName;
    final permanent = AddressControllers(initial: partner.permanentAddress);
    final present = AddressControllers(
      initial: partner.presentSameAsPermanent
          ? partner.permanentAddress
          : partner.presentAddress,
    );
    // Legacy flat fields → seed address if structured address missing.
    if ((partner.permanentAddress == null ||
            partner.permanentAddress!.addressLine.isEmpty) &&
        partner.state.isNotEmpty) {
      permanent.state.text = partner.state;
      permanent.district.text = partner.district;
      permanent.pincode.text = partner.pincode;
    }
    _sameAsPermanent = partner.presentSameAsPermanent ||
        partner.presentAddress == null ||
        (partner.permanentAddress != null &&
            partner.presentAddress != null &&
            partner.permanentAddress!.isSameAs(partner.presentAddress!));
    if (_sameAsPermanent) {
      present.copyFrom(permanent);
    }
    permanent.addListener(_syncPresent);
    _permanent = permanent;
    _present = present;

    for (final field in partnerProfileFieldsForRole(partner.role)) {
      _profileControllers[field.key] = TextEditingController(
        text: partner.profile[field.key]?.toString() ?? '',
      );
    }

    _boundPartnerId = partner.id;
  }

  Future<void> _save(Partner partner) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    final permanent = _permanent;
    final present = _present;
    if (permanent == null || present == null) return;

    if (_sameAsPermanent) {
      present.copyFrom(permanent);
    }

    setState(() => _saving = true);
    try {
      await ref.read(authRepositoryProvider).updateMe(
            fullName: _fullName.text.trim(),
            permanentAddress: permanent.toAddress().toApiJson(),
            presentSameAsPermanent: _sameAsPermanent,
            presentAddress:
                _sameAsPermanent ? null : present.toAddress().toApiJson(),
            profile: {
              for (final field in partnerProfileFieldsForRole(partner.role))
                field.key: _profileControllers[field.key]!.text.trim(),
            },
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.personalDetails)),
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
          final permanent = _permanent!;
          final present = _present!;
          final roleFields = partnerProfileFieldsForRole(partner.role);

          return Form(
            key: _formKey,
            child: ListView(
              padding: AppStyles.detailPadding,
              children: [
                TextFormField(
                  controller: _fullName,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(labelText: l10n.fullName),
                  validator: (v) => _required(v, l10n),
                ),
                SizedBox(height: 12.h),
                InputDecorator(
                  decoration: const InputDecoration(labelText: 'Role'),
                  child: Text(
                    partnerRoleLabel(partner.role),
                    style: textTheme.bodyLarge,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(l10n.permanentAddress, style: textTheme.titleMedium),
                SizedBox(height: 8.h),
                AddressFields(
                  controllers: permanent,
                  enabled: true,
                  validator: (v) => _required(v, l10n),
                ),
                SizedBox(height: 20.h),
                Text(l10n.currentAddress, style: textTheme.titleMedium),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(l10n.sameAsPermanent),
                  value: _sameAsPermanent,
                  onChanged: (value) {
                    setState(() {
                      _sameAsPermanent = value ?? false;
                      if (_sameAsPermanent) {
                        present.copyFrom(permanent);
                      }
                    });
                  },
                ),
                AddressFields(
                  controllers: present,
                  enabled: !_sameAsPermanent,
                  validator: (v) => _required(v, l10n),
                ),
                if (roleFields.isNotEmpty) ...[
                  SizedBox(height: 20.h),
                  Text('Role details', style: textTheme.titleMedium),
                  SizedBox(height: 8.h),
                  for (final field in roleFields) ...[
                    TextFormField(
                      controller: _profileControllers[field.key],
                      keyboardType: field.isPhone
                          ? TextInputType.phone
                          : TextInputType.text,
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
                      validator: (v) =>
                          _profileValidator(partner, field, v, l10n),
                    ),
                    SizedBox(height: 12.h),
                  ],
                ],
                SizedBox(height: 16.h),
                FilledButton(
                  onPressed: _saving ? null : () => _save(partner),
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
                SizedBox(height: 12.h),
              ],
            ),
          );
        },
      ),
    );
  }
}
