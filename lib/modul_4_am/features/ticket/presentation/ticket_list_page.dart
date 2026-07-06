import 'package:flutter/material.dart';
import '../../../core/services/ticket_service.dart';
import '../../auth/data/dummy_auth_service.dart';
import '../../tracking/presentation/tracking_page.dart';
import 'create_ticket_page.dart';
import 'ticket_detail_page.dart';

class TicketListPage extends StatefulWidget {
  const TicketListPage({super.key});

  @override
  State<TicketListPage> createState() => _TicketListPageState();
}

class _TicketListPageState extends State<TicketListPage> {
  final TextEditingController searchController = TextEditingController();
  String keyword = '';
  String selectedCategoryFilter = 'Semua';
  String selectedAssigneeFilter = 'Semua';
  List<Map<String, dynamic>> helpdeskUsersForFilter = [];

  @override
  void initState() {
    super.initState();
    // Selalu muat ulang tiket setiap halaman ini dibuka,
    // biar data selalu fresh (bukan cache lama).
    TicketService.loadTickets();

    if (DummyAuthService.isAdmin()) {
      TicketService.getHelpdeskUsers().then((users) {
        if (mounted) setState(() => helpdeskUsersForFilter = users);
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = DummyAuthService.isUser();

    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textPrimary =
    isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textMuted =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final border =
    isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
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
              isUser ? 'Tiket Saya' : 'List Tiket',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CreateTicketPage()),
          );
          // Refresh list setelah balik dari halaman create
          TicketService.loadTickets();
        },
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 2,
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Search bar ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border, width: 1),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) => setState(() => keyword = value),
                      style: TextStyle(color: textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Cari tiket...',
                        hintStyle:
                        TextStyle(color: textMuted, fontSize: 14),
                        prefixIcon:
                        Icon(Icons.search_rounded, color: textMuted, size: 20),
                        suffixIcon: keyword.isNotEmpty
                            ? IconButton(
                          onPressed: () {
                            searchController.clear();
                            setState(() => keyword = '');
                          },
                          icon: Icon(Icons.close_rounded,
                              color: textMuted, size: 18),
                        )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isUser
                        ? 'Menampilkan tiket yang kamu buat'
                        : 'Menampilkan seluruh tiket masuk',
                    style: TextStyle(
                        color: textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            // ── Filter Kategori (Admin/Helpdesk) ──────────────────
            if (!isUser)
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    'Semua',
                    'Jaringan',
                    'Perangkat',
                    'Akun',
                    'Lainnya',
                  ].map((cat) {
                    final isSelected = selectedCategoryFilter == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat, style: const TextStyle(fontSize: 12)),
                        selected: isSelected,
                        onSelected: (_) =>
                            setState(() => selectedCategoryFilter = cat),
                        selectedColor: accent,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B)),
                          fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        backgroundColor:
                        isDark ? const Color(0xFF1E293B) : Colors.white,
                        side: BorderSide(color: border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 10),

            // ── Filter Helpdesk (khusus Admin) ────────────────────
            if (DummyAuthService.isAdmin() && helpdeskUsersForFilter.isNotEmpty)
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    'Semua',
                    ...helpdeskUsersForFilter
                        .map((u) => (u['full_name'] ?? u['username'] ?? '-').toString()),
                  ].map((name) {
                    final isSelected = selectedAssigneeFilter == name;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(name, style: const TextStyle(fontSize: 12)),
                        selected: isSelected,
                        onSelected: (_) =>
                            setState(() => selectedAssigneeFilter = name),
                        selectedColor: const Color(0xFF0EA5E9),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B)),
                          fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        backgroundColor:
                        isDark ? const Color(0xFF1E293B) : Colors.white,
                        side: BorderSide(color: border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 10),

            // ── List ─────────────────────────────────────────────
            Expanded(
              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: TicketService.ticketsNotifier,
                builder: (context, tickets, _) {
                  // Catatan: filter per-role (User cuma lihat tiketnya sendiri,
                  // Helpdesk cuma lihat yang di-assign) SUDAH dilakukan
                  // di TicketService.loadTickets() lewat query reporter_id/
                  // assignee_id ke Supabase. Jangan filter ulang di sini
                  // pakai nama, karena rawan meleset kalau currentUser null.

                  final filteredTickets = tickets.where((ticket) {
                    final title =
                    (ticket['title'] ?? '').toString().toLowerCase();
                    final category =
                    (ticket['category'] ?? '').toString();
                    final assignee = (ticket['assignee'] ?? '').toString();
                    final key = keyword.toLowerCase();

                    final matchesKeyword = title.contains(key) ||
                        category.toLowerCase().contains(key);
                    final matchesCategory = selectedCategoryFilter == 'Semua' ||
                        category == selectedCategoryFilter;
                    final matchesAssignee = selectedAssigneeFilter == 'Semua' ||
                        assignee == selectedAssigneeFilter;

                    return matchesKeyword && matchesCategory && matchesAssignee;
                  }).toList();

                  if (filteredTickets.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: border, width: 1),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E3A5F)
                                    : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.inbox_rounded,
                                  color: accent, size: 26),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada tiket',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isUser
                                  ? 'Kamu belum membuat tiket.'
                                  : 'Belum ada tiket yang tersedia.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: textMuted,
                                  height: 1.4,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    itemCount: filteredTickets.length,
                    itemBuilder: (context, index) {
                      final ticket = filteredTickets[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TicketCard(
                          ticket: ticket,
                          isDark: isDark,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TicketDetailPage(ticket: ticket),
                              ),
                            );
                            TicketService.loadTickets();
                          },
                          onTrackingTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TrackingPage(ticket: ticket),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Ticket Card ──────────────────────────────────────────────────
class _TicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onTrackingTap;

  const _TicketCard({
    required this.ticket,
    required this.isDark,
    required this.onTap,
    required this.onTrackingTap,
  });

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

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'tinggi':
        return const Color(0xFFEF4444);
      case 'medium':
      case 'sedang':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = ticket['title']?.toString() ?? '-';
    final status = ticket['status']?.toString() ?? '-';
    final date = ticket['date']?.toString() ?? '-';
    final category = ticket['category']?.toString() ?? '-';
    final reporter = ticket['reporter']?.toString() ?? '-';
    final priority = ticket['priority']?.toString() ?? '-';

    final statusColor = _statusColor(status);
    final priorityColor = _priorityColor(priority);

    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary =
    isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textMuted =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    const accent = Color(0xFF2563EB);

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon box
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E3A5F)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.confirmation_number_rounded,
                        color: accent, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _Chip(
                              label: status,
                              color: statusColor,
                              isDark: isDark,
                            ),
                            _Chip(
                              label: priority,
                              color: priorityColor,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: textMuted, size: 20),
                ],
              ),
              const SizedBox(height: 10),
              // Divider
              Divider(
                  color: border, height: 1, thickness: 1),
              const SizedBox(height: 8),
              // Footer row
              Row(
                children: [
                  Icon(Icons.folder_outlined,
                      size: 13, color: textMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      category,
                      style: TextStyle(
                          fontSize: 12,
                          color: textMuted,
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.person_outline_rounded,
                      size: 13, color: textMuted),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      reporter,
                      style:
                      TextStyle(fontSize: 12, color: textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    date,
                    style: TextStyle(
                        fontSize: 11,
                        color: textMuted,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: onTrackingTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.track_changes_rounded,
                          size: 14, color: accent),
                      const SizedBox(width: 4),
                      Text(
                        'Tracking',
                        style: TextStyle(
                          fontSize: 12,
                          color: accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Chip badge ───────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;
  const _Chip(
      {required this.label, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}