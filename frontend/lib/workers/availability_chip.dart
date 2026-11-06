import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/l10n/app_localizations.dart';

class AvailabilityChip extends StatelessWidget {
  const AvailabilityChip({
    super.key,
    required this.isAvailable,
    this.onTap,
  });

  final bool isAvailable;

  /// When set, shows a switch. Tapping it calls this (opens the confirm modal);
  /// the switch itself does not flip until the parent rebuilds with new data.
  final VoidCallback? onTap;

  static const _availableColor = Color(0xFF2E7D32);
  static const _onJobColor = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = isAvailable ? _availableColor : _onJobColor;
    final label = isAvailable ? l10n.ready : l10n.busy;

    final labelText = Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
    );

    if (onTap == null) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8.r,
              height: 8.r,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: 6.w),
            labelText,
          ],
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        labelText,
        SizedBox(width: 4.w),
        Switch.adaptive(
          value: isAvailable,
          activeThumbColor: _availableColor,
          onChanged: (_) => onTap!(),
        ),
      ],
    );
  }
}
