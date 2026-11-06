import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Compact in-button / inline loader using the themed M3 progress style.
class AppProgress extends StatelessWidget {
  const AppProgress({
    super.key,
    this.size = 20,
    this.color,
    this.strokeWidth = 2.4,
  });

  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color ?? AppColors.brand,
      ),
    );
  }
}
