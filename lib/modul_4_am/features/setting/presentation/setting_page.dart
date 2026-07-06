import 'package:flutter/material.dart';
import '../../../core/theme/theme_controller.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
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
              'Pengaturan',
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
                'TAMPILAN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textMuted,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Dark Mode Toggle ───────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border, width: 1),
            ),
            child: ValueListenableBuilder<ThemeMode>(
              valueListenable: ThemeController.themeModeNotifier,
              builder: (context, mode, _) {
                return Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.dark_mode_outlined,
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
                            'Dark Mode',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: textPrimary,
                            ),
                          ),
                          Text(
                            'Aktifkan tema gelap',
                            style: TextStyle(
                              fontSize: 11,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: mode == ThemeMode.dark,
                      onChanged: ThemeController.toggleTheme,
                      activeColor: accent,
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 24),

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
                'TENTANG',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textMuted,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border, width: 1),
            ),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.info_outline_rounded,
                  label: 'Versi Aplikasi',
                  value: '2.0.0',
                  iconBg: iconBg,
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                ),
                Divider(color: border, height: 20, thickness: 1),
                _InfoRow(
                  icon: Icons.apps_outlined,
                  label: 'Nama Aplikasi',
                  value: 'E-Ticketing Helpdesk',
                  iconBg: iconBg,
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconBg;
  final Color textPrimary;
  final Color textMuted;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconBg,
    required this.textPrimary,
    required this.textMuted,
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
            color: textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
