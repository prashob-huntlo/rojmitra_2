import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

/// Shared shimmer palette matching scaffold / card surfaces.
abstract final class AppShimmer {
  static const baseColor = Color(0xFFE2E7F0);
  static const highlightColor = Color(0xFFF3F6FA);

  static Widget wrap({required Widget child}) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }

  static Widget box({
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: borderRadius ?? BorderRadius.circular(AppStyles.radius),
      ),
    );
  }
}

/// Skeleton matching [WorkerTile] card shape.
class WorkerTileSkeleton extends StatelessWidget {
  const WorkerTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: AppShimmer.wrap(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppShimmer.box(width: 160.w, height: 16.h),
                    SizedBox(height: 10.h),
                    AppShimmer.box(width: 220.w, height: 12.h),
                    SizedBox(height: 6.h),
                    AppShimmer.box(width: 140.w, height: 12.h),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              AppShimmer.box(
                width: 72.w,
                height: 28.h,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkersListSkeleton extends StatelessWidget {
  const WorkersListSkeleton({
    super.key,
    this.itemCount = 6,
    this.showHeader = true,
  });

  final int itemCount;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppStyles.pagePadding,
      children: [
        if (showHeader) ...[
          AppShimmer.wrap(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppShimmer.box(width: 140.w, height: 24.h),
                SizedBox(height: 8.h),
                AppShimmer.box(width: 200.w, height: 14.h),
              ],
            ),
          ),
          SizedBox(height: 20.h),
        ],
        for (var i = 0; i < itemCount; i++) const WorkerTileSkeleton(),
      ],
    );
  }
}

class WorkerDetailSkeleton extends StatelessWidget {
  const WorkerDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppStyles.detailPadding,
      children: [
        AppShimmer.wrap(
          child: Card(
            child: Padding(
              padding: AppStyles.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppShimmer.box(width: 180.w, height: 22.h),
                  SizedBox(height: 12.h),
                  AppShimmer.box(
                    width: 90.w,
                    height: 28.h,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        AppShimmer.wrap(
          child: Card(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
              child: Column(
                children: [
                  for (var i = 0; i < 4; i++) ...[
                    Row(
                      children: [
                        AppShimmer.box(width: 110.w, height: 12.h),
                        SizedBox(width: 16.w),
                        Expanded(child: AppShimmer.box(height: 14.h)),
                      ],
                    ),
                    SizedBox(height: 14.h),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppStyles.pagePadding,
      children: [
        AppShimmer.wrap(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppShimmer.box(width: 100.w, height: 24.h),
              SizedBox(height: 16.h),
              Card(
                child: Padding(
                  padding: AppStyles.cardPadding,
                  child: Column(
                    children: [
                      for (var i = 0; i < 5; i++) ...[
                        Row(
                          children: [
                            AppShimmer.box(width: 100.w, height: 12.h),
                            SizedBox(width: 16.w),
                            Expanded(child: AppShimmer.box(height: 14.h)),
                          ],
                        ),
                        SizedBox(height: 12.h),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Form-shaped skeleton for document image slots / heavy form sections.
class FormFieldsSkeleton extends StatelessWidget {
  const FormFieldsSkeleton({super.key, this.fieldCount = 5});

  final int fieldCount;

  @override
  Widget build(BuildContext context) {
    return AppShimmer.wrap(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < fieldCount; i++) ...[
            AppShimmer.box(height: 56.h),
            SizedBox(height: 12.h),
          ],
        ],
      ),
    );
  }
}
