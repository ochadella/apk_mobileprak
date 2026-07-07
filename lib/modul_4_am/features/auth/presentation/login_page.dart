import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/ticket_service.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/baboy_mascot.dart';
import '../data/dummy_auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool get isWeb => kIsWeb;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan password wajib diisi')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final error = await DummyAuthService.login(username, password);

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (error == null) {
      await TicketService.loadTickets();
      ThemeController.loadForCurrentUser();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF2563EB);
    const bg = Color(0xFFF8FAFC);
    const cardColor = Colors.white;
    const textPrimary = Color(0xFF0F172A);
    const textMuted = Color(0xFF64748B);
    const border = Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bg,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(top: -40, left: -30, child: _circle(120, Colors.white.withOpacity(0.06))),
            Positioned(bottom: 180, right: -50, child: _circle(150, Colors.white.withOpacity(0.04))),
            Positioned(bottom: -50, left: -20, child: _circle(100, Colors.white.withOpacity(0.05))),
            SafeArea(
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: isWeb ? 48 : 24, vertical: isWeb ? 32 : 20),
                  children: [
                    Center(
                      child: BaboyMascot(size: isWeb ? 100 : 88),
                    ),
                    SizedBox(height: isWeb ? 16 : 6),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: Container(
                        constraints: isWeb ? const BoxConstraints(maxWidth: 440) : null,
                        padding: isWeb
                            ? const EdgeInsets.fromLTRB(40, 40, 40, 36)
                            : const EdgeInsets.fromLTRB(20, 24, 20, 20),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: border, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 3,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: accent,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Masuk ke Akun',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: textPrimary,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Padding(
                              padding: EdgeInsets.only(left: 13),
                              child: Text(
                                'Baboy siap bantu selesaiin keluhanmu!',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(height: isWeb ? 32 : 22),
                            _FieldLabel(label: 'Username'),
                            SizedBox(height: isWeb ? 10 : 6),
                            TextField(
                              controller: usernameController,
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: isWeb ? 16 : 14,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Masukkan username',
                                hintStyle: const TextStyle(
                                    color: textMuted, fontSize: 13, fontWeight: FontWeight.w400),
                                prefixIcon: const Icon(
                                  Icons.person_outline_rounded,
                                  color: textMuted,
                                  size: 18,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: border, width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: border, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: accent, width: 1.5),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: isWeb ? 16 : 12, vertical: isWeb ? 18 : 14),
                              ),
                            ),
                            SizedBox(height: isWeb ? 24 : 16),
                            _FieldLabel(label: 'Password'),
                            const SizedBox(height: 6),
                            TextField(
                              controller: passwordController,
                              obscureText: obscurePassword,
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: isWeb ? 16 : 14,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Masukkan password',
                                hintStyle: const TextStyle(
                                    color: textMuted, fontSize: 13, fontWeight: FontWeight.w400),
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                  color: textMuted,
                                  size: 18,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      obscurePassword = !obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: textMuted,
                                    size: 18,
                                  ),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: border, width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: border, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: accent, width: 1.5),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: isWeb ? 16 : 12, vertical: isWeb ? 18 : 14),
                              ),
                            ),
                            SizedBox(height: isWeb ? 16 : 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.forgotPassword,
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                ),
                                child: Text(
                                  'Lupa Password?',
                                  style: TextStyle(
                                    color: accent,
                                    fontWeight: FontWeight.w600,
                                    fontSize: isWeb ? 14 : 13,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: isWeb ? 16 : 8),
                            Container(
                              width: double.infinity,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: accent.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: isLoading ? null : handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : const Text(
                                  'Masuk',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isWeb ? 32 : 20),
                    Center(
                      child: Wrap(
                        spacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Belum punya akun?',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isWeb ? 15 : 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.register);
                            },
                            child: Text(
                              'Daftar Sekarang',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isWeb ? 15 : 13,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isWeb ? 20 : 14),
                    Center(
                      child: Text(
                        'Daftar akun baru jika belum punya',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: isWeb ? 14 : 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF64748B),
        letterSpacing: 0.4,
      ),
    );
  }
}
