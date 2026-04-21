import 'package:flutter/material.dart';
import '../../../core/services/ticket_service.dart';

class TrackingPage extends StatelessWidget {
  final Map<String, dynamic>? ticket;

  const TrackingPage({super.key, this.ticket});

  @override
  Widget build(BuildContext context) {
    final selectedTicket = ticket ??
        (TicketService.tickets.isNotEmpty ? TicketService.tickets.first : null);

    final tracking = (selectedTicket?['tracking'] as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary =
    isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textMuted =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    const accent = Color(0xFF2563EB);
    const done_color = Color(0xFF10B981);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textMuted),
        title: Text(
          'Tracking Tiket',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: textPrimary,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: selectedTicket == null
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E3A5F)
                    : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.track_changes_rounded,
                color: accent,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada tiket',
              style: TextStyle(
                color: textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )
          : ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // ── Hero header ──────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedTicket['title'] ?? '-',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'ID: ${selectedTicket['id'] ?? '-'}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Section label ────────────────────────────────
          Text(
            'RIWAYAT PROGRES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          // ── Timeline ─────────────────────────────────────
          ...List.generate(tracking.length, (index) {
            final step = tracking[index];
            final bool done = step['done'] == true;
            final bool isLast = index == tracking.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dot + line
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: done ? done_color : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: done ? done_color : border,
                          width: 2,
                        ),
                      ),
                      child: done
                          ? const Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: Colors.white,
                      )
                          : Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: border,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 60,
                        decoration: BoxDecoration(
                          color: done ? done_color.withOpacity(0.3) : border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 12),

                // Card
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: done
                            ? done_color.withOpacity(0.35)
                            : border,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step['title']?.toString() ?? '-',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: textPrimary,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                step['time']?.toString() ?? '-',
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (done)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: done_color.withOpacity(
                                  isDark ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Selesai',
                              style: TextStyle(
                                color: done_color,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}