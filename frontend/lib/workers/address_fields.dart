import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/l10n/app_localizations.dart';

import 'worker.dart';

class AddressControllers {
  AddressControllers({Address? initial})
      : addressLine = TextEditingController(text: initial?.addressLine ?? ''),
        villageOrTown =
            TextEditingController(text: initial?.villageOrTown ?? ''),
        district = TextEditingController(text: initial?.district ?? ''),
        state = TextEditingController(text: initial?.state ?? ''),
        pincode = TextEditingController(text: initial?.pincode ?? '');

  final TextEditingController addressLine;
  final TextEditingController villageOrTown;
  final TextEditingController district;
  final TextEditingController state;
  final TextEditingController pincode;

  Address toAddress() {
    return Address(
      addressLine: addressLine.text.trim(),
      villageOrTown: villageOrTown.text.trim(),
      district: district.text.trim(),
      state: state.text.trim(),
      pincode: pincode.text.trim(),
    );
  }

  void copyFrom(AddressControllers other) {
    addressLine.text = other.addressLine.text;
    villageOrTown.text = other.villageOrTown.text;
    district.text = other.district.text;
    state.text = other.state.text;
    pincode.text = other.pincode.text;
  }

  void addListener(VoidCallback listener) {
    addressLine.addListener(listener);
    villageOrTown.addListener(listener);
    district.addListener(listener);
    state.addListener(listener);
    pincode.addListener(listener);
  }

  void removeListener(VoidCallback listener) {
    addressLine.removeListener(listener);
    villageOrTown.removeListener(listener);
    district.removeListener(listener);
    state.removeListener(listener);
    pincode.removeListener(listener);
  }

  void dispose() {
    addressLine.dispose();
    villageOrTown.dispose();
    district.dispose();
    state.dispose();
    pincode.dispose();
  }
}

class AddressFields extends StatelessWidget {
  const AddressFields({
    super.key,
    required this.controllers,
    required this.enabled,
    required this.validator,
  });

  final AddressControllers controllers;
  final bool enabled;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        TextFormField(
          controller: controllers.addressLine,
          enabled: enabled,
          decoration: InputDecoration(labelText: l10n.addressLine),
          validator: validator,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controllers.villageOrTown,
          enabled: enabled,
          decoration: InputDecoration(labelText: l10n.villageOrTown),
          validator: validator,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controllers.district,
          enabled: enabled,
          decoration: InputDecoration(labelText: l10n.district),
          validator: validator,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controllers.state,
          enabled: enabled,
          decoration: InputDecoration(labelText: l10n.state),
          validator: validator,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controllers.pincode,
          enabled: enabled,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          decoration: InputDecoration(labelText: l10n.pincode),
          validator: (value) {
            final requiredError = validator(value);
            if (requiredError != null) {
              return requiredError;
            }
            if (value!.trim().length != 6) {
              return l10n.requiredField;
            }
            return null;
          },
        ),
      ],
    );
  }
}
