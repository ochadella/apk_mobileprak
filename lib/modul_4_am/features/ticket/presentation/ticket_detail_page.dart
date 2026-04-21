import 'package:flutter/material.dart';
import '../../../core/services/ticket_service.dart';
import '../../auth/data/dummy_auth_service.dart';
import '../../tracking/presentation/tracking_page.dart';

class TicketDetailPage extends StatefulWidget {
  final Map<String, dynamic> ticket;

  const TicketDetailPage({
    super.key,
    required this.ticket,
  });

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  late String selectedStatus;
  late String selectedAssignee;
  final TextEditingController commentController = TextEditingController();
  late List<Map<String, String>> comments;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.ticket['status']?.toString() ?? 'Open';
    selectedAssignee =
        widget.ticket['assignee']?.toString() ?? 'Belum di-assign';
    comments = [
      {
        'name': widget.ticket['reporter']?.toString() ?? 'User',
        'message': 'Mohon segera dicek terkait tiket ini.',
        'time': '08:00',
      },
      {
        'name': 'Helpdesk',
        'message': 'Laporan diterima, sedang kami tindak lanjuti.',
        'time': '08:30',
      },
    ];
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void addComment() {
    if (commentController.text.trim().isEmpty) return;
    setState(() {
      comments.add({
        'name': DummyAuthService.currentUser?.fullName ?? 'User',
        'message': commentController.text.trim(),
        'time': 'Baru saja',
      });
      commentController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Komentar berhasil ditambahkan')),
    );
  }

  void saveTicketAction() {
    if (!DummyAuthService.canManageTicket()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hanya Helpdesk/Admin yang dapat mengubah tiket'),
        ),
      );
      return;
    }
    final newAssignee = DummyAuthService.canAssign()
        ? selectedAssignee
        : widget.ticket['assignee']?.toString() ?? 'Belum di-assign';

