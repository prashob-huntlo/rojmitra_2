import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/errors/api_error.dart';
import '../core/ui/app_shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../workers/worker_filters.dart';
import '../workers/worker_tile.dart';
import '../workers/workers_provider.dart';

class WorkersPage extends ConsumerStatefulWidget {
  const WorkersPage({super.key, this.showAppBar = false});

  final bool showAppBar;

  @override
  ConsumerState<WorkersPage> createState() => _WorkersPageState();
}

class _WorkersPageState extends ConsumerState<WorkersPage> {
  void _openForm() {
    context.push('/worker/new');
  }

  Future<void> _openFilterSheet() async {
    final current = ref.read(workerFiltersProvider);
    final result = await showModalBottomSheet<WorkerFilters>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return _WorkerFilterSheet(initial: current);
      },
    );
    if (result == null || !mounted) return;
    ref.read(workerFiltersProvider.notifier).setFilters(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final asyncList = ref.watch(workersProvider);
    final filters = ref.watch(workerFiltersProvider);
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    final body = asyncList.when(
      loading: () => const WorkersListSkeleton(),
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
        final filtered = filters.apply(workers);
        return RefreshIndicator(
          onRefresh: () => ref.read(workersProvider.notifier).refresh(),
          child: ListView(
            padding: AppStyles.pagePadding,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.workers, style: textTheme.headlineSmall),
                        SizedBox(height: 4.h),
                        Text(
                          filters.isActive
                              ? '${filtered.length} of ${workers.length}'
                              : l10n.workersCount(workers.length),
                          style: textTheme.bodyLarge?.copyWith(color: muted),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  SizedBox(
                    height: 40.h,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        IconButton.filledTonal(
                          tooltip: l10n.filter,
                          onPressed: _openFilterSheet,
                          style: IconButton.styleFrom(
                            minimumSize: Size(40.h, 40.h),
                            maximumSize: Size(40.h, 40.h),
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            backgroundColor: filters.isActive
                                ? AppColors.brand.withValues(alpha: 0.18)
                                : AppColors.brand.withValues(alpha: 0.1),
                            foregroundColor: AppColors.brand,
                          ),
                          icon: Badge(
                            isLabelVisible: filters.isActive,
                            label: Text('${filters.activeCount}'),
                            child: Icon(Icons.tune, size: 20.r),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        FilledButton.tonalIcon(
                          onPressed: _openForm,
                          style: FilledButton.styleFrom(
                            minimumSize: Size(0, 40.h),
                            maximumSize: Size(double.infinity, 40.h),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            backgroundColor:
                                AppColors.brand.withValues(alpha: 0.1),
                            foregroundColor: AppColors.brand,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                          ),
                          icon: Icon(Icons.add, size: 18.r),
                          label: Text(l10n.addWorker),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (filters.isActive) ...[
                SizedBox(height: 12.h),
                _ActiveFilterChips(
                  filters: filters,
                  onClear: () =>
                      ref.read(workerFiltersProvider.notifier).clear(),
                  onEdit: _openFilterSheet,
                ),
              ],
              SizedBox(height: 20.h),
              if (workers.isEmpty)
                _EmptyState(onAdd: _openForm)
              else if (filtered.isEmpty)
                _NoMatchState(onClear: () {
                  ref.read(workerFiltersProvider.notifier).clear();
                })
              else
                for (final person in filtered) WorkerTile(worker: person),
            ],
          ),
        );
      },
    );

    if (!widget.showAppBar) return body;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.workers)),
      body: body,
    );
  }
}

class _ActiveFilterChips extends StatelessWidget {
  const _ActiveFilterChips({
    required this.filters,
    required this.onClear,
    required this.onEdit,
  });

  final WorkerFilters filters;
  final VoidCallback onClear;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chips = <Widget>[];

    if (filters.query.trim().isNotEmpty) {
      chips.add(Chip(label: Text('"${filters.query.trim()}"')));
    }
    if (filters.isReadyToWork == true) {
      chips.add(Chip(label: Text(l10n.filterAvailable)));
    } else if (filters.isReadyToWork == false) {
      chips.add(Chip(label: Text(l10n.filterOnJob)));
    }
    if (filters.hasDisability == true) {
      chips.add(Chip(label: Text(l10n.filterWithDisability)));
    } else if (filters.hasDisability == false) {
      chips.add(Chip(label: Text(l10n.filterWithoutDisability)));
    }
    if (filters.tradeQuery.trim().isNotEmpty) {
      chips.add(Chip(label: Text(filters.tradeQuery.trim())));
    }
    if (filters.districtQuery.trim().isNotEmpty) {
      chips.add(Chip(label: Text(filters.districtQuery.trim())));
    }

