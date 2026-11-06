import 'package:frontend/l10n/app_localizations.dart';

String? validateIndianMobile(String? value, AppLocalizations l10n) {
  final phone = value?.trim() ?? '';
  if (phone.isEmpty) {
    return l10n.enterMobileNumber;
  }
  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
    return l10n.enterValidMobile;
  }
  return null;
}

/// Optional email: empty OK; otherwise basic format check.
String? validateOptionalEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return null;
  if (!email.contains('@') || !email.contains('.')) {
    return 'Enter a valid email';
  }
  return null;
}

/// Supervisor / secondary phone: required 10-digit Indian mobile, ≠ [ownPhone].
String? validateOtherMobile(
  String? value,
  String ownPhone,
  AppLocalizations l10n, {
  String sameAsOwnMessage = 'Must be different from your mobile number',
}) {
  final err = validateIndianMobile(value, l10n);
  if (err != null) return err;
  if (value!.trim() == ownPhone.trim()) return sameAsOwnMessage;
  return null;
}

String? validatePassword(String? value, AppLocalizations l10n) {
  if (value == null || value.isEmpty) {
    return l10n.enterPassword;
  }
  return null;
}

String? validateOtp(String? value, AppLocalizations l10n) {
  final otp = value?.trim() ?? '';
  if (otp.isEmpty) {
    return l10n.enterOtp;
  }
  if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
    return l10n.enterSixDigitOtp;
  }
  return null;
}

String? validateNewPassword(String? value, AppLocalizations l10n) {
  final password = value ?? '';
  if (password.isEmpty) {
    return l10n.enterNewPassword;
  }
  if (password.length < 8) {
    return l10n.useAtLeast8Characters;
  }
  return null;
}

String? validateConfirmPassword(
  String? value,
  String password,
  AppLocalizations l10n,
) {
  if (value == null || value.isEmpty) {
    return l10n.confirmNewPassword;
  }
  if (value != password) {
    return l10n.passwordsDoNotMatch;
  }
  return null;
}
