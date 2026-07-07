import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../../core/widgets/baboy_mascot.dart';
import '../data/dummy_auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;
  bool isSubmitting = false;
  bool get isWeb => kIsWeb;

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String _friendlyError(String error) {
    final lower = error.toLowerCase();
    if (lower.contains('duplicate key') || lower.contains('profiles_pkey')) {
      return 'Akun ini sudah terdaftar. Coba login, atau tunggu sebentar lalu coba lagi.';
    }
    if (lower.contains('weak') || lower.contains('password should be')) {
      return 'Password terlalu lemah, minimal 6 karakter.';
    }
    if (lower.contains('network') || lower.contains('socket')) {
      return 'Koneksi bermasalah, coba lagi.';
    }
    return 'Gagal mendaftar, coba lagi dalam beberapa saat.';
  }

  Future<void> handleRegister() async {
    if (isSubmitting) return;

    if (nameController.text.isEmpty ||
        usernameController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi')),
      );
      return;
    }

    if (passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 6 karakter')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    final username = usernameController.text.trim();

    final exists = await DummyAuthService.usernameExists(username);
    if (!mounted) return;

    if (exists) {
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username sudah digunakan')),
      );
      return;
    }

    final error = await DummyAuthService.register(
      fullName: nameController.text.trim(),
      username: username,
      password: passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => isSubmitting = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_friendlyError(error))),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Register berhasil, silakan login')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary =
    isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textMuted =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final fieldBg =
    isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    const accent = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white70 : Colors.black54),
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
              'Daftar Akun',
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: bg,
        child: Stack(
          children: [
            Positioned(top: -30, right: -40, child: _circle(100, Colors.blue.withOpacity(isDark ? 0.04 : 0.05))),
            Positioned(bottom: 100, left: -50, child: _circle(140, Colors.blue.withOpacity(isDark ? 0.03 : 0.04))),
            ListView(
              padding: EdgeInsets.fromLTRB(isWeb ? 48 : 16, isWeb ? 24 : 8, isWeb ? 48 : 16, 24),
              children: [
                Center(
                  child: BaboyMascot(size: isWeb ? 100 : 84),
                ),
                SizedBox(height: isWeb ? 16 : 4),
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
                    padding: isWeb
                        ? const EdgeInsets.fromLTRB(40, 36, 40, 32)
                        : const EdgeInsets.fromLTRB(16, 20, 16, 18),
                    constraints: isWeb ? const BoxConstraints(maxWidth: 480) : null,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: border, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
                          blurRadius: 20,
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
                              height: 18,
                              decoration: BoxDecoration(
                                color: accent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Buat Akun Baru',
                              style: TextStyle(
                                fontSize: isWeb ? 22 : 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 13),
                          child: Text(
                            'Daftarkan akun untuk menggunakan aplikasi Baboy.',
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ),
                        SizedBox(height: isWeb ? 32 : 20),
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
                              'INFORMASI AKUN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: textMuted,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isWeb ? 24 : 16),

                        _FieldLabel(label: 'Nama Lengkap', textMuted: textMuted),
                        SizedBox(height: isWeb ? 10 : 6),
                        _StyledTextField(
                          controller: nameController,
                          hintText: 'Masukkan nama lengkap',
                          prefixIcon: Icons.badge_outlined,
                          fieldBg: fieldBg,
                          border: border,
                          textPrimary: textPrimary,
                          textMuted: textMuted,
                          isWeb: isWeb,
                        ),

                        SizedBox(height: isWeb ? 22 : 14),

                        _FieldLabel(label: 'Username', textMuted: textMuted),
                        SizedBox(height: isWeb ? 10 : 6),
                        _StyledTextField(
                          controller: usernameController,
                          hintText: 'Masukkan username',
                          prefixIcon: Icons.person_outline_rounded,
                          fieldBg: fieldBg,
                          border: border,
                          textPrimary: textPrimary,
                          textMuted: textMuted,
                          isWeb: isWeb,
                        ),

                        SizedBox(height: isWeb ? 22 : 14),

                        _FieldLabel(label: 'Password', textMuted: textMuted),
                        SizedBox(height: isWeb ? 10 : 6),
                        TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Minimal 6 karakter',
                            hintStyle: TextStyle(
                              color: textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: Icon(
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
                            fillColor: fieldBg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: border, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: border, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              const BorderSide(color: accent, width: 1.5),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: isWeb ? 16 : 12, vertical: isWeb ? 18 : 14),
                          ),
                        ),

                        SizedBox(height: isWeb ? 32 : 22),

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
                            onPressed: isSubmitting ? null : handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                                : const Text(
                              'Daftar Sekarang',
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

                SizedBox(height: isWeb ? 24 : 16),

                Center(
                  child: Wrap(
                    spacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Sudah punya akun?',
                        style: TextStyle(
                          color: textMuted,
                          fontSize: isWeb ? 15 : 13,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          'Masuk di sini',
                          style: TextStyle(
                            color: accent,
                            fontSize: isWeb ? 15 : 13,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
  final Color textMuted;
  const _FieldLabel({required this.label, required this.textMuted});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: textMuted,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final Color fieldBg;
  final Color border;
  final Color textPrimary;
  final Color textMuted;
  final bool isWeb;

  const _StyledTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.fieldBg,
    required this.border,
    required this.textPrimary,
    required this.textMuted,
    this.isWeb = false,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF2563EB);
    return TextField(
      controller: controller,
      style: TextStyle(
        color: textPrimary,
        fontSize: isWeb ? 16 : 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(prefixIcon, color: textMuted, size: isWeb ? 22 : 18),
        filled: true,
        fillColor: fieldBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        contentPadding:
        EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12, vertical: isWeb ? 18 : 14),
      ),
    );
  }
}
