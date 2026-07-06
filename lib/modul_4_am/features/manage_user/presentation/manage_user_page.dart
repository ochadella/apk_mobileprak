import 'package:flutter/material.dart';
import '../../auth/data/dummy_auth_service.dart';

class ManageUserPage extends StatefulWidget {
  const ManageUserPage({super.key});

  @override
  State<ManageUserPage> createState() => _ManageUserPageState();
}

class _ManageUserPageState extends State<ManageUserPage> {
  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String selectedNewRole = 'User';
  bool obscurePassword = true;
  bool isCreating = false;
  bool showAddForm = false;

  List<UserAccount> users = [];
  bool isLoading = true;
  String? updatingUserId;
  String? updatingActiveId;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loadUsers() async {
    setState(() => isLoading = true);
    final data = await DummyAuthService.getUsers();
    if (!mounted) return;
    setState(() {
      users = data;
      isLoading = false;
    });
  }

  Future<void> addUser() async {
    final fullName = fullNameController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (fullName.isEmpty || username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 6 karakter')),
      );
      return;
    }

    setState(() => isCreating = true);

    final error = await DummyAuthService.createUserByAdmin(
      fullName: fullName,
      username: username,
      password: password,
      role: selectedNewRole,
    );

    if (!mounted) return;
    setState(() => isCreating = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User berhasil ditambahkan')),
      );
      fullNameController.clear();
      usernameController.clear();
      passwordController.clear();
      setState(() {
        selectedNewRole = 'User';
        showAddForm = false;
      });
      await loadUsers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  Future<void> changeRole(UserAccount user, String newRole) async {
    if (user.id == null || user.role == newRole) return;

    setState(() => updatingUserId = user.id);

    final success = await DummyAuthService.updateUserRole(user.id!, newRole);

    if (!mounted) return;
    setState(() => updatingUserId = null);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Role ${user.fullName} diubah jadi $newRole')),
      );
      await loadUsers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengubah role, coba lagi')),
      );
    }
  }

  Future<void> toggleActive(UserAccount user) async {
    if (user.id == null) return;

    setState(() => updatingActiveId = user.id);

    final newValue = !user.isActive;
    final success = await DummyAuthService.toggleUserActive(user.id!, newValue);

    if (!mounted) return;
    setState(() => updatingActiveId = null);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newValue
              ? '${user.fullName} diaktifkan kembali'
              : '${user.fullName} dinonaktifkan'),
        ),
      );
      await loadUsers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengubah status, coba lagi')),
      );
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'Admin':
        return const Color(0xFFEF4444);
      case 'Helpdesk':
        return const Color(0xFF0EA5E9);
      default:
        return const Color(0xFF10B981);
    }
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
              'Manage User',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: textPrimary,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => showAddForm = !showAddForm),
            icon: Icon(
              showAddForm ? Icons.close_rounded : Icons.person_add_rounded,
              color: accent,
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: loadUsers,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          children: [
            // ── Form Tambah User (collapsible) ──────────────────
            if (showAddForm) ...[
              Container(
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
                            'TAMBAH USER BARU',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: textMuted,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: fullNameController,
                      style: TextStyle(color: textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Nama lengkap',
                        hintStyle: TextStyle(color: textMuted, fontSize: 13),
                        filled: true,
                        fillColor: fieldBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: accent, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: usernameController,
                      style: TextStyle(color: textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Username',
                        hintStyle: TextStyle(color: textMuted, fontSize: 13),
                        filled: true,
                        fillColor: fieldBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: accent, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      style: TextStyle(color: textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Password (min. 6 karakter)',
                        hintStyle: TextStyle(color: textMuted, fontSize: 13),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                                  () => obscurePassword = !obscurePassword),
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
                          borderSide: BorderSide(color: border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: accent, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: fieldBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: border, width: 1),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedNewRole,
                          isExpanded: true,
                          dropdownColor:
                          isDark ? const Color(0xFF1E293B) : Colors.white,
                          style: TextStyle(color: textPrimary, fontSize: 14),
                          items: const ['User', 'Helpdesk', 'Admin']
                              .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(r),
                          ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedNewRole = value);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      height: 46,
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
                        onPressed: isCreating ? null : addUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isCreating
                            ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                            : const Text(
                          'Tambah User',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Section label ────────────────────────────────────
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
                  'DAFTAR PENGGUNA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: textMuted,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (users.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'Belum ada pengguna terdaftar',
                    style: TextStyle(color: textMuted, fontSize: 13),
                  ),
                ),
              )
            else
              ...users.map((user) {
                final roleColor = _roleColor(user.role);
                final isUpdating = updatingUserId == user.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border, width: 1),
                  ),
                  child: Opacity(
                    opacity: user.isActive ? 1.0 : 0.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: roleColor.withOpacity(0.15),
                              child: Text(
                                user.fullName.isNotEmpty
                                    ? user.fullName[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                    color: roleColor, fontWeight: FontWeight.w800),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.fullName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '@${user.username}${user.isActive ? '' : ' · Nonaktif'}',
                                    style: TextStyle(fontSize: 12, color: textMuted),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            isUpdating
                                ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                CircularProgressIndicator(strokeWidth: 2))
                                : Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: roleColor.withOpacity(isDark ? 0.18 : 0.10),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: user.role,
                                  dropdownColor: isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white,
                                  icon: Icon(Icons.keyboard_arrow_down_rounded,
                                      color: roleColor, size: 18),
                                  style: TextStyle(
                                    color: roleColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                  items: const ['User', 'Helpdesk', 'Admin']
                                      .map((r) => DropdownMenuItem(
                                    value: r,
                                    child: Text(r),
                                  ))
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != null) changeRole(user, value);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              user.isActive ? 'Status: Aktif' : 'Status: Nonaktif',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: user.isActive
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                              ),
                            ),
                            updatingActiveId == user.id
                                ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2))
                                : Switch(
                              value: user.isActive,
                              onChanged: (_) => toggleActive(user),
                              activeColor: accent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}