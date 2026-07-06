import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../features/auth/data/dummy_auth_service.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> themeModeNotifier =
  ValueNotifier(ThemeMode.light);

  static bool get isDark => themeModeNotifier.value == ThemeMode.dark;

  /// Muat preferensi dark mode KHUSUS untuk user yang sedang login.
  /// Dipanggil setelah login sukses / restoreSession, biar tema gak
  /// "kebawa" dari akun lain yang sebelumnya login di device yang sama.
  static void loadForCurrentUser() {
    final userId = DummyAuthService.currentUser?.id;
    if (userId == null) {
      themeModeNotifier.value = ThemeMode.light;
      return;
    }

    try {
      final box = Hive.box('appBox');
      final saved = box.get('dark_mode_by_user');
      final map = saved is Map ? Map<String, dynamic>.from(saved) : {};
      final isDarkForUser = map[userId] == true;

      themeModeNotifier.value =
      isDarkForUser ? ThemeMode.dark : ThemeMode.light;
    } catch (_) {
      themeModeNotifier.value = ThemeMode.light;
    }
  }

  static void toggleTheme(bool value) {
    themeModeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;

    final userId = DummyAuthService.currentUser?.id;
    if (userId == null) return;

    try {
      final box = Hive.box('appBox');
      final saved = box.get('dark_mode_by_user');
      final map = saved is Map ? Map<String, dynamic>.from(saved) : {};
      map[userId] = value;
      box.put('dark_mode_by_user', map);
    } catch (_) {
      // gagal simpan preferensi, gapapa, tema tetep jalan untuk sesi ini
    }
  }

  /// Reset ke light mode, dipanggil pas logout biar gak "kebawa"
  /// ke halaman Login untuk akun berikutnya.
  static void resetToDefault() {
    themeModeNotifier.value = ThemeMode.light;
  }
}