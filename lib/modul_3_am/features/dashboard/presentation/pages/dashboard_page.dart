import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/common_widget.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/dashboard_widget.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard (Riverpod)')),
      body: state.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => CustomErrorWidget(message: 'Error: $e'),
        data: (data) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...data.stats.map(
                      (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DashboardItem(
                      stats: s,
                      onTap: () => ref
                          .read(dashboardControllerProvider.notifier)
                          .tambahByTitle(s.title),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}