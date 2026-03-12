import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dashboard_model.dart';
import '../../data/repositories/dashboard_repository.dart';

final dashboardRepositoryProvider =
Provider((ref) => DashboardRepository());

final dashboardProvider =
FutureProvider<List<DashboardStats>>((ref) async {

  final repo = ref.read(dashboardRepositoryProvider);

  return repo.getDashboardData();
});