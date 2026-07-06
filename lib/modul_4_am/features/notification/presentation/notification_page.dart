import 'package:flutter/material.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/ticket_service.dart';
import '../../ticket/presentation/ticket_detail_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    // Pastikan daftar tiket yang relevan buat user ini fresh,
    // biar filter notifikasi di bawah akurat.
    TicketService.loadTickets();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              height: 18,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Notifikasi',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: textPrimary,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              NotificationService.markAllAsRead();
            },
            child: Text(
              'Baca semua',
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: NotificationService.notificationsNotifier,
        builder: (context, allNotifications, _) {
          // Cuma tampilin notifikasi yang tiketnya relevan buat role
          // user saat ini (tiket kosong id = notif umum, selalu tampil;
          // tiket ber-id cuma tampil kalau ada di daftar tiket yang
          // sudah difilter per role oleh TicketService).
          final notifications = allNotifications.where((item) {
            final ticketId = item['ticketId']?.toString() ?? '';
            if (ticketId.isEmpty) return true;
            return TicketService.getTicketById(ticketId) != null;
          }).toList();

          if (notifications.isEmpty) {
            return Center(
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
                      Icons.notifications_none_rounded,
                      color: accent,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada notifikasi',
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final item = notifications[index];
              final notifId = item['id']?.toString() ?? '';
              final bool unread = !NotificationService.isReadByCurrentUser(notifId);

              final cardColor = unread
                  ? (isDark
                  ? const Color(0xFF1E3A5F)
                  : const Color(0xFFEFF6FF))
                  : (isDark ? const Color(0xFF1E293B) : Colors.white);
              final border = isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0);
              final accentBorder = unread
                  ? (isDark
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFFBFDBFE))
                  : border;

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  final ticketId = item['ticketId']?.toString() ?? '';
                  if (ticketId.isEmpty) return;

                  final ticket = TicketService.getTicketById(ticketId);
                  if (ticket == null) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TicketDetailPage(ticket: ticket),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: accentBorder, width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E3A5F)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: accent,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item['title']?.toString() ?? '-',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: textPrimary,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                                if (unread)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: accent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['message']?.toString() ?? '-',
                              style: TextStyle(
                                color: textMuted,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item['time']?.toString() ?? '-',
                              style: TextStyle(
                                color: textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}