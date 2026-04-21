import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class NotificationService {
  static final ValueNotifier<List<Map<String, dynamic>>> notificationsNotifier =
  ValueNotifier([]);

  static void loadFromLocal() {
    final box = Hive.box('appBox');
    final data = box.get('notifications');

    if (data != null) {
      notificationsNotifier.value = List<Map<String, dynamic>>.from(
        (data as List).map((item) => Map<String, dynamic>.from(item)),
      );
    } else {
      notificationsNotifier.value = [
        {
          'title': 'Selamat datang',
          'message': 'Aplikasi helpdesk siap digunakan.',
          'time': 'Baru saja',
          'unread': true,
          'ticketId': '',
        },
      ];

      _saveToLocal();
    }
  }

  static void _saveToLocal() {
    final box = Hive.box('appBox');
    box.put('notifications', notificationsNotifier.value);
  }

  static void addNotification({
    required String title,
    required String message,
    String ticketId = '',
  }) {
    final current = List<Map<String, dynamic>>.from(notificationsNotifier.value);

    current.insert(0, {
      'title': title,
      'message': message,
      'time': 'Baru saja',
      'unread': true,
      'ticketId': ticketId,
    });

    notificationsNotifier.value = current;
    _saveToLocal();
  }

  static void markAllAsRead() {
    final updated = notificationsNotifier.value.map((item) {
      return {
        ...item,
        'unread': false,
      };
    }).toList();

    notificationsNotifier.value = updated;
    _saveToLocal();
  }
}