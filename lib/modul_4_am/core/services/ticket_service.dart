import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'notification_service.dart';

class TicketService {
  static final ValueNotifier<List<Map<String, dynamic>>> ticketsNotifier =
  ValueNotifier([]);

  static List<Map<String, dynamic>> get tickets => ticketsNotifier.value;

  static supabase.SupabaseClient get _client =>
      supabase.Supabase.instance.client;

  static Future<void> loadTickets() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final profile = await _client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .single();
      final role = profile['role'];

      var query = _client
          .from('tickets')
          .select('''
            id, title, description, category, priority, status,
            reporter_id, assignee_id, attachment_url, created_at,
            rating, feedback, estimated_completion, completion_proof_url,
            transfer_requested, transfer_reason
          ''');

      if (role == 'User') {
        query = query.eq('reporter_id', userId);
      } else if (role == 'Helpdesk') {
        query = query.eq('assignee_id', userId);
      }

      final data = await query.order('created_at', ascending: false);

      final profiles = await _client.from('profiles').select('id, full_name, username');
      final profileMap = {
        for (final p in profiles) p['id']: p,
      };

      final tickets = (data as List).map((t) {
        final reporter = profileMap[t['reporter_id']];
        final assignee = profileMap[t['assignee_id']];

        return <String, dynamic>{
          'id': t['id'].toString(), // full UUID disimpan, dipakai buat query lanjutan
          'shortId': '#${t['id'].toString().substring(0, 8)}',
          'title': t['title'] ?? '',
          'status': _mapStatus(t['status']),
          'date': _formatDate(t['created_at']),
          'category': t['category'] ?? '',
          'priority': t['priority'] ?? 'Sedang',
          'reporter': reporter?['full_name'] ?? reporter?['username'] ?? '-',
          'reporter_id': t['reporter_id'],
          'description': t['description'] ?? '',
          'assignee': assignee?['full_name'] ?? assignee?['username'] ?? 'Belum di-assign',
          'assignee_id': t['assignee_id'],
          'attachment_url': t['attachment_url'],
          'rating': t['rating'],
          'feedback': t['feedback'],
          'estimated_completion': t['estimated_completion'],
          'completion_proof_url': t['completion_proof_url'],
          'transfer_requested': t['transfer_requested'],
          'transfer_reason': t['transfer_reason'],
          'tracking': _generateTracking(_mapStatus(t['status'])),
        };
      }).toList();