    TicketService.updateTicket(
      ticketId: widget.ticket['id']?.toString() ?? '',
      status: selectedStatus,
      assignee: newAssignee,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perubahan tiket berhasil disimpan')),
    );
    setState(() {
      widget.ticket['status'] = selectedStatus;
      widget.ticket['assignee'] = newAssignee;
      widget.ticket['tracking'] =
          TicketService.getTicketById(widget.ticket['id'])?['tracking'] ??
              widget.ticket['tracking'];
      selectedAssignee = newAssignee;
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
    final canManage = DummyAuthService.canManageTicket();
    final canAssign = DummyAuthService.canAssign();
    final ticket = widget.ticket;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary =
    isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textMuted =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    const accent = Color(0xFF2563EB);

    final statusColor = _statusColor(selectedStatus);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Detail Tiket',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: textPrimary,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Hero header ─────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ticket['title']?.toString() ?? '-',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _HeroBadge(label: selectedStatus, color: statusColor),
                        _HeroBadge(
                          label: ticket['priority']?.toString() ?? '-',
                          color: Colors.white.withOpacity(0.25),
                          textColor: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'ID: ${ticket['id']?.toString() ?? '-'}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Deskripsi ────────────────────────────────────────
              _SectionCard(
                title: 'Deskripsi',
                isDark: isDark,
                cardColor: cardColor,
                border: border,
                textPrimary: textPrimary,
                textMuted: textMuted,
                child: Text(
                  ticket['description']?.toString() ?? '-',
                  style: TextStyle(
                    height: 1.6,
                    fontSize: 13,
                    color: textMuted,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── Info Tiket ───────────────────────────────────────
              _SectionCard(
                title: 'Informasi Tiket',
                isDark: isDark,
                cardColor: cardColor,
                border: border,
                textPrimary: textPrimary,
                textMuted: textMuted,
                child: Column(
                  children: [
                    _InfoRow(
                        label: 'Kategori',
                        value: ticket['category']?.toString() ?? '-',
                        textPrimary: textPrimary,
                        textMuted: textMuted),
                    _RowDivider(color: border),
                    _InfoRow(
                        label: 'Prioritas',
                        value: ticket['priority']?.toString() ?? '-',
                        textPrimary: textPrimary,
                        textMuted: textMuted),
                    _RowDivider(color: border),
                    _InfoRow(
                        label: 'Tanggal',
                        value: ticket['date']?.toString() ?? '-',
                        textPrimary: textPrimary,
                        textMuted: textMuted),
                    _RowDivider(color: border),
                    _InfoRow(
                        label: 'Pelapor',
                        value: ticket['reporter']?.toString() ?? '-',
                        textPrimary: textPrimary,
                        textMuted: textMuted),
                    _RowDivider(color: border),
                    _InfoRow(
                        label: 'Assignee',
                        value: selectedAssignee,
                        textPrimary: textPrimary,
                        textMuted: textMuted),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ── Tracking button ──────────────────────────────────
              SizedBox(
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => TrackingPage(ticket: ticket)),
                    );
                  },
                  icon: Icon(Icons.track_changes_rounded,
                      size: 18, color: accent),
                  label: Text(
                    'Lihat Tracking',
                    style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: accent, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              // ── Aksi (Helpdesk/Admin) ────────────────────────────
              if (canManage) ...[
                const SizedBox(height: 10),
                _SectionCard(
                  title: canAssign ? 'Aksi Admin' : 'Aksi Helpdesk',
                  isDark: isDark,
                  cardColor: cardColor,
                  border: border,
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _StyledDropdown<String>(
                        label: 'Update Status',
                        value: selectedStatus,
                        items: ['Open', 'On Progress', 'Closed'],
                        isDark: isDark,
                        border: border,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        onChanged: (value) =>
                            setState(() => selectedStatus = value!),
                      ),
                      if (canAssign) ...[
                        const SizedBox(height: 10),
                        _StyledDropdown<String>(
                          label: 'Assign Tiket',
                          value: selectedAssignee,
                          items: [
                            'Belum di-assign',
                            'Helpdesk A',
                            'Helpdesk B'
                          ],
                          isDark: isDark,
                          border: border,
                          textPrimary: textPrimary,
                          textMuted: textMuted,
                          onChanged: (value) =>
                              setState(() => selectedAssignee = value!),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: saveTicketAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Simpan Perubahan',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 10),

              // ── Komentar ─────────────────────────────────────────
              _SectionCard(
                title: 'Komentar',
                isDark: isDark,
                cardColor: cardColor,
                border: border,
                textPrimary: textPrimary,
                textMuted: textMuted,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...comments.map(
                          (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _CommentTile(
                          name: item['name']!,
                          message: item['message']!,
                          time: item['time']!,
                          isDark: isDark,
                          textPrimary: textPrimary,
                          textMuted: textMuted,
                          border: border,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: border, width: 1),
                      ),
                      child: TextField(
                        controller: commentController,
                        maxLines: 3,
                        style:
                        TextStyle(color: textPrimary, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Tulis komentar...',
                          hintStyle:
                          TextStyle(color: textMuted, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: addComment,
                        icon: const Icon(Icons.send_rounded, size: 16),
                        label: const Text(
                          'Kirim Komentar',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Hero Badge ───────────────────────────────────────────────────
class _HeroBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  const _HeroBadge(
      {required this.label, required this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Section Card ─────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final bool isDark;
  final Color cardColor;
  final Color border;
  final Color textPrimary;
  final Color textMuted;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.isDark,
    required this.cardColor,
    required this.border,
    required this.textPrimary,
    required this.textMuted,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
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
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textMuted,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// ─── Row Divider ──────────────────────────────────────────────────
class _RowDivider extends StatelessWidget {
  final Color color;
  const _RowDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Divider(color: color, height: 16, thickness: 1);
  }
}

// ─── Info Row ─────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color textPrimary;
  final Color textMuted;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: textMuted,
                  fontWeight: FontWeight.w500)),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Styled Dropdown ──────────────────────────────────────────────
class _StyledDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final bool isDark;
  final Color border;
  final Color textPrimary;
  final Color textMuted;
  final ValueChanged<T?> onChanged;

  const _StyledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.isDark,
    required this.border,
    required this.textPrimary,
    required this.textMuted,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor:
          isDark ? const Color(0xFF1E293B) : Colors.white,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: textMuted, size: 20),
          hint: Text(label,
              style: TextStyle(color: textMuted, fontSize: 13)),
          style: TextStyle(
              color: textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                item.toString(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ),
          )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ─── Comment Tile ─────────────────────────────────────────────────
class _CommentTile extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final bool isDark;
  final Color textPrimary;
  final Color textMuted;
  final Color border;

  const _CommentTile({
    required this.name,
    required this.message,
    required this.time,
    required this.isDark,
    required this.textPrimary,
    required this.textMuted,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF2563EB);
    final avatarBg =
    isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: avatarBg,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: accent,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                          color: textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(fontSize: 13, color: textMuted),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}