    return Wrap(
      spacing: 8.w,
      runSpacing: 4.h,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...chips,
        TextButton(onPressed: onEdit, child: Text(l10n.filter)),
        TextButton(onPressed: onClear, child: Text(l10n.clearFilters)),
      ],
    );
  }
}

class _WorkerFilterSheet extends StatefulWidget {
  const _WorkerFilterSheet({required this.initial});

  final WorkerFilters initial;

  @override
  State<_WorkerFilterSheet> createState() => _WorkerFilterSheetState();
}

class _WorkerFilterSheetState extends State<_WorkerFilterSheet> {
  late final TextEditingController _query;
  late final TextEditingController _trade;
  late final TextEditingController _district;
  late bool? _availability;
  late bool? _disability;

  @override
  void initState() {
    super.initState();
    _query = TextEditingController(text: widget.initial.query);
    _trade = TextEditingController(text: widget.initial.tradeQuery);
    _district = TextEditingController(text: widget.initial.districtQuery);
    _availability = widget.initial.isReadyToWork;
    _disability = widget.initial.hasDisability;
  }

  @override
  void dispose() {
    _query.dispose();
    _trade.dispose();
    _district.dispose();
    super.dispose();
  }

  WorkerFilters _build() {
    return WorkerFilters(
      query: _query.text,
      isReadyToWork: _availability,
      hasDisability: _disability,
      tradeQuery: _trade.text,
      districtQuery: _district.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.filters, style: textTheme.titleLarge),
            SizedBox(height: 16.h),
            TextField(
              controller: _query,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.searchWorkers,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16.h),
            Text(l10n.filterAvailability, style: textTheme.titleSmall),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              children: [
                ChoiceChip(
                  label: Text(l10n.filterAll),
                  selected: _availability == null,
                  onSelected: (_) => setState(() => _availability = null),
                ),
                ChoiceChip(
                  label: Text(l10n.filterAvailable),
                  selected: _availability == true,
                  onSelected: (_) => setState(() => _availability = true),
                ),
                ChoiceChip(
                  label: Text(l10n.filterOnJob),
                  selected: _availability == false,
                  onSelected: (_) => setState(() => _availability = false),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(l10n.filterDisability, style: textTheme.titleSmall),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              children: [
                ChoiceChip(
                  label: Text(l10n.filterAll),
                  selected: _disability == null,
                  onSelected: (_) => setState(() => _disability = null),
                ),
                ChoiceChip(
                  label: Text(l10n.filterWithDisability),
                  selected: _disability == true,
                  onSelected: (_) => setState(() => _disability = true),
                ),
                ChoiceChip(
                  label: Text(l10n.filterWithoutDisability),
                  selected: _disability == false,
                  onSelected: (_) => setState(() => _disability = false),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _trade,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.filterTrade,
                hintText: l10n.filterTradeHint,
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: _district,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n.filterDistrict,
                hintText: l10n.filterDistrictHint,
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _query.clear();
                        _trade.clear();
                        _district.clear();
                        _availability = null;
                        _disability = null;
                      });
                    },
                    child: Text(l10n.clearFilters),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, _build()),
                    child: Text(l10n.applyFilters),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppStyles.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.groups_outlined, size: 40.r, color: AppColors.brand),
          SizedBox(height: 12.h),
          Text(
            'No workers registered yet',
            style: textTheme.titleMedium?.copyWith(color: AppColors.ink),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            'Register a worker when you verify someone in the field.',
            style: textTheme.bodyMedium?.copyWith(color: muted),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 18.h),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.person_add_alt_1),
            label: Text(l10n.addWorker),
          ),
        ],
      ),
    );
  }
}

class _NoMatchState extends StatelessWidget {
  const _NoMatchState({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppStyles.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.filter_alt_off_outlined, size: 40.r, color: muted),
          SizedBox(height: 12.h),
          Text(
            l10n.noWorkersMatchFilters,
            style: textTheme.titleMedium?.copyWith(color: AppColors.ink),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 18.h),
          TextButton(onPressed: onClear, child: Text(l10n.clearFilters)),
        ],
      ),
    );
  }
}
