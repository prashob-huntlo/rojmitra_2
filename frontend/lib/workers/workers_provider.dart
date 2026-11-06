import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/workers/data/workers_repository.dart';
import 'worker.dart';

class WorkersNotifier extends AsyncNotifier<List<Worker>> {
  WorkersRepository get _repo => ref.read(workersRepositoryProvider);

  @override
  Future<List<Worker>> build() => _repo.list();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repo.list);
  }

  Worker? findById(String id) {
    final list = state.asData?.value;
    if (list == null) return null;
    for (final item in list) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<void> setAvailability(String id, {required bool isReadyToWork}) async {
    await _repo.setAvailability(id: id, isReadyToWork: isReadyToWork);
    await refresh();
  }

  Future<Worker> create(Map<String, dynamic> body) async {
    final created = await _repo.create(body);
    await refresh();
    return created;
  }

  Future<Worker> updateWorker(
    String id,
    Map<String, dynamic> body,
  ) async {
    final updated = await _repo.update(id, body);
    await refresh();
    return updated;
  }
}

final workersProvider =
    AsyncNotifierProvider<WorkersNotifier, List<Worker>>(
  WorkersNotifier.new,
);
