import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/brand.dart';
import '../core/errors/api_error.dart';
import '../core/ui/app_shimmer.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/models/partner.dart';
import '../features/auth/presentation/auth_notifier.dart';
import '../features/auth/presentation/partner_profile_provider.dart';
import '../features/uploads/data/uploads_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import 'profile_helpers.dart';

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  final _imagePicker = ImagePicker();
  bool _uploadingAvatar = false;
  /// Matches pubspec `version:` when PackageInfo is unavailable (e.g. mid-session plugin add).
  String _versionLabel = '1.0.0 (1)';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _versionLabel = '${info.version} (${info.buildNumber})';
      });
    } catch (_) {
      // Keep pubspec fallback.
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(partnerProfileProvider);
    await ref.read(partnerProfileProvider.future);
  }

  Future<void> _logout() async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (mounted) context.go('/login');
  }

  void _showError(Object error) {
    final message = error is ApiError ? error.error : error.toString();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _editAvatar(Partner partner) async {
    final l10n = AppLocalizations.of(context)!;
    final action = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(l10n.takePhoto),
                onTap: () => Navigator.pop(sheetContext, 'camera'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.chooseGallery),
                onTap: () => Navigator.pop(sheetContext, 'gallery'),
              ),
              if (partner.avatarUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: Text(l10n.removePhoto),
                  onTap: () => Navigator.pop(sheetContext, 'remove'),
                ),
            ],
          ),
        );
      },
    );
    if (action == null || !mounted) return;

    if (action == 'remove') {
      setState(() => _uploadingAvatar = true);
      try {
        final oldKey = partner.avatarUrl;
        await ref.read(authRepositoryProvider).updateMe(clearAvatar: true);
        ref.invalidate(partnerProfileProvider);
        if (oldKey != null) ref.invalidate(signedReadUrlProvider(oldKey));
        await ref.read(partnerProfileProvider.future);
      } catch (e) {
        _showError(e);
      } finally {
        if (mounted) setState(() => _uploadingAvatar = false);
      }
      return;
    }

    final source =
        action == 'camera' ? ImageSource.camera : ImageSource.gallery;
    final file = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (file == null || !mounted) return;

    setState(() => _uploadingAvatar = true);
    try {
      final oldKey = partner.avatarUrl;
      final key = await ref.read(uploadsRepositoryProvider).uploadImage(
            localPath: file.path,
            kind: 'avatar',
          );
      await ref.read(authRepositoryProvider).updateMe(avatarUrl: key);
      ref.invalidate(partnerProfileProvider);
      if (oldKey != null) ref.invalidate(signedReadUrlProvider(oldKey));
      await ref.read(partnerProfileProvider.future);
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _openSupport() async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.contactSupport, style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 8.h),
                Text(
                  l10n.contactSupportBody,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: AppColors.scaffold,
                    borderRadius: BorderRadius.circular(AppStyles.radius),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.mail_outline, color: AppColors.brand, size: 22.r),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          AppBrand.supportEmail,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                FilledButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      const ClipboardData(text: AppBrand.supportEmail),
                    );
                    if (!sheetContext.mounted) return;
                    Navigator.of(sheetContext).pop();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.emailCopied)),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded),
                  label: Text(l10n.copyEmail),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final asyncPartner = ref.watch(partnerProfileProvider);
    final textTheme = Theme.of(context).textTheme;

    return asyncPartner.when(
      skipLoadingOnReload: true,
      loading: () => const ProfileSkeleton(),
      error: (error, _) {
        final apiError = error is ApiError
            ? error
            : const ApiError(code: 'server_error', error: 'Something went wrong');
        return Padding(
          padding: AppStyles.pagePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(apiError.error, textAlign: TextAlign.center),
              SizedBox(height: 16.h),
              FilledButton(
                onPressed: () => ref.invalidate(partnerProfileProvider),
                child: const Text('Retry'),
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: _logout,
                child: Text(l10n.signOut),
              ),
            ],
          ),
        );
      },
      data: (partner) {
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: AppStyles.pagePadding,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _PartnerAvatar(
                    partner: partner,
                    uploading: _uploadingAvatar,
                    onTap: _uploadingAvatar ? null : () => _editAvatar(partner),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(partner.fullName, style: textTheme.headlineSmall),
                        SizedBox(height: 8.h),
                        Chip(label: Text(partnerRoleLabel(partner.role))),
                        SizedBox(height: 4.h),
                        TextButton(
                          onPressed: _uploadingAvatar
                              ? null
                              : () => _editAvatar(partner),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            alignment: Alignment.centerLeft,
                          ),
                          child: Text(
                            partner.avatarUrl == null
                                ? l10n.addPhotoOptional
                                : l10n.changePhoto,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Card(
                child: Column(
                  children: [
                    _ProfileNavRow(
                      icon: Icons.lock_outline,
                      title: l10n.authenticationDetails,
                      onTap: () => context.push('/profile/authentication'),
                    ),
                    const Divider(height: 1),
                    _ProfileNavRow(
                      icon: Icons.badge_outlined,
                      title: l10n.personalDetails,
                      onTap: () => context.push('/profile/personal'),
                    ),
                    const Divider(height: 1),
                    _ProfileNavRow(
                      icon: Icons.tune,
                      title: l10n.preferences,
                      onTap: () => context.push('/profile/preferences'),
                    ),
                    const Divider(height: 1),
                    _ProfileNavRow(
                      icon: Icons.support_agent_outlined,
                      title: l10n.contactSupport,
                      onTap: _openSupport,
                    ),
                    const Divider(height: 1),
                    _ProfileNavRow(
                      icon: Icons.privacy_tip_outlined,
                      title: l10n.privacyPolicy,
                      onTap: () => context.push('/privacy'),
                    ),
                    const Divider(height: 1),
                    _ProfileNavRow(
                      icon: Icons.description_outlined,
                      title: l10n.termsAndConditions,
                      onTap: () => context.push('/terms'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28.h),
              OutlinedButton(
                onPressed: _logout,
                style: AppStyles.outlinedTall,
                child: Text(l10n.signOut),
              ),
              SizedBox(height: 16.h),
              Text(
                l10n.appVersion(_versionLabel),
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        );
      },
    );
  }
}

class _PartnerAvatar extends ConsumerWidget {
  const _PartnerAvatar({
    required this.partner,
    required this.uploading,
    this.onTap,
  });

  final Partner partner;
  final bool uploading;
  final VoidCallback? onTap;

  String get _initials {
    final parts = partner.fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Widget _initialsLabel(BuildContext context) {
    return Text(
      _initials,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.brand,
            fontWeight: FontWeight.w700,
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = 72.r;
    final key = partner.avatarUrl;

    Widget child;
    if (uploading) {
      child = SizedBox(
        width: 24.r,
        height: 24.r,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (key == null) {
      child = _initialsLabel(context);
    } else {
      final asyncUrl = ref.watch(signedReadUrlProvider(key));
      final url = asyncUrl.asData?.value;
      if (url == null) {
        // Keep initials while URL resolves — no spinner flash on return.
        child = _initialsLabel(context);
      } else {
        child = ClipOval(
          child: IgnorePointer(
            child: Image.network(
              url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) =>
                  Center(child: _initialsLabel(context)),
            ),
          ),
        );
      }
    }

    return Material(
      color: AppColors.brand.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _ProfileNavRow extends StatelessWidget {
  const _ProfileNavRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
