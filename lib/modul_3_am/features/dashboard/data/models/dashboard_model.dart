class DashboardStats {
  final String title;
  final int value;

  DashboardStats({
    required this.title,
    required this.value,
  });

  DashboardStats copyWith({String? title, int? value}) {
    return DashboardStats(
      title: title ?? this.title,
      value: value ?? this.value,
    );
  }
}

class DashboardData {
  final List<DashboardStats> stats;

  DashboardData({required this.stats});

  DashboardData copyWith({List<DashboardStats>? stats}) {
    return DashboardData(stats: stats ?? this.stats);
  }
}