      ticketsNotifier.value = tickets;
    } catch (e) {
      print('LOAD TICKETS ERROR: $e');
    }
  }

  static String _mapStatus(String? status) {
    switch (status) {
      case 'Open':
        return 'Open';
      case 'Assigned':
        return 'Open';
      case 'In Progress':
        return 'On Progress';
      case 'Closed':
        return 'Closed';
      default:
        return 'Open';
    }
  }

  static String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return '-';
    }
  }

  static Future<bool> addTicket(Map<String, dynamic> ticket, {String? attachmentUrl}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      final response = await _client.from('tickets').insert({
        'title': ticket['title'],
        'description': ticket['description'],
        'category': ticket['category'],
        'priority': ticket['priority'],
        'status': 'Open',
        'reporter_id': userId,
        if (attachmentUrl != null) 'attachment_url': attachmentUrl,
      }).select();

      final newId = (response as List).first['id'].toString();

      // Catat histori pertama ke ticket_tracking
      try {
        await _client.from('ticket_tracking').insert({
          'ticket_id': newId,
          'status': 'Open',
          'note': 'Tiket dibuat',
          'changed_by': userId,
        });
      } catch (e) {
        print('INSERT TRACKING (create) ERROR: $e');
      }

      final newTicket = Map<String, dynamic>.from(ticket);
      newTicket['id'] = newId;
      newTicket['shortId'] = '#${newId.substring(0, 8)}';
      newTicket['reporter_id'] = userId;
      newTicket['assignee_id'] = null;

      final updated = List<Map<String, dynamic>>.from(ticketsNotifier.value);
      updated.insert(0, newTicket);
      ticketsNotifier.value = updated;

      NotificationService.addNotification(
        title: 'Tiket baru dibuat',
        message: '${newTicket['shortId']} - ${newTicket['title']}',
        ticketId: newId,
      );

      return true;
    } catch (e) {
      print('ADD TICKET ERROR: $e');
      return false;
    }
  }

  static Map<String, dynamic>? getTicketById(String id) {
    try {
      return ticketsNotifier.value.firstWhere((ticket) => ticket['id'] == id);
    } catch (_) {
      return null;
    }
  }

  /// Ambil daftar user dengan role Helpdesk YANG MASIH AKTIF, buat dropdown assign di Admin
  static Future<List<Map<String, dynamic>>> getHelpdeskUsers() async {
    try {
      final data = await _client
          .from('profiles')
          .select('id, full_name, username')
          .eq('role', 'Helpdesk')
          .eq('is_active', true);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('GET HELPDESK USERS ERROR: $e');
      return [];
    }
  }

  static Future<void> updateTicket({
    required String ticketId,
    required String status,
    String? assigneeId,
    required String assigneeName,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final updated = List<Map<String, dynamic>>.from(ticketsNotifier.value);
    final index = updated.indexWhere((ticket) => ticket['id'] == ticketId);
    if (index == -1) return;

    final oldTicket = Map<String, dynamic>.from(updated[index]);
    final oldStatus = oldTicket['status'] ?? 'Open';
    final oldAssignee = oldTicket['assignee'] ?? 'Belum di-assign';

    final newTicket = Map<String, dynamic>.from(oldTicket);
    newTicket['status'] = status;
    newTicket['assignee'] = assigneeName;
    if (assigneeId != null) newTicket['assignee_id'] = assigneeId;
    newTicket['tracking'] = _generateTracking(status);

    updated[index] = newTicket;
    ticketsNotifier.value = updated;

    try {
      final updateData = <String, dynamic>{
        'status': _unmapStatus(status),
      };
      if (assigneeId != null) {
        updateData['assignee_id'] = assigneeId;
      }
      await _client.from('tickets').update(updateData).eq('id', ticketId);

      // Catat histori perubahan status ke ticket_tracking
      if (oldStatus != status) {
        try {
          await _client.from('ticket_tracking').insert({
            'ticket_id': ticketId,
            'status': _unmapStatus(status),
            'note': 'Status diubah menjadi $status',
            'changed_by': userId,
          });
        } catch (e) {
          print('INSERT TRACKING (update) ERROR: $e');
        }
      }
    } catch (e) {
      print('UPDATE TICKET ERROR: $e');
    }

    if (oldStatus != status) {
      NotificationService.addNotification(
        title: 'Status tiket diperbarui',
        message: '${oldTicket['shortId'] ?? ticketId} berubah dari $oldStatus menjadi $status',
        ticketId: ticketId,
      );
    }

    if (assigneeName != oldAssignee) {
      NotificationService.addNotification(
        title: 'Tiket di-assign',
        message: '${oldTicket['shortId'] ?? ticketId} di-assign ke $assigneeName',
        ticketId: ticketId,
      );
    }
  }

  static String _unmapStatus(String status) {
    switch (status) {
      case 'Open':
        return 'Open';
      case 'On Progress':
        return 'In Progress';
      case 'Closed':
        return 'Closed';
      default:
        return 'Open';
    }
  }

  static List<Map<String, dynamic>> _generateTracking(String status) {
    if (status == 'Open') {
      return [
        {'title': 'Tiket Dibuat', 'time': 'Baru saja', 'done': true},
        {'title': 'Menunggu Penanganan', 'time': 'Baru saja', 'done': false},
        {'title': 'Diproses', 'time': '-', 'done': false},
        {'title': 'Selesai', 'time': '-', 'done': false},
      ];
    }

    if (status == 'On Progress') {
      return [
        {'title': 'Tiket Dibuat', 'time': 'Baru saja', 'done': true},
        {'title': 'Menunggu Penanganan', 'time': 'Baru saja', 'done': true},
        {'title': 'Diproses', 'time': 'Baru saja', 'done': true},
        {'title': 'Selesai', 'time': '-', 'done': false},
      ];
    }

    return [
      {'title': 'Tiket Dibuat', 'time': 'Baru saja', 'done': true},
      {'title': 'Menunggu Penanganan', 'time': 'Baru saja', 'done': true},
      {'title': 'Diproses', 'time': 'Baru saja', 'done': true},
      {'title': 'Selesai', 'time': 'Baru saja', 'done': true},
    ];
  }

  // ── Komentar (tersambung ke tabel ticket_comments) ────────────────

  static Future<List<Map<String, dynamic>>> loadComments(String ticketId) async {
    try {
      final data = await _client
          .from('ticket_comments')
          .select('id, message, created_at, user_id')
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: true);

      final comments = List<Map<String, dynamic>>.from(data);
      if (comments.isEmpty) return [];

      final userIds = comments.map((c) => c['user_id']).toSet().toList();
      final profiles = await _client
          .from('profiles')
          .select('id, full_name, username')
          .inFilter('id', userIds);

      final profileMap = {
        for (final p in profiles) p['id']: p,
      };

      return comments.map((c) {
        final user = profileMap[c['user_id']];
        return {
          'name': user?['full_name'] ?? user?['username'] ?? 'User',
          'message': c['message'] ?? '',
          'time': _formatTime(c['created_at']),
        };
      }).toList();
    } catch (e) {
      print('LOAD COMMENTS ERROR: $e');
      return [];
    }
  }

  static Future<bool> addComment({
    required String ticketId,
    required String message,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      await _client.from('ticket_comments').insert({
        'ticket_id': ticketId,
        'user_id': userId,
        'message': message,
      });
      return true;
    } catch (e) {
      print('ADD COMMENT ERROR: $e');
      return false;
    }
  }

  static String _formatTime(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final h = date.hour.toString().padLeft(2, '0');
      final m = date.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '-';
    }
  }

  /// Ambil histori tracking ASLI dari database (bukan hasil hitung ulang)
  static Future<List<Map<String, dynamic>>> loadTrackingHistory(String ticketId) async {
    try {
      final data = await _client
          .from('ticket_tracking')
          .select('status, note, created_at, changed_by')
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: true);

      final rows = List<Map<String, dynamic>>.from(data);
      if (rows.isEmpty) return [];

      final userIds = rows.map((r) => r['changed_by']).toSet().toList();
      final profiles = await _client
          .from('profiles')
          .select('id, full_name, username')
          .inFilter('id', userIds);
      final profileMap = {for (final p in profiles) p['id']: p};

      return rows.map((r) {
        final user = profileMap[r['changed_by']];
        return {
          'title': r['note'] ?? r['status'] ?? '-',
          'time': _formatDateTime(r['created_at']),
          'by': user?['full_name'] ?? user?['username'] ?? '-',
          'done': true,
        };
      }).toList();
    } catch (e) {
      print('LOAD TRACKING HISTORY ERROR: $e');
      return [];
    }
  }

  static String _formatDateTime(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      final h = date.hour.toString().padLeft(2, '0');
      final m = date.minute.toString().padLeft(2, '0');
      return '${date.day} ${months[date.month - 1]} • $h:$m';
    } catch (_) {
      return '-';
    }
  }

  /// User kasih rating & feedback setelah tiket Closed
  static Future<bool> submitRating({
    required String ticketId,
    required int rating,
    String? feedback,
  }) async {
    try {
      await _client.from('tickets').update({
        'rating': rating,
        'feedback': feedback,
      }).eq('id', ticketId);

      // Update juga di data lokal biar UI langsung ke-refresh
      final updated = List<Map<String, dynamic>>.from(ticketsNotifier.value);
      final index = updated.indexWhere((t) => t['id'] == ticketId);
      if (index != -1) {
        final newTicket = Map<String, dynamic>.from(updated[index]);
        newTicket['rating'] = rating;
        newTicket['feedback'] = feedback;
        updated[index] = newTicket;
        ticketsNotifier.value = updated;
      }

      return true;
    } catch (e) {
      print('SUBMIT RATING ERROR: $e');
      return false;
    }
  }

  /// Helpdesk set estimasi waktu penyelesaian tiket
  static Future<bool> setEstimatedCompletion({
    required String ticketId,
    required DateTime estimatedDate,
  }) async {
    try {
      await _client.from('tickets').update({
        'estimated_completion': estimatedDate.toIso8601String(),
      }).eq('id', ticketId);

      _updateLocalField(ticketId, 'estimated_completion', estimatedDate.toIso8601String());
      return true;
    } catch (e) {
      print('SET ESTIMATED COMPLETION ERROR: $e');
      return false;
    }
  }

  /// Helpdesk upload bukti penyelesaian (URL gambar dari Storage)
  static Future<bool> uploadCompletionProof({
    required String ticketId,
    required String proofUrl,
  }) async {
    try {
      await _client.from('tickets').update({
        'completion_proof_url': proofUrl,
      }).eq('id', ticketId);

      _updateLocalField(ticketId, 'completion_proof_url', proofUrl);
      return true;
    } catch (e) {
      print('UPLOAD COMPLETION PROOF ERROR: $e');
      return false;
    }
  }

  /// Helpdesk ajukan pengalihan tiket ke Admin (karena di luar keahliannya)
  static Future<bool> requestTransfer({
    required String ticketId,
    required String reason,
  }) async {
    try {
      await _client.from('tickets').update({
        'transfer_requested': true,
        'transfer_reason': reason,
      }).eq('id', ticketId);

      _updateLocalField(ticketId, 'transfer_requested', true);
      _updateLocalField(ticketId, 'transfer_reason', reason);

      NotificationService.addNotification(
        title: 'Pengajuan pengalihan tiket',
        message: 'Helpdesk mengajukan pengalihan: $reason',
        ticketId: ticketId,
      );

      return true;
    } catch (e) {
      print('REQUEST TRANSFER ERROR: $e');
      return false;
    }
  }

  /// Admin setujui atau tolak pengajuan pengalihan tiket dari Helpdesk
  static Future<bool> resolveTransferRequest({
    required String ticketId,
    required bool approved,
    String? newAssigneeId,
    String? newAssigneeName,
  }) async {
    try {
      final updateData = <String, dynamic>{'transfer_requested': false};
      if (approved && newAssigneeId != null) {
        updateData['assignee_id'] = newAssigneeId;
      }

      await _client.from('tickets').update(updateData).eq('id', ticketId);

      _updateLocalField(ticketId, 'transfer_requested', false);
      if (approved && newAssigneeId != null) {
        _updateLocalField(ticketId, 'assignee_id', newAssigneeId);
        _updateLocalField(ticketId, 'assignee', newAssigneeName);
      }

      NotificationService.addNotification(
        title: approved ? 'Pengalihan tiket disetujui' : 'Pengalihan tiket ditolak',
        message: approved
            ? 'Tiket dialihkan ke ${newAssigneeName ?? '-'}'
            : 'Admin menolak pengajuan pengalihan untuk tiket ini',
        ticketId: ticketId,
      );

      return true;
    } catch (e) {
      print('RESOLVE TRANSFER ERROR: $e');
      return false;
    }
  }

  /// Helper: update satu field di data lokal (ticketsNotifier) tanpa reload penuh
  static void _updateLocalField(String ticketId, String key, dynamic value) {
    final updated = List<Map<String, dynamic>>.from(ticketsNotifier.value);
    final index = updated.indexWhere((t) => t['id'] == ticketId);
    if (index != -1) {
      final newTicket = Map<String, dynamic>.from(updated[index]);
      newTicket[key] = value;
      updated[index] = newTicket;
      ticketsNotifier.value = updated;
    }
  }

  static int get totalCount => ticketsNotifier.value.length;

  /// Hitung jumlah tiket per kategori (buat dashboard analitik Admin)
  static Map<String, int> get countByCategory {
    final map = <String, int>{};
    for (final t in ticketsNotifier.value) {
      final cat = (t['category'] ?? 'Lainnya').toString();
      map[cat] = (map[cat] ?? 0) + 1;
    }
    return map;
  }

  /// Hitung jumlah tiket per prioritas (buat dashboard analitik Admin)
  static Map<String, int> get countByPriority {
    final map = <String, int>{};
    for (final t in ticketsNotifier.value) {
      final p = (t['priority'] ?? '-').toString();
      map[p] = (map[p] ?? 0) + 1;
    }
    return map;
  }

  /// Hitung berapa banyak tiket AKTIF (belum Closed) yang di-assign
  /// ke satu Helpdesk tertentu. Dipakai buat bantu Admin milih Helpdesk
  /// paling gak sibuk pas assign/pengalihan tiket.
  static int helpdeskActiveWorkload(String helpdeskId) {
    return ticketsNotifier.value
        .where((t) => t['assignee_id'] == helpdeskId && t['status'] != 'Closed')
        .length;
  }

  static int get openCount =>
      ticketsNotifier.value.where((t) => t['status'] == 'Open').length;

  static int get progressCount =>
      ticketsNotifier.value.where((t) => t['status'] == 'On Progress').length;

  static int get closedCount =>
      ticketsNotifier.value.where((t) => t['status'] == 'Closed').length;
}