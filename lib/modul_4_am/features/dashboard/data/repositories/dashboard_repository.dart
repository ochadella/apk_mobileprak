import '../models/dashboard_model.dart';

class DashboardRepository {
  Future<List<DashboardStats>> getDashboardData() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      DashboardStats(
        title: "Total Mahasiswa",
        subtitle: "Total keseluruhan",
        value: 1200,
      ),
      DashboardStats(
        title: "Mahasiswa Aktif",
        subtitle: "Sedang berjalan",
        value: 550,
      ),
      DashboardStats(
        title: "Dosen",
        subtitle: "Tenaga pengajar",
        value: 60,
      ),
      DashboardStats(
        title: "Mahasiswa Lulus",
        subtitle: "Alumni",
        value: 650,
      ),
    ];
  }
}