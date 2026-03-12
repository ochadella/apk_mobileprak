import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:praktikummobile/modul_4_am/core/constants/constants.dart';
import 'package:praktikummobile/modul_4_am/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:praktikummobile/modul_4_am/features/dashboard/presentation/widgets/dashboard_widget.dart';
import 'package:praktikummobile/modul_4_am/features/dosen/presentation/pages/dosen_page.dart';
import 'package:praktikummobile/modul_4_am/mahasiswa/mahasiswa_page.dart';
import 'package:praktikummobile/modul_4_am/mahasiswa_aktif/mahasiswa_aktif_page.dart';
import 'package:praktikummobile/modul_4_am/profile/profile_page.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  IconData getIconForStat(String title) {
    switch (title) {
      case 'Total Mahasiswa':
        return Icons.school_rounded;
      case 'Mahasiswa Aktif':
        return Icons.person_outline_rounded;
      case 'Mahasiswa Lulus':
        return Icons.workspace_premium_rounded;
      case 'Dosen':
        return Icons.people_outline_rounded;
      default:
        return Icons.analytics_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (data) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(dashboardProvider);
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.85),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withOpacity(0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Selamat Datang! 👋",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        AppConstants.userName,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ProfilePage(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.person_outline_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Dashboard Statistik Mahasiswa",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Statistik",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => ref.invalidate(dashboardProvider),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text("Refresh"),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final stat = data[index];
                        Widget? targetPage;

                        switch (stat.title) {
                          case 'Total Mahasiswa':
                            targetPage = const MahasiswaPage();
                            break;
                          case 'Mahasiswa Aktif':
                            targetPage = const MahasiswaAktifPage();
                            break;
                          case 'Dosen':
                            targetPage = const DosenPage();
                            break;
                          case 'Mahasiswa Lulus':
                            targetPage = null;
                            break;
                        }

                        return ModernStatCard(
                          stats: stat,
                          icon: getIconForStat(stat.title),
                          gradientColors: AppConstants.dashboardGradients[
                          index % AppConstants.dashboardGradients.length],
                          onTap: targetPage == null
                              ? null
                              : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => targetPage!,
                              ),
                            );
                          },
                        );
                      },
                      childCount: data.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.0,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 28),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}