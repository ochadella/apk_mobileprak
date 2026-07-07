import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/ticket_service.dart';
import '../../auth/data/dummy_auth_service.dart';

// ─── Design Tokens ────────────────────────────────────────────────
// Accent  : #2563EB (Blue 600)
// Surface : #F8FAFC light / #0F172A dark
// Card    : #FFFFFF light / #1E293B dark
// Border  : #E2E8F0 light / #334155 dark
// Muted   : #64748B light / #94A3B8 dark

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = DummyAuthService.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canManage = DummyAuthService.canManageTicket();

    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textPrimary =
    isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textMuted =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    const accent = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              width: 3,
              height: 20,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.headset_mic_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'BABOY',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: textPrimary,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.profile),
            icon: Icon(
              Icons.person_outline_rounded,
              color: textMuted,
              size: 22,
            ),
          ),
          IconButton(
            onPressed: () async {
              await DummyAuthService.logout();
              TicketService.ticketsNotifier.value = [];
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.login,
              );
            },
            icon: Icon(
              Icons.logout_rounded,
              color: textMuted,
              size: 22,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: TicketService.ticketsNotifier,
          builder: (context, tickets, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero greeting ──────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selamat datang,',
                                style: TextStyle(
                                  color:
                                  Colors.white.withOpacity(0.72),
                                  fontSize: 12,
                                  letterSpacing: 0.1,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                user?.fullName ?? 'Dashboard',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  user?.role ?? '-',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.support_agent_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Stats ──────────────────────────────────────
                  _SectionLabel(label: 'Ringkasan', textColor: textMuted, accentColor: accent),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _StatCard(
                        label: 'Total',
                        value: TicketService.totalCount.toString(),
                        icon: Icons.inbox_rounded,
                        accentColor: accent,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _StatCard(
                        label: 'Open',
                        value: TicketService.openCount.toString(),
                        icon: Icons.radio_button_checked_rounded,
                        accentColor: const Color(0xFFF59E0B),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _StatCard(
                        label: 'Proses',
                        value: TicketService.progressCount.toString(),
                        icon: Icons.autorenew_rounded,
                        accentColor: const Color(0xFF0EA5E9),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _StatCard(
                        label: 'Selesai',
                        value: TicketService.closedCount.toString(),
                        icon: Icons.check_circle_rounded,
                        accentColor: const Color(0xFF10B981),
                        isDark: isDark,
                      ),
                    ],
                  ),

                  // ── Analitik (khusus Admin) ─────────────────────
                  if (DummyAuthService.isAdmin()) ...[
                    const SizedBox(height: 24),
                    _SectionLabel(label: 'Analitik', textColor: textMuted, accentColor: accent),
                    const SizedBox(height: 10),
                    _AnalyticsCard(
                      title: 'Tiket per Kategori',
                      data: TicketService.countByCategory,
                      isDark: isDark,
                      barColor: accent,
                    ),
                    const SizedBox(height: 10),
                    _AnalyticsCard(
                      title: 'Tiket per Prioritas',
                      data: TicketService.countByPriority,
                      isDark: isDark,
                      barColor: const Color(0xFFF59E0B),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ── Menu ───────────────────────────────────────
                  _SectionLabel(label: 'Menu', textColor: textMuted, accentColor: accent),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _MenuCard(
                          title: canManage ? 'Kelola Tiket' : 'List Tiket',
                          subtitle: canManage ? 'Semua tiket' : 'Tiket saya',
                          icon: Icons.receipt_long_rounded,
                          isDark: isDark,
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.ticketList),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MenuCard(
                          title: 'Buat Tiket',
                          subtitle: 'Kirim keluhan',
                          icon: Icons.add_circle_outline_rounded,
                          isDark: isDark,
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.createTicket),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: _MenuCard(
                          title: 'Tracking',
                          subtitle: 'Pantau progres',
                          icon: Icons.track_changes_rounded,
                          isDark: isDark,
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.tracking),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MenuCard(
                          title: 'Notifikasi',
                          subtitle: 'Update tiket',
                          icon: Icons.notifications_none_rounded,
                          isDark: isDark,
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.notification),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: _MenuCard(
                          title: 'Profile',
                          subtitle: 'Akun & tema',
                          icon: Icons.person_outline_rounded,
                          isDark: isDark,
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.profile),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DummyAuthService.isAdmin()
                            ? _MenuCard(
                          title: 'Manage User',
                          subtitle: 'Kelola akun',
                          icon: Icons.manage_accounts_rounded,
                          isDark: isDark,
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.manageUser),
                        )
                            : const SizedBox(),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color accentColor;

  const _SectionLabel({
    required this.label,
    required this.textColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 2,
          height: 12,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary =
    isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textMuted =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accentColor, size: 16),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Analytics Card (breakdown bar sederhana, tanpa library eksternal) ─
class _AnalyticsCard extends StatelessWidget {
  final String title;
  final Map<String, int> data;
  final bool isDark;
  final Color barColor;

  const _AnalyticsCard({
    required this.title,
    required this.data,
    required this.isDark,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary =
    isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textMuted =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final trackColor =
    isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    if (data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 1),
        ),
        child: Text(
          'Belum ada data',
          style: TextStyle(color: textMuted, fontSize: 12),
        ),
      );
    }

    final maxValue = data.values.reduce((a, b) => a > b ? a : b);
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...sortedEntries.map((entry) {
            final ratio = maxValue == 0 ? 0.0 : entry.value / maxValue;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 12,
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        entry.value.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            Container(
                              height: 8,
                              width: constraints.maxWidth,
                              color: trackColor,
                            ),
                            Container(
                              height: 8,
                              width: constraints.maxWidth * ratio,
                              color: barColor,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Menu Card ────────────────────────────────────────────────────
class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary =
    isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textMuted =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    const accent = Color(0xFF2563EB);
    final iconBg =
    isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF);

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 108,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent, size: 18),
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}