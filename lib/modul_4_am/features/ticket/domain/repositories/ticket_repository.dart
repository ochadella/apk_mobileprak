import 'package:flutter/foundation.dart';
import '../../../../modul_4_am/core/services/notification_service.dart';
import '../../../../modul_4_am/core/storage/hive_service.dart';
import '../models/ticket_model.dart';

class TicketRepository {
  TicketRepository._internal();

  static final TicketRepository instance = TicketRepository._internal();

  final ValueNotifier<List<TicketModel>> ticketsNotifier = ValueNotifier([]);

  Future<void> init() async {
    final saved = HiveService.appBox.get('tickets');

    if (saved == null) {
      final seeded = _seedTickets();
      await HiveService.appBox.put(
        'tickets',
        seeded.map((e) => e.toMap()).toList(),
      );
      ticketsNotifier.value = seeded;
    } else {
      final tickets = List<Map<String, dynamic>>.from(saved)
          .map((e) => TicketModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();

      ticketsNotifier.value = tickets;
    }
  }

  List<TicketModel> get tickets => ticketsNotifier.value;

  TicketModel? getById(String id) {
    try {
      return ticketsNotifier.value.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addTicket(TicketModel ticket) async {
    final updated = List<TicketModel>.from(ticketsNotifier.value);
    updated.insert(0, ticket);
    ticketsNotifier.value = updated;
    await _persist();

    NotificationService.addNotification(
      title: 'Tiket baru dibuat',
      message: '${ticket.id} - ${ticket.title}',
      ticketId: ticket.id,
    );
  }

  Future<void> updateTicket({
    required String ticketId,
    required String status,
    required String assignee,
  }) async {
    final updated = List<TicketModel>.from(ticketsNotifier.value);
    final index = updated.indexWhere((t) => t.id == ticketId);
    if (index == -1) return;

    final old = updated[index];

    final newTicket = old.copyWith(
      status: status,
      assignee: assignee,
      tracking: _generateTracking(status),
    );

    updated[index] = newTicket;
    ticketsNotifier.value = updated;
    await _persist();

    if (old.status != status) {
      NotificationService.addNotification(
        title: 'Status tiket diperbarui',
        message: '$ticketId berubah dari ${old.status} menjadi $status',
        ticketId: ticketId,
      );
    }

    if (old.assignee != assignee) {
      NotificationService.addNotification(
        title: 'Tiket di-assign',
        message: '$ticketId di-assign ke $assignee',
        ticketId: ticketId,
      );
    }
  }

  int get totalCount => ticketsNotifier.value.length;
  int get openCount =>
      ticketsNotifier.value.where((t) => t.status == 'Open').length;
  int get progressCount =>
      ticketsNotifier.value.where((t) => t.status == 'On Progress').length;
  int get closedCount =>
      ticketsNotifier.value.where((t) => t.status == 'Closed').length;

  Future<void> _persist() async {
    await HiveService.appBox.put(
      'tickets',
      ticketsNotifier.value.map((e) => e.toMap()).toList(),
    );
  }

  List<Map<String, dynamic>> _generateTracking(String status) {
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

  List<TicketModel> _seedTickets() {
    return [
      TicketModel(
        id: '#HD-001',
        title: 'Internet Lab Lambat',
        status: 'Open',
        date: '17 Apr 2026',
        category: 'Jaringan',
        priority: 'Sedang',
        reporter: 'Ocha',
        description:
        'Koneksi internet di laboratorium sangat lambat sejak pagi dan mengganggu proses praktikum.',
        assignee: 'Belum di-assign',
        tracking: [
          {'title': 'Tiket Dibuat', 'time': '17 Apr 2026 - 08:00', 'done': true},
          {'title': 'Menunggu Penanganan', 'time': '17 Apr 2026 - 08:10', 'done': false},
          {'title': 'Diproses', 'time': '-', 'done': false},
          {'title': 'Selesai', 'time': '-', 'done': false},
        ],
      ),
      TicketModel(
        id: '#HD-002',
        title: 'Printer Ruang Admin Rusak',
        status: 'On Progress',
        date: '16 Apr 2026',
        category: 'Perangkat',
        priority: 'Tinggi',
        reporter: 'Rina',
        description:
        'Printer di ruang admin tidak bisa mencetak dan lampu indikator berkedip merah.',
        assignee: 'Helpdesk A',
        tracking: [
          {'title': 'Tiket Dibuat', 'time': '16 Apr 2026 - 09:00', 'done': true},
          {'title': 'Menunggu Penanganan', 'time': '16 Apr 2026 - 09:10', 'done': true},
          {'title': 'Diproses', 'time': '16 Apr 2026 - 10:00', 'done': true},
          {'title': 'Selesai', 'time': '-', 'done': false},
        ],
      ),
      TicketModel(
        id: '#HD-003',
        title: 'Akun Tidak Bisa Login',
        status: 'Closed',
        date: '15 Apr 2026',
        category: 'Akun',
        priority: 'Sedang',
        reporter: 'Budi',
        description:
        'User tidak bisa login ke sistem akademik karena password selalu dianggap salah.',
        assignee: 'Helpdesk B',
        tracking: [
          {'title': 'Tiket Dibuat', 'time': '15 Apr 2026 - 07:30', 'done': true},
          {'title': 'Menunggu Penanganan', 'time': '15 Apr 2026 - 07:40', 'done': true},
          {'title': 'Diproses', 'time': '15 Apr 2026 - 08:15', 'done': true},
          {'title': 'Selesai', 'time': '15 Apr 2026 - 09:00', 'done': true},
        ],
      ),
    ];
  }
}