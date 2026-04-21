import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../features/ticket/data/repositories/ticket_repository.dart';
import 'notification_service.dart';

class TicketService {
  static final ValueNotifier<List<Map<String, dynamic>>> ticketsNotifier =
  ValueNotifier([]);

  static List<Map<String, dynamic>> get tickets => ticketsNotifier.value;

  static void loadFromLocal() {
    final box = Hive.box('appBox');
    final data = box.get('tickets');

    if (data != null) {
      ticketsNotifier.value = List<Map<String, dynamic>>.from(
        (data as List).map((item) => Map<String, dynamic>.from(item)),
      );
    } else {
      ticketsNotifier.value = [
        {
          'id': '#HD-001',
          'title': 'Internet Lab Lambat',
          'status': 'Open',
          'date': '17 Apr 2026',
          'category': 'Jaringan',
          'priority': 'Sedang',
          'reporter': 'Ocha',
          'description':
          'Koneksi internet di laboratorium sangat lambat sejak pagi dan mengganggu proses praktikum.',
          'assignee': 'Belum di-assign',
          'tracking': [
            {
              'title': 'Tiket Dibuat',
              'time': '17 Apr 2026 - 08:00',
              'done': true,
            },
            {
              'title': 'Menunggu Penanganan',
              'time': '17 Apr 2026 - 08:10',
              'done': false,
            },
            {'title': 'Diproses', 'time': '-', 'done': false},
            {'title': 'Selesai', 'time': '-', 'done': false},
          ],
        },
        {
          'id': '#HD-002',
          'title': 'Printer Ruang Admin Rusak',
          'status': 'On Progress',
          'date': '16 Apr 2026',
          'category': 'Perangkat',
          'priority': 'Tinggi',
          'reporter': 'Rina',
          'description':
          'Printer di ruang admin tidak bisa mencetak dan lampu indikator berkedip merah.',
          'assignee': 'Helpdesk A',
          'tracking': [
            {
              'title': 'Tiket Dibuat',
              'time': '16 Apr 2026 - 09:00',
              'done': true,
            },
            {
              'title': 'Menunggu Penanganan',
              'time': '16 Apr 2026 - 09:10',
              'done': true,
            },
            {
              'title': 'Diproses',
              'time': '16 Apr 2026 - 10:00',
              'done': true,
            },
            {'title': 'Selesai', 'time': '-', 'done': false},
          ],
        },
        {
          'id': '#HD-003',
          'title': 'Akun Tidak Bisa Login',
          'status': 'Closed',
          'date': '15 Apr 2026',
          'category': 'Akun',
          'priority': 'Sedang',
          'reporter': 'Budi',
          'description':
          'User tidak bisa login ke sistem akademik karena password selalu dianggap salah.',
          'assignee': 'Helpdesk B',
          'tracking': [
            {
              'title': 'Tiket Dibuat',
              'time': '15 Apr 2026 - 07:30',
              'done': true,
            },
            {
              'title': 'Menunggu Penanganan',
              'time': '15 Apr 2026 - 07:40',
              'done': true,
            },
            {
              'title': 'Diproses',
              'time': '15 Apr 2026 - 08:15',
              'done': true,
            },
            {
              'title': 'Selesai',
              'time': '15 Apr 2026 - 09:00',
              'done': true,
            },
          ],
        },
      ];

      _saveToLocal();
    }
  }

  static void _saveToLocal() {
    final box = Hive.box('appBox');
    box.put('tickets', ticketsNotifier.value);
  }

  static Future<void> fetchFromApi() async {
    final repository = TicketRepository();

    try {
      final data = await repository.getTickets();

      final apiTickets = data.take(3).map((e) {
        return {
          'id': '#API-${e['id']}',
          'title': e['title']?.toString() ?? 'Untitled',
          'status': 'Open',
          'date': 'API',
          'category': 'Jaringan',
          'priority': 'Sedang',
          'reporter': 'API',
          'description': e['description']?.toString() ?? '-',
          'assignee': 'Belum di-assign',
          'tracking': [
            {'title': 'Tiket Dibuat', 'time': 'API', 'done': true},
            {'title': 'Menunggu Penanganan', 'time': '-', 'done': false},
            {'title': 'Diproses', 'time': '-', 'done': false},
            {'title': 'Selesai', 'time': '-', 'done': false},
          ],
        };
      }).toList();

      final current = List<Map<String, dynamic>>.from(ticketsNotifier.value);
      final existingIds = current.map((e) => e['id']).toSet();

      for (final ticket in apiTickets) {
        if (!existingIds.contains(ticket['id'])) {
          current.add(ticket);
        }
      }

      ticketsNotifier.value = current;
      _saveToLocal();
    } catch (_) {
      // biarin fallback ke local data
    }
  }

  static void addTicket(Map<String, dynamic> ticket) {
    final updated = List<Map<String, dynamic>>.from(ticketsNotifier.value);
    updated.insert(0, ticket);
    ticketsNotifier.value = updated;

    _saveToLocal();

    NotificationService.addNotification(
      title: 'Tiket baru dibuat',
      message: '${ticket['id']} - ${ticket['title']}',
      ticketId: ticket['id'] ?? '',
    );
  }

  static Map<String, dynamic>? getTicketById(String id) {
    try {
      return ticketsNotifier.value.firstWhere((ticket) => ticket['id'] == id);
    } catch (_) {
      return null;
    }
  }

  static void updateTicket({
    required String ticketId,
    required String status,
    required String assignee,
  }) {
    final updated = List<Map<String, dynamic>>.from(ticketsNotifier.value);

    final index = updated.indexWhere((ticket) => ticket['id'] == ticketId);
    if (index == -1) return;

    final oldTicket = Map<String, dynamic>.from(updated[index]);
    final oldStatus = oldTicket['status'] ?? 'Open';

    final newTicket = Map<String, dynamic>.from(oldTicket);
    newTicket['status'] = status;
    newTicket['assignee'] = assignee;
    newTicket['tracking'] = _generateTracking(status);

    updated[index] = newTicket;
    ticketsNotifier.value = updated;

    _saveToLocal();

    if (oldStatus != status) {
      NotificationService.addNotification(
        title: 'Status tiket diperbarui',
        message: '$ticketId berubah dari $oldStatus menjadi $status',
        ticketId: ticketId,
      );
    }

    if (assignee != (oldTicket['assignee'] ?? 'Belum di-assign')) {
      NotificationService.addNotification(
        title: 'Tiket di-assign',
        message: '$ticketId di-assign ke $assignee',
        ticketId: ticketId,
      );
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

  static int get totalCount => ticketsNotifier.value.length;

  static int get openCount =>
      ticketsNotifier.value.where((t) => t['status'] == 'Open').length;

  static int get progressCount =>
      ticketsNotifier.value.where((t) => t['status'] == 'On Progress').length;

  static int get closedCount =>
      ticketsNotifier.value.where((t) => t['status'] == 'Closed').length;
}