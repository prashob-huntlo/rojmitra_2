import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

abstract final class AppStyles {
  static EdgeInsets get pagePadding =>
      EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h);

  static EdgeInsets get detailPadding =>
      EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h);

  static EdgeInsets get cardPadding => EdgeInsets.all(20.r);

  static double get radius => 12.r;

  static RoundedRectangleBorder get cardShape => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: const BorderSide(color: AppColors.border),
      );

  static ButtonStyle get outlinedTall => OutlinedButton.styleFrom(
        minimumSize: Size.fromHeight(52.h),
      );
}
