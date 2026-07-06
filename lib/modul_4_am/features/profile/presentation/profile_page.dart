import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/ticket_service.dart';
import '../../../core/theme/theme_controller.dart';
import '../../auth/data/dummy_auth_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = DummyAuthService.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary =
    isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textMuted =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    const accent = Color(0xFF2563EB);
    final iconBg = isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF);

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
              height: 18,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Profile',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: textPrimary,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: bg,
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -40,
              child: _circle(100, Colors.blue.withOpacity(isDark ? 0.04 : 0.05)),
            ),
            Positioned(
              bottom: 100,
              left: -50,
              child: _circle(140, Colors.blue.withOpacity(isDark ? 0.03 : 0.04)),
            ),
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                // ── Avatar Card ────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            (user?.fullName.isNotEmpty == true)
                                ? user!.fullName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? '-',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '@${user?.username ?? '-'}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.72),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 3),
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
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Info Card (dengan fade-in animation) ────────────────
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: border, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 2,
                              height: 12,
                              decoration: BoxDecoration(
                                color: accent,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'INFORMASI AKUN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: textMuted,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.badge_outlined,
                          label: 'Nama Lengkap',
                          value: user?.fullName ?? '-',
                          iconBg: iconBg,
                          textPrimary: textPrimary,
                          textMuted: textMuted,
                          border: border,
                        ),
                        Divider(color: border, height: 20, thickness: 1),
                        _InfoRow(
                          icon: Icons.person_outline_rounded,
                          label: 'Username',
                          value: user?.username ?? '-',
                          iconBg: iconBg,
                          textPrimary: textPrimary,
                          textMuted: textMuted,
                          border: border,
                        ),
                        Divider(color: border, height: 20, thickness: 1),
                        _InfoRow(
                          icon: Icons.admin_panel_settings_outlined,
                          label: 'Role',
                          value: user?.role ?? '-',
                          iconBg: iconBg,
                          textPrimary: textPrimary,
                          textMuted: textMuted,
                          border: border,
                          valueColor: accent,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Pengaturan (link ke halaman Setting terpisah) ────────
                Material(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.settings),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: border, width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: iconBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.settings_outlined,
                              color: accent,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pengaturan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: textPrimary,
                                  ),
                                ),
                                Text(
                                  'Tema & info aplikasi',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              color: textMuted, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Ganti Password Button ────────────────────────────────
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.changePassword);
                    },
                    icon: Icon(
                      Icons.lock_reset_outlined,
                      size: 18,
                      color: textPrimary,
                    ),
                    label: Text(
                      'Ganti Password',
                      style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: border, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Logout Button ──────────────────────────────────────
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await DummyAuthService.logout();
                      TicketService.ticketsNotifier.value = [];
                      ThemeController.resetToDefault();
                      if (!context.mounted) return;
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                            (route) => false,
                      );
                    },
                    icon: const Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: Color(0xFFEF4444),
                    ),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFEF4444), width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Info Row ─────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconBg;
  final Color textPrimary;
  final Color textMuted;
  final Color border;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconBg,
    required this.textPrimary,
    required this.textMuted,
    required this.border,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF2563EB);
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: accent, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}