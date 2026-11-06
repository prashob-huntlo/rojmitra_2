import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Which crop of the RojMitra brand sheet to show.
enum AppLogoVariant {
  /// Right crop — icon + wordmark + tagline (wide). App bars, headers.
  brand,

  /// Left crop — stacked icon above wordmark. Splash / auth hero.
  mark,

  /// Pin only — launcher-sized / compact chrome.
  pin,
}

/// Brand mark used in place of text titles in app bars and auth heroes.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.height,
    this.width,
    this.variant = AppLogoVariant.brand,
    this.alignment = Alignment.centerLeft,
  });

  /// Stacked mark for portrait splash / auth screens.
  const AppLogo.hero({
    super.key,
    this.height,
    this.width,
    this.alignment = Alignment.center,
  }) : variant = AppLogoVariant.mark;

  /// Compact pin for tight chrome.
  const AppLogo.pin({
    super.key,
    this.height,
    this.width,
    this.alignment = Alignment.center,
  }) : variant = AppLogoVariant.pin;

  final double? height;
  final double? width;
  final AppLogoVariant variant;
  final AlignmentGeometry alignment;

  static const brandPath = 'assets/images/rojmitra-brand.png';
  static const markPath = 'assets/images/rojmitra-mark.png';
  static const pinPath = 'assets/images/rojmitra-favicon.png';

  String get _assetPath => switch (variant) {
        AppLogoVariant.brand => brandPath,
        AppLogoVariant.mark => markPath,
        AppLogoVariant.pin => pinPath,
      };

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Image.asset(
        _assetPath,
        height: height ?? (variant == AppLogoVariant.brand ? 32.h : null),
        width: width,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
