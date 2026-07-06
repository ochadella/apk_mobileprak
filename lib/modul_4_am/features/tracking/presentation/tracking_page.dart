import 'package:flutter/material.dart';
import '../../../core/services/ticket_service.dart';
import '../../auth/data/dummy_auth_service.dart';

class TrackingPage extends StatefulWidget {
  final Map<String, dynamic>? ticket;

  const TrackingPage({super.key, this.ticket});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  List<Map<String, dynamic>> tracking = [];
  bool isLoading = true;
  String selectedStatusFilter = 'Semua';

  Map<String, dynamic>? get selectedTicket => widget.ticket;

  /// Mode list cuma aktif kalau: gak ada tiket spesifik yang dikirim,
  /// DAN rolenya Admin/Helpdesk (yang emang ngurus banyak tiket sekaligus).
  /// User selalu diarahkan ke 1 tiket spesifik dari List Tiket, jadi
  /// gak butuh mode list ini.
  bool get isListMode =>
      widget.ticket == null &&
          (DummyAuthService.isAdmin() || DummyAuthService.isHelpdesk());

  @override
  void initState() {
    super.initState();
    TicketService.loadTickets();
    if (!isListMode) {
      _loadHistory();
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadHistory() async {
    final ticket = selectedTicket;
    if (ticket == null) {
      setState(() => isLoading = false);
      return;
    }

    final history = await TicketService.loadTrackingHistory(
      ticket['id']?.toString() ?? '',
    );

    if (!mounted) return;
    setState(() {
      tracking = history;
      isLoading = false;
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Open':
        return const Color(0xFFF59E0B);
      case 'On Progress':
        return const Color(0xFF0EA5E9);
      case 'Closed':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textPrimary =
    isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textMuted =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

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
      body: isListMode ? _buildListMode(isDark) : _buildDetailMode(isDark),
    );
  }

  // ─── MODE LIST: buat Admin/Helpdesk, nampilin semua tiket + filter status ──
  Widget _buildListMode(bool isDark) {
    final textPrimary =
    isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textMuted =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    const accent = Color(0xFF2563EB);

    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: TicketService.ticketsNotifier,
      builder: (context, tickets, _) {
        final filtered = tickets.where((t) {
          if (selectedStatusFilter == 'Semua') return true;
          return (t['status'] ?? '').toString() == selectedStatusFilter;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Filter status ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ['Semua', 'Open', 'On Progress', 'Closed']
                      .map((status) {
                    final isSelected = selectedStatusFilter == status;
                    final chipColor =
                    status == 'Semua' ? accent : _statusColor(status);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(status, style: const TextStyle(fontSize: 12)),
                        selected: isSelected,
                        onSelected: (_) =>
                            setState(() => selectedStatusFilter = status),
                        selectedColor: chipColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : textMuted,
                          fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        backgroundColor: cardColor,
                        side: BorderSide(color: border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ── List tiket ───────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                child: Text(
                  'Tidak ada tiket dengan status ini',
                  style: TextStyle(color: textMuted, fontSize: 13),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final ticket = filtered[index];
                  final status = (ticket['status'] ?? '-').toString();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TrackingPage(ticket: ticket),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: border, width: 1),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ticket['title']?.toString() ?? '-',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'ID: ${ticket['shortId'] ?? '-'}',
                                      style: TextStyle(
                                        color: textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor(status),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(Icons.chevron_right_rounded,
                                  color: textMuted, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── MODE DETAIL: 1 tiket spesifik, timeline riwayat (User & tap dari list) ──
  Widget _buildDetailMode(bool isDark) {
    final ticket = selectedTicket;

    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary =
    isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textMuted =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    const accent = Color(0xFF2563EB);
    const doneColor = Color(0xFF10B981);

    if (ticket == null) {
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
      );
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
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
                ticket['title'] ?? '-',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(ticket['status']?.toString() ?? '-'),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  ticket['status']?.toString() ?? '-',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'ID: ${ticket['shortId'] ?? ticket['id'] ?? '-'}',
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

        if (tracking.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border, width: 1),
            ),
            child: Center(
              child: Text(
                'Belum ada riwayat tercatat untuk tiket ini',
                style: TextStyle(color: textMuted, fontSize: 13),
              ),
            ),
          )
        else
          ...List.generate(tracking.length, (index) {
            final step = tracking[index];
            final bool isLast = index == tracking.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: doneColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 60,
                        decoration: BoxDecoration(
                          color: doneColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: doneColor.withOpacity(0.35),
                        width: 1,
                      ),
                    ),
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
                        const SizedBox(height: 2),
                        Text(
                          'oleh ${step['by']?.toString() ?? '-'}',
                          style: TextStyle(
                            color: textMuted,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
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
    );
  }
}