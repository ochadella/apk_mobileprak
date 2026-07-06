import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
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
  String? selectedAssigneeId;
  late String selectedAssigneeName;
  final TextEditingController commentController = TextEditingController();

  List<Map<String, dynamic>> helpdeskUsers = [];
  List<Map<String, dynamic>> comments = [];
  bool isLoadingHelpdesk = true;
  bool isLoadingComments = true;
  bool isSaving = false;
  bool isSendingComment = false;
  int selectedRating = 0;
  final TextEditingController feedbackController = TextEditingController();
  bool isSubmittingRating = false;

  // Fitur tambahan Helpdesk
  DateTime? selectedEstimatedDate;
  bool isSavingEstimate = false;
  File? proofImage;
  final ImagePicker picker = ImagePicker();
  bool isUploadingProof = false;
  final TextEditingController transferReasonController = TextEditingController();
  bool isRequestingTransfer = false;
  bool isResolvingTransfer = false;
  String? selectedNewAssigneeForTransfer;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.ticket['status']?.toString() ?? 'Open';
    selectedAssigneeId = widget.ticket['assignee_id']?.toString();
    selectedAssigneeName =
        widget.ticket['assignee']?.toString() ?? 'Belum di-assign';

    final rawEstimate = widget.ticket['estimated_completion'];
    if (rawEstimate != null) {
      try {
        selectedEstimatedDate = DateTime.parse(rawEstimate.toString());
      } catch (_) {}
    }

    _loadHelpdeskUsers();
    _loadComments();
  }

  @override
  void dispose() {
    commentController.dispose();
    feedbackController.dispose();
    transferReasonController.dispose();
    super.dispose();
  }

  Future<void> _loadHelpdeskUsers() async {
    final users = await TicketService.getHelpdeskUsers();
    if (!mounted) return;
    setState(() {
      helpdeskUsers = users;
      isLoadingHelpdesk = false;
    });
  }

  Future<void> _loadComments() async {
    final ticketId = widget.ticket['id']?.toString() ?? '';
    final loaded = await TicketService.loadComments(ticketId);
    if (!mounted) return;
    setState(() {
      comments = loaded;
      isLoadingComments = false;
    });
  }

  Future<void> addComment() async {
    final message = commentController.text.trim();
    if (message.isEmpty) return;

    setState(() => isSendingComment = true);

    final success = await TicketService.addComment(
      ticketId: widget.ticket['id']?.toString() ?? '',
      message: message,
    );

    if (!mounted) return;

    if (success) {
      commentController.clear();
      await _loadComments();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentar berhasil ditambahkan')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim komentar, coba lagi')),
      );
    }

    setState(() => isSendingComment = false);
  }

  Future<void> saveTicketAction() async {
    if (!DummyAuthService.canManageTicket()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hanya Helpdesk/Admin yang dapat mengubah tiket'),
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    final newAssigneeId =
    DummyAuthService.canAssign() ? selectedAssigneeId : null;
    final newAssigneeName = DummyAuthService.canAssign()
        ? selectedAssigneeName
        : widget.ticket['assignee']?.toString() ?? 'Belum di-assign';

    await TicketService.updateTicket(
      ticketId: widget.ticket['id']?.toString() ?? '',
      status: selectedStatus,
      assigneeId: newAssigneeId,
      assigneeName: newAssigneeName,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perubahan tiket berhasil disimpan')),
    );

    setState(() {
      widget.ticket['status'] = selectedStatus;
      widget.ticket['assignee'] = newAssigneeName;
      widget.ticket['assignee_id'] = newAssigneeId;
      widget.ticket['tracking'] =
          TicketService.getTicketById(widget.ticket['id'])?['tracking'] ??
              widget.ticket['tracking'];
      isSaving = false;
    });
  }

  Future<void> submitRating() async {
    if (selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih rating dulu (minimal 1 bintang)')),
      );
      return;
    }

    setState(() => isSubmittingRating = true);

    final success = await TicketService.submitRating(
      ticketId: widget.ticket['id']?.toString() ?? '',
      rating: selectedRating,
      feedback: feedbackController.text.trim().isEmpty
          ? null
          : feedbackController.text.trim(),
    );

    if (!mounted) return;
    setState(() => isSubmittingRating = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terima kasih atas penilaiannya!')),
      );
      setState(() {
        widget.ticket['rating'] = selectedRating;
        widget.ticket['feedback'] = feedbackController.text.trim();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim rating, coba lagi')),
      );
    }
  }

  Future<void> pickEstimatedDateAndSave() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: selectedEstimatedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedEstimatedDate ?? now),
    );
    if (time == null || !mounted) return;

    final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    setState(() => isSavingEstimate = true);

    final success = await TicketService.setEstimatedCompletion(
      ticketId: widget.ticket['id']?.toString() ?? '',
      estimatedDate: combined,
    );

    if (!mounted) return;
    setState(() {
      isSavingEstimate = false;
      if (success) {
        selectedEstimatedDate = combined;
        widget.ticket['estimated_completion'] = combined.toIso8601String();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Estimasi waktu penyelesaian disimpan'
            : 'Gagal menyimpan estimasi, coba lagi'),
      ),
    );
  }

  Future<void> pickAndUploadProof() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (image == null || !mounted) return;

    setState(() {
      proofImage = File(image.path);
      isUploadingProof = true;
    });

    try {
      final fileName =
          'proof_${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
      final bytes = await proofImage!.readAsBytes();

      await supabase.Supabase.instance.client.storage
          .from('ticket-attachments')
          .uploadBinary(fileName, bytes);

      final proofUrl = supabase.Supabase.instance.client.storage
          .from('ticket-attachments')
          .getPublicUrl(fileName);

      final success = await TicketService.uploadCompletionProof(
        ticketId: widget.ticket['id']?.toString() ?? '',
        proofUrl: proofUrl,
      );

      if (!mounted) return;
      setState(() {
        isUploadingProof = false;
        if (success) widget.ticket['completion_proof_url'] = proofUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Bukti penyelesaian berhasil diupload'
              : 'Gagal menyimpan bukti, coba lagi'),
        ),
      );
    } catch (e) {
      print('UPLOAD PROOF ERROR: $e');
      if (!mounted) return;
      setState(() => isUploadingProof = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal upload gambar, coba lagi')),
      );
    }
  }

  Future<void> showTransferDialog() async {
    transferReasonController.clear();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final fieldBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textPrimary = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    const accent = Color(0xFF2563EB);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(isDark ? 0.18 : 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.swap_horiz_rounded,
                          color: Color(0xFFEF4444), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ajukan Pengalihan Tiket',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: fieldBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border, width: 1),
                  ),
                  child: TextField(
                    controller: transferReasonController,
                    maxLines: 3,
                    style: TextStyle(color: textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Alasan pengalihan (di luar keahlian, dsb)...',
                      hintStyle: TextStyle(color: textMuted, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: border),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Batal',
                              style: TextStyle(color: textMuted, fontSize: 13)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Ajukan',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final reason = transferReasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi alasan pengalihan dulu')),
      );
      return;
    }

    setState(() => isRequestingTransfer = true);

    final success = await TicketService.requestTransfer(
      ticketId: widget.ticket['id']?.toString() ?? '',
      reason: reason,
    );

    if (!mounted) return;
    setState(() {
      isRequestingTransfer = false;
      if (success) {
        widget.ticket['transfer_requested'] = true;
        widget.ticket['transfer_reason'] = reason;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Pengajuan pengalihan terkirim ke Admin'
            : 'Gagal mengajukan pengalihan, coba lagi'),
      ),
    );
  }

  Future<void> rejectTransfer() async {
    setState(() => isResolvingTransfer = true);

    final success = await TicketService.resolveTransferRequest(
      ticketId: widget.ticket['id']?.toString() ?? '',
      approved: false,
    );

    if (!mounted) return;
    setState(() {
      isResolvingTransfer = false;
      if (success) widget.ticket['transfer_requested'] = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Pengajuan pengalihan ditolak'
            : 'Gagal memproses, coba lagi'),
      ),
    );
  }

  Future<void> approveTransferDialog() async {
    if (helpdeskUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada akun Helpdesk lain terdaftar')),
      );
      return;
    }

    selectedNewAssigneeForTransfer = null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final fieldBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textPrimary = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    const accent = Color(0xFF2563EB);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: accent.withOpacity(isDark ? 0.18 : 0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.swap_horiz_rounded,
                              color: accent, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Setujui & Alihkan Tiket',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pilih Helpdesk baru untuk tiket ini',
                      style: TextStyle(color: textMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: fieldBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: border, width: 1),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedNewAssigneeForTransfer,
                          isExpanded: true,
                          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          icon: Icon(Icons.keyboard_arrow_down_rounded,
                              color: textMuted, size: 20),
                          hint: Text('Pilih Helpdesk',
                              style: TextStyle(color: textMuted, fontSize: 13)),
                          style: TextStyle(
                              color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                          items: helpdeskUsers
                              .map((u) => DropdownMenuItem<String>(
                            value: u['id'] as String,
                            child: Text(
                                '${u['full_name'] ?? u['username'] ?? '-'} · ${TicketService.helpdeskActiveWorkload(u['id'] as String)} aktif'),
                          ))
                              .toList(),
                          onChanged: (value) {
                            setDialogState(() => selectedNewAssigneeForTransfer = value);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: border),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text('Batal',
                                  style: TextStyle(color: textMuted, fontSize: 13)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              onPressed: selectedNewAssigneeForTransfer == null
                                  ? null
                                  : () => Navigator.pop(
                                  dialogContext, selectedNewAssigneeForTransfer),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                disabledBackgroundColor: border,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Konfirmasi',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700, fontSize: 13)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null || !mounted) return;

    final newUser = helpdeskUsers.firstWhere((u) => u['id'] == result);
    final newName = newUser['full_name'] ?? newUser['username'] ?? '-';

    setState(() => isResolvingTransfer = true);

    final success = await TicketService.resolveTransferRequest(
      ticketId: widget.ticket['id']?.toString() ?? '',
      approved: true,
      newAssigneeId: result,
      newAssigneeName: newName,
    );

    if (!mounted) return;
    setState(() {
      isResolvingTransfer = false;
      if (success) {
        widget.ticket['transfer_requested'] = false;
        widget.ticket['assignee_id'] = result;
        widget.ticket['assignee'] = newName;
        selectedAssigneeId = result;
        selectedAssigneeName = newName;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Tiket berhasil dialihkan ke $newName'
            : 'Gagal memproses, coba lagi'),
      ),
    );
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

    // Daftar item buat dropdown assign: null = 'Belum di-assign', sisanya id user Helpdesk aktif.
    // PENTING: kalau assignee saat ini ternyata sudah dinonaktifkan (gak ada lagi
    // di helpdeskUsers), tetep masukkan id-nya biar dropdown gak crash karena
    // value gak ketemu di antara items.
    final assigneeItems = <String?>[
      null,
      ...helpdeskUsers.map((u) => u['id'] as String),
      if (selectedAssigneeId != null &&
          !helpdeskUsers.any((u) => u['id'] == selectedAssigneeId))
        selectedAssigneeId!,
    ];
    String assigneeLabel(String? id) {
      if (id == null) return 'Belum di-assign';
      final user = helpdeskUsers.firstWhere(
            (u) => u['id'] == id,
        orElse: () => {'full_name': selectedAssigneeName},
      );
      final isInactiveNow = !helpdeskUsers.any((u) => u['id'] == id);
      final name = user['full_name'] ?? user['username'] ?? '-';
      final workload = TicketService.helpdeskActiveWorkload(id);
      return isInactiveNow
          ? '$name (nonaktif)'
          : '$name · $workload aktif';
    }

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
              'Detail Tiket',
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
                      'ID: ${ticket['shortId']?.toString() ?? ticket['id']?.toString() ?? '-'}',
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

              // ── Lampiran ─────────────────────────────────────────
              if (ticket['attachment_url'] != null &&
                  ticket['attachment_url'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SectionCard(
                    title: 'Lampiran',
                    isDark: isDark,
                    cardColor: cardColor,
                    border: border,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        ticket['attachment_url'].toString(),
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const SizedBox(
                            height: 180,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 100,
                            alignment: Alignment.center,
                            child: Text(
                              'Gagal memuat gambar',
                              style: TextStyle(color: textMuted, fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

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
                        value: assigneeLabel(selectedAssigneeId),
                        textPrimary: textPrimary,
                        textMuted: textMuted),
                    if (selectedEstimatedDate != null) ...[
                      _RowDivider(color: border),
                      _InfoRow(
                          label: 'Estimasi Selesai',
                          value:
                          '${selectedEstimatedDate!.day}/${selectedEstimatedDate!.month}/${selectedEstimatedDate!.year} ${selectedEstimatedDate!.hour.toString().padLeft(2, '0')}:${selectedEstimatedDate!.minute.toString().padLeft(2, '0')}',
                          textPrimary: textPrimary,
                          textMuted: textMuted),
                    ],
                  ],
                ),
              ),

              // ── Banner Pengalihan Diajukan ────────────────────────
              if (ticket['transfer_requested'] == true) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(isDark ? 0.15 : 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.swap_horiz_rounded,
                              color: Color(0xFFF59E0B), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pengalihan tiket diajukan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  ticket['transfer_reason']?.toString() ?? '-',
                                  style: TextStyle(fontSize: 12, color: textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (canAssign) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 38,
                                child: OutlinedButton(
                                  onPressed: isResolvingTransfer
                                      ? null
                                      : rejectTransfer,
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFEF4444)),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Tolak',
                                      style: TextStyle(
                                          color: Color(0xFFEF4444), fontSize: 12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 38,
                                child: ElevatedButton(
                                  onPressed: isResolvingTransfer
                                      ? null
                                      : approveTransferDialog,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accent,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: isResolvingTransfer
                                      ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                      : const Text('Setujui & Alihkan',
                                      style: TextStyle(fontSize: 12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        const SizedBox(height: 6),
                        Text(
                          'Menunggu tindakan Admin.',
                          style: TextStyle(fontSize: 11, color: textMuted),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

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
                        items: const ['Open', 'On Progress', 'Closed'],
                        labelBuilder: (v) => v,
                        isDark: isDark,
                        border: border,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        onChanged: (value) =>
                            setState(() => selectedStatus = value!),
                      ),
                      if (canAssign) ...[
                        const SizedBox(height: 10),
                        isLoadingHelpdesk
                            ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                            : _StyledDropdown<String?>(
                          label: 'Assign Tiket',
                          value: selectedAssigneeId,
                          items: assigneeItems,
                          labelBuilder: assigneeLabel,
                          isDark: isDark,
                          border: border,
                          textPrimary: textPrimary,
                          textMuted: textMuted,
                          onChanged: (value) => setState(() {
                            selectedAssigneeId = value;
                            selectedAssigneeName = assigneeLabel(value);
                          }),
                        ),
                        if (!isLoadingHelpdesk && helpdeskUsers.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'Belum ada akun Helpdesk terdaftar',
                              style: TextStyle(color: textMuted, fontSize: 11),
                            ),
                          ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: isSaving ? null : saveTicketAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isSaving
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
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

              // ── Fitur Tambahan Helpdesk ──────────────────────────
              if (DummyAuthService.isHelpdesk()) ...[
                const SizedBox(height: 10),
                _SectionCard(
                  title: 'Progress Penanganan',
                  isDark: isDark,
                  cardColor: cardColor,
                  border: border,
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Estimasi waktu penyelesaian
                      Text(
                        'Estimasi Waktu Penyelesaian',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: textPrimary),
                      ),
                      const SizedBox(height: 6),
                      OutlinedButton.icon(
                        onPressed: isSavingEstimate ? null : pickEstimatedDateAndSave,
                        icon: isSavingEstimate
                            ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2))
                            : Icon(Icons.event_outlined, size: 16, color: accent),
                        label: Text(
                          selectedEstimatedDate == null
                              ? 'Set Estimasi Waktu'
                              : 'Ubah Estimasi Waktu',
                          style: TextStyle(color: accent, fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: border),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Bukti penyelesaian
                      Text(
                        'Bukti Penyelesaian',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: textPrimary),
                      ),
                      const SizedBox(height: 6),
                      if (ticket['completion_proof_url'] != null &&
                          ticket['completion_proof_url'].toString().isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            ticket['completion_proof_url'].toString(),
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 6),
                      OutlinedButton.icon(
                        onPressed: isUploadingProof ? null : pickAndUploadProof,
                        icon: isUploadingProof
                            ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2))
                            : Icon(Icons.upload_file_outlined, size: 16, color: accent),
                        label: Text(
                          ticket['completion_proof_url'] == null
                              ? 'Upload Bukti Penyelesaian'
                              : 'Ganti Bukti Penyelesaian',
                          style: TextStyle(color: accent, fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: border),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Ajukan pengalihan
                      Text(
                        'Pengalihan Tiket',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: textPrimary),
                      ),
                      const SizedBox(height: 6),
                      if (ticket['transfer_requested'] == true)
                        Text(
                          'Pengalihan sudah diajukan, menunggu tindakan Admin.',
                          style: TextStyle(fontSize: 12, color: textMuted),
                        )
                      else
                        OutlinedButton.icon(
                          onPressed:
                          isRequestingTransfer ? null : showTransferDialog,
                          icon: isRequestingTransfer
                              ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.swap_horiz_rounded,
                              size: 16, color: Color(0xFFEF4444)),
                          label: const Text(
                            'Ajukan Pengalihan Tiket',
                            style: TextStyle(
                                color: Color(0xFFEF4444), fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFEF4444)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              // ── Rating & Feedback (User, tiket Closed) ──────────
              if (DummyAuthService.isUser() && selectedStatus == 'Closed') ...[
                const SizedBox(height: 10),
                _SectionCard(
                  title: 'Beri Rating',
                  isDark: isDark,
                  cardColor: cardColor,
                  border: border,
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                  child: (ticket['rating'] != null)
                      ? Row(
                    children: [
                      ...List.generate(5, (i) {
                        return Icon(
                          i < (ticket['rating'] as int)
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: const Color(0xFFF59E0B),
                          size: 22,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        'Terima kasih atas penilaianmu',
                        style: TextStyle(color: textMuted, fontSize: 12),
                      ),
                    ],
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Bagaimana penanganan tiket ini?',
                        style: TextStyle(color: textMuted, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (i) {
                          final starIndex = i + 1;
                          return IconButton(
                            onPressed: () {
                              setState(() => selectedRating = starIndex);
                            },
                            icon: Icon(
                              starIndex <= selectedRating
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: const Color(0xFFF59E0B),
                              size: 32,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: border, width: 1),
                        ),
                        child: TextField(
                          controller: feedbackController,
                          maxLines: 2,
                          style: TextStyle(
                              color: textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Feedback (opsional)...',
                            hintStyle: TextStyle(
                                color: textMuted, fontSize: 13),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed:
                          isSubmittingRating ? null : submitRating,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isSubmittingRating
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            'Kirim Rating',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13),
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
                    if (isLoadingComments)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    else if (comments.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Belum ada komentar',
                          style: TextStyle(color: textMuted, fontSize: 13),
                        ),
                      )
                    else
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
                        onPressed: isSendingComment ? null : addComment,
                        icon: isSendingComment
                            ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Icon(Icons.send_rounded, size: 16),
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
    const accent = Color(0xFF2563EB);
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
                title.toUpperCase(),
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
  final String Function(T) labelBuilder;
  final bool isDark;
  final Color border;
  final Color textPrimary;
  final Color textMuted;
  final ValueChanged<T?> onChanged;

  const _StyledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.labelBuilder,
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
                labelBuilder(item),
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