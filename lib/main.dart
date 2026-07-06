import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'modul_4_am/core/routes/app_routes.dart';
import 'modul_4_am/core/services/notification_service.dart';
import 'modul_4_am/core/services/ticket_service.dart';
import 'modul_4_am/core/supabase/supabase_service.dart';
import 'modul_4_am/core/theme/theme_controller.dart';
import 'modul_4_am/features/auth/data/dummy_auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('appBox');

  await SupabaseService.initialize();

  // WAJIB: isi ulang currentUser dari sesi Supabase yang tersimpan,
  // biar role/nama user tetap kebaca meski app di-restart tanpa login ulang.
  await DummyAuthService.restoreSession();
  ThemeController.loadForCurrentUser();

  NotificationService.loadFromLocal();
  await TicketService.loadTickets();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor:
      isDark ? const Color(0xFF121212) : const Color(0xFFF6F4FA),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF7C6CF2),
        brightness: brightness,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF7C6CF2),
            width: 1.5,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7C6CF2),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'OchadellasProject',
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          themeMode: themeMode,
          initialRoute: AppRoutes.splash,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}