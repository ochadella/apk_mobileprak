import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../features/auth/data/dummy_auth_service.dart';

class NotificationService {
  static final ValueNotifier<List<Map<String, dynamic>>> notificationsNotifier =
  ValueNotifier([]);

  // Simpan siapa aja yang udah baca notifikasi apa: { userId: [id1, id2, ...] }
  static Map<String, List<String>> _readByUser = {};

  static void loadFromLocal() {
    final box = Hive.box('appBox');
    final data = box.get('notifications');
    final readData = box.get('notifications_read_by_user');

    if (readData != null) {
      try {
        _readByUser = (readData as Map).map(
              (key, value) => MapEntry(
            key.toString(),
            List<String>.from(value as List),
          ),
        );
      } catch (_) {
        _readByUser = {};
      }
    }

    if (data != null) {
      final list = List<Map<String, dynamic>>.from(
        (data as List).map((item) => Map<String, dynamic>.from(item)),
      );

      // Migrasi data lama yang belum punya 'id' unik
      bool needsMigration = false;
      for (var i = 0; i < list.length; i++) {
        if (list[i]['id'] == null) {
          list[i]['id'] = 'legacy_$i';
          needsMigration = true;
        }
      }

      notificationsNotifier.value = list;
      if (needsMigration) _saveToLocal();
    } else {
      notificationsNotifier.value = [
        {
          'id': 'welcome',
          'title': 'Selamat datang',
          'message': 'Aplikasi helpdesk siap digunakan.',
          'time': 'Baru saja',
          'ticketId': '',
        },
      ];
      _saveToLocal();
    }
  }

  static void _saveToLocal() {
    final box = Hive.box('appBox');
    box.put('notifications', notificationsNotifier.value);
    box.put('notifications_read_by_user', _readByUser);
  }

  static void addNotification({
    required String title,
    required String message,
    String ticketId = '',
  }) {
    final current = List<Map<String, dynamic>>.from(notificationsNotifier.value);
    final id = DateTime.now().microsecondsSinceEpoch.toString();

    current.insert(0, {
      'id': id,
      'title': title,
      'message': message,
      'time': 'Baru saja',
      'ticketId': ticketId,
    });

    notificationsNotifier.value = current;
    _saveToLocal();
  }

  /// Apakah notifikasi ini sudah dibaca oleh user yang SEDANG LOGIN sekarang
  static bool isReadByCurrentUser(String notificationId) {
    final userId = DummyAuthService.currentUser?.id;
    if (userId == null) return false;
    return (_readByUser[userId] ?? const []).contains(notificationId);
  }

  /// Tandai semua notifikasi sebagai sudah dibaca, KHUSUS untuk user yang login sekarang
  static void markAllAsRead() {
    final userId = DummyAuthService.currentUser?.id;
    if (userId == null) return;

    final allIds = notificationsNotifier.value
        .map((item) => item['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList();

    _readByUser[userId] = allIds;
    _saveToLocal();

    // Trigger rebuild di halaman yang dengerin notificationsNotifier
    notificationsNotifier.value =
    List<Map<String, dynamic>>.from(notificationsNotifier.value);
  }
}