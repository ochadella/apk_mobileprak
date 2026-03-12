import 'dart:async';
import '../models/dashboard_model.dart';

class DashboardRepository {
  Future<DashboardData> getDashboardData() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return DashboardData(
      stats: [
        DashboardStats(title: 'Mahasiswa', value: 124),
        DashboardStats(title: 'Dosen', value: 38),
        DashboardStats(title: 'Mata Kuliah', value: 45),
      ],
    );
  }
}