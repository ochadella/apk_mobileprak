import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/dashboard_model.dart';
import '../../data/repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

class DashboardController extends AsyncNotifier<DashboardData> {
  @override
  Future<DashboardData> build() async {
    final repo = ref.read(dashboardRepositoryProvider);
    return repo.getDashboardData();
  }

  void tambahByTitle(String title) {
    final current = state.value;
    if (current == null) return;

    final updated = current.stats.map((s) {
      if (s.title == title) return s.copyWith(value: s.value + 1);
      return s;
    }).toList();

    state = AsyncData(current.copyWith(stats: updated));
  }
}

final dashboardControllerProvider =
AsyncNotifierProvider<DashboardController, DashboardData>(
  DashboardController.new,
);