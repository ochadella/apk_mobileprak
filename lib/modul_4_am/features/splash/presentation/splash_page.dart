import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/baboy_mascot.dart';
import '../../auth/data/dummy_auth_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () async {
      if (!mounted) return;

      if (DummyAuthService.isLoggedIn()) {
        await DummyAuthService.restoreSession();
        if (!mounted) return;

        if (DummyAuthService.currentUser != null) {
          Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Mascot Baboy ──────────────────────────────────
              const BaboyMascot(size: 84),

              const SizedBox(height: 22),

              const Text(
                'Selamat datang di Baboy!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Andalkan Baboy bila kamu butuh bantuan!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 48),

              // ── Loading indicator ─────────────────────────────
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white.withOpacity(0.72),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}