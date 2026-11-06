import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'worker.dart';

/// Client-side filters for the workers list.
class WorkerFilters {
  const WorkerFilters({
    this.query = '',
    this.isReadyToWork,
    this.hasDisability,
    this.tradeQuery = '',
    this.districtQuery = '',
  });

  /// Matches worker full name (case-insensitive).
  final String query;

  /// `null` = all, `true` = available, `false` = on a job.
  final bool? isReadyToWork;

  /// `null` = all, `true` = PwD, `false` = not PwD.
  final bool? hasDisability;

  /// Matches primary trade / main work name.
  final String tradeQuery;

  /// Matches permanent or current district.
  final String districtQuery;

  bool get isActive =>
      query.trim().isNotEmpty ||
      isReadyToWork != null ||
      hasDisability != null ||
      tradeQuery.trim().isNotEmpty ||
      districtQuery.trim().isNotEmpty;

  int get activeCount {
    var n = 0;
    if (query.trim().isNotEmpty) n++;
    if (isReadyToWork != null) n++;
    if (hasDisability != null) n++;
    if (tradeQuery.trim().isNotEmpty) n++;
    if (districtQuery.trim().isNotEmpty) n++;
    return n;
  }

  WorkerFilters copyWith({
    String? query,
    bool? isReadyToWork,
    bool clearAvailability = false,
    bool? hasDisability,
    bool clearDisability = false,
    String? tradeQuery,
    String? districtQuery,
  }) {
    return WorkerFilters(
      query: query ?? this.query,
      isReadyToWork:
          clearAvailability ? null : (isReadyToWork ?? this.isReadyToWork),
      hasDisability:
          clearDisability ? null : (hasDisability ?? this.hasDisability),
      tradeQuery: tradeQuery ?? this.tradeQuery,
      districtQuery: districtQuery ?? this.districtQuery,
    );
  }

  List<Worker> apply(List<Worker> workers) {
    final q = query.trim().toLowerCase();
    final trade = tradeQuery.trim().toLowerCase();
    final district = districtQuery.trim().toLowerCase();

    return [
      for (final w in workers)
        if (_matches(w, q, trade, district)) w,
    ];
  }

  bool _matches(Worker w, String q, String trade, String district) {
    if (isReadyToWork != null && w.isReadyToWork != isReadyToWork) {
      return false;
    }
    if (hasDisability != null &&
        w.personal.hasDisability != hasDisability) {
      return false;
    }
    if (q.isNotEmpty && !w.personal.fullName.toLowerCase().contains(q)) {
      return false;
    }
    if (trade.isNotEmpty &&
        !w.experience.primaryTrade.toLowerCase().contains(trade)) {
      return false;
    }
    if (district.isNotEmpty) {
      final perm = w.personal.permanentAddress.district.toLowerCase();
      final curr = w.personal.currentAddress.district.toLowerCase();
      if (!perm.contains(district) && !curr.contains(district)) {
        return false;
      }
    }
    return true;
  }
}

/// Shared so Home snapshot chips can open Workers with a filter applied.
class WorkerFiltersNotifier extends Notifier<WorkerFilters> {
  @override
  WorkerFilters build() => const WorkerFilters();

  void setFilters(WorkerFilters filters) => state = filters;

  void clear() => state = const WorkerFilters();
}

final workerFiltersProvider =
    NotifierProvider<WorkerFiltersNotifier, WorkerFilters>(
  WorkerFiltersNotifier.new,
);
