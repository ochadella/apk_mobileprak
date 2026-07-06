import 'package:flutter/material.dart';
import '../data/dummy_auth_service.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> handleChangePassword() async {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi semua field')),
      );
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 6 karakter')),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi password tidak cocok')),
      );
      return;
    }

    setState(() => isLoading = true);

    final success = await DummyAuthService.resetPassword(
      username: DummyAuthService.currentUser?.username ?? '',
      newPassword: newPassword,
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil diubah')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengubah password, coba lagi')),
      );
    }
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
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
    final fieldBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    const accent = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textMuted),
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
              'Ganti Password',
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
            Positioned(
              top: -30,
              right: -40,
              child: _circle(100, Colors.blue.withOpacity(isDark ? 0.04 : 0.05)),
            ),
            Positioned(
              bottom: 100,
              left: -50,
              child: _circle(140, Colors.blue.withOpacity(isDark ? 0.03 : 0.04)),
            ),
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ganti Password',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Buat password baru untuk akunmu.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.72),
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.lock_reset_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

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
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: border, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                              'PASSWORD BARU',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: textMuted,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _FieldLabel(label: 'Password Baru', textMuted: textMuted),
                        const SizedBox(height: 6),
                        TextField(
                          controller: newPasswordController,
                          obscureText: obscureNewPassword,
                          style: TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: 'Minimal 6 karakter',
                            hintStyle: TextStyle(
                                color: textMuted,
                                fontSize: 13,
                                fontWeight: FontWeight.w400),
                            prefixIcon: Icon(Icons.lock_outline_rounded,
                                color: textMuted, size: 18),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscureNewPassword = !obscureNewPassword;
                                });
                              },
                              icon: Icon(
                                obscureNewPassword
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
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                          ),
                        ),

                        const SizedBox(height: 14),

                        _FieldLabel(
                            label: 'Konfirmasi Password', textMuted: textMuted),
                        const SizedBox(height: 6),
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: obscureConfirmPassword,
                          style: TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: 'Ulangi password baru',
                            hintStyle: TextStyle(
                                color: textMuted,
                                fontSize: 13,
                                fontWeight: FontWeight.w400),
                            prefixIcon: Icon(Icons.lock_outline_rounded,
                                color: textMuted, size: 18),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscureConfirmPassword =
                                  !obscureConfirmPassword;
                                });
                              },
                              icon: Icon(
                                obscureConfirmPassword
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
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                          ),
                        ),

                        const SizedBox(height: 20),

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
                            onPressed:
                            isLoading ? null : handleChangePassword,
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
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                                : const Text(
                              'Simpan Password Baru',
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
              ],
            ),
          ],
        ),
      ),
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