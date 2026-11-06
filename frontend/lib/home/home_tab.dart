import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/errors/api_error.dart';
import '../core/ui/app_shimmer.dart';
import '../features/auth/models/partner.dart';
import '../features/auth/presentation/partner_profile_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../workers/worker_filters.dart';
import '../workers/worker_tile.dart';
import '../workers/workers_provider.dart';
import 'profile_helpers.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  static const previewCount = 3;

  String _firstName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? fullName : parts.first;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncList = ref.watch(workersProvider);
    final asyncPartner = ref.watch(partnerProfileProvider);
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return asyncList.when(
      loading: () => const WorkersListSkeleton(itemCount: 3),
      error: (error, _) {
        final message = error is ApiError ? error.error : 'Something went wrong';
        return Center(
          child: Padding(
            padding: AppStyles.pagePadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(message, textAlign: TextAlign.center),
                SizedBox(height: 12.h),
                FilledButton(
                  onPressed: () =>
                      ref.read(workersProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
      data: (workers) {
        final available =
            workers.where((t) => t.isReadyToWork).length;
        final onJob = workers.length - available;
        final preview = workers.take(previewCount).toList();
        final partner = asyncPartner.asData?.value;

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(partnerProfileProvider);
            await ref.read(workersProvider.notifier).refresh();
          },
          child: ListView(
            padding: AppStyles.pagePadding,
            children: [
              _Greeting(
                partner: partner,
                firstName: partner == null
                    ? null
                    : _firstName(partner.fullName),
              ),
              SizedBox(height: 20.h),
              _SnapshotRow(
                total: workers.length,
                available: available,
                onJob: onJob,
                onRegistered: () {
                  ref.read(workerFiltersProvider.notifier).clear();
                  context.go('/workers');
                },
                onAvailable: () {
                  ref.read(workerFiltersProvider.notifier).setFilters(
                        const WorkerFilters(isReadyToWork: true),
                      );
                  context.go('/workers');
                },
                onOnJob: () {
                  ref.read(workerFiltersProvider.notifier).setFilters(
                        const WorkerFilters(isReadyToWork: false),
                      );
                  context.go('/workers');
                },
              ),
              SizedBox(height: 16.h),
              _RegisterAction(
                onTap: () => context.push('/worker/new'),
              ),
              SizedBox(height: 28.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Recent workers',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  if (workers.isNotEmpty)
                    TextButton(
                      onPressed: () => context.go('/workers'),
                      child: Text(l10n.moreWorkers),
                    ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                l10n.recentWorkers,
                style: textTheme.bodyMedium?.copyWith(color: muted),
              ),
              SizedBox(height: 14.h),
              if (preview.isEmpty)
                _EmptyWorkersHint(
                  onAdd: () => context.push('/worker/new'),
                )
              else
                ...preview.map(
                  (worker) =>
                      WorkerTile(worker: worker),
                ),
              SizedBox(height: 12.h),
            ],
          ),
        );
      },
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.partner, required this.firstName});

  final Partner? partner;
  final String? firstName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final hour = DateTime.now().hour;
    final hello = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          firstName == null || firstName!.isEmpty
              ? hello
              : '$hello, $firstName',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        SizedBox(height: 6.h),
        if (partner != null)
          Text(
            '${partnerRoleLabel(partner!.role)} partner · ${partner!.district}',
            style: textTheme.bodyMedium?.copyWith(color: muted),
          )
        else
          Text(
            'Your field workspace',
            style: textTheme.bodyMedium?.copyWith(color: muted),
          ),
      ],
    );
  }
}

class _SnapshotRow extends StatelessWidget {
  const _SnapshotRow({
    required this.total,
    required this.available,
    required this.onJob,
    required this.onRegistered,
    required this.onAvailable,
    required this.onOnJob,
  });

  final int total;
  final int available;
  final int onJob;
  final VoidCallback onRegistered;
  final VoidCallback onAvailable;
  final VoidCallback onOnJob;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            label: 'Registered',
            value: '$total',
            accent: AppColors.brand,
            onTap: onRegistered,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _StatChip(
            label: 'Available',
            value: '$available',
            accent: const Color(0xFF16A34A),
            onTap: onAvailable,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _StatChip(
            label: 'On a job',
            value: '$onJob',
            accent: AppColors.accent,
            onTap: onOnJob,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final String value;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppStyles.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyles.radius),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppStyles.radius),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: accent,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegisterAction extends StatelessWidget {
  const _RegisterAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Material(
      color: AppColors.brand.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppStyles.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyles.radius),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: AppColors.brand,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.person_add_alt_1_rounded,
                  color: Colors.white,
                  size: 22.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.addWorker,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Register someone you verified in the field',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: muted,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyWorkersHint extends StatelessWidget {
  const _EmptyWorkersHint({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 22.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppStyles.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.groups_outlined, size: 36.r, color: AppColors.brand),
          SizedBox(height: 10.h),
          Text(
            'No workers on your list yet',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            'Start with someone you already know in your area.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: muted),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 14.h),
          TextButton(
            onPressed: onAdd,
            child: const Text('Register first worker'),
          ),
        ],
      ),
    );
  }
}
