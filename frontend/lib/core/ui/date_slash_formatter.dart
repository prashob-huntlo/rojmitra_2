import 'package:flutter/services.dart';

/// Formats digits as `DD/MM/YYYY`, inserting `/` and clamping day/month.
class DateSlashInputFormatter extends TextInputFormatter {
  const DateSlashInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final oldDigits = oldValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 8) {
      digits = digits.substring(0, 8);
    }

    // Deleting a slash: also drop the digit before it so backspace feels natural.
    if (newValue.text.length < oldValue.text.length &&
        digits.length == oldDigits.length &&
        digits.isNotEmpty) {
      digits = digits.substring(0, digits.length - 1);
    }

    digits = _clampDateParts(digits);

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2 || i == 4) buffer.write('/');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  /// Keeps day in 01–31 and month in 01–12 as those segments are completed.
  static String _clampDateParts(String digits) {
    if (digits.isEmpty) return digits;

    final chars = digits.split('');

    // Day first digit: 0–3
    if (chars.isNotEmpty) {
      final d0 = int.parse(chars[0]);
      if (d0 > 3) chars[0] = '3';
    }
    // Day complete
    if (chars.length >= 2) {
      var day = int.parse('${chars[0]}${chars[1]}');
      if (day == 0) day = 1;
      if (day > 31) day = 31;
      chars[0] = (day ~/ 10).toString();
      chars[1] = (day % 10).toString();
    }

    // Month first digit: 0–1
    if (chars.length >= 3) {
      final m0 = int.parse(chars[2]);
      if (m0 > 1) chars[2] = '1';
    }
    // Month complete
    if (chars.length >= 4) {
      var month = int.parse('${chars[2]}${chars[3]}');
      if (month == 0) month = 1;
      if (month > 12) month = 12;
      chars[2] = (month ~/ 10).toString();
      chars[3] = (month % 10).toString();
    }

    return chars.join();
  }
}

/// Latest DOB allowed for someone who is at least [minAge] years old today.
DateTime maxDobForMinAge({int minAge = 18, DateTime? now}) {
  final today = now ?? DateTime.now();
  return DateTime(today.year - minAge, today.month, today.day);
}

/// Returns a parsed DOB if [text] is a real DD/MM/YYYY calendar date.
/// When [requireMinAge] is set, the person must be at least that many years old.
DateTime? tryParseDobDdMmYyyy(
  String text, {
  int? requireMinAge = 18,
}) {
  final parts = text.trim().split('/');
  if (parts.length != 3) return null;
  if (parts[0].length != 2 || parts[1].length != 2 || parts[2].length != 4) {
    return null;
  }
  final d = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final y = int.tryParse(parts[2]);
  if (d == null || m == null || y == null) return null;
  if (y < 1900) return null;

  final date = DateTime(y, m, d);
  if (date.year != y || date.month != m || date.day != d) return null;

  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  if (date.isAfter(todayDate)) return null;

  if (requireMinAge != null && date.isAfter(maxDobForMinAge(minAge: requireMinAge))) {
    return null;
  }
  return date;
}

/// Returns ISO-8601 if [text] is a valid DOB (default: age ≥ 18).
String? parseDobDdMmYyyy(String text, {int? requireMinAge = 18}) {
  return tryParseDobDdMmYyyy(text, requireMinAge: requireMinAge)?.toIso8601String();
}

String formatDobDdMmYyyy(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  return '$d/$m/${date.year}';
}
