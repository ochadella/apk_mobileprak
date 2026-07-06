import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../core/supabase/supabase_config.dart';

class UserAccount {
  final String? id;
  final String fullName;
  final String username;
  String password;
  final String role;
  final bool isActive;

  UserAccount({
    this.id,
    required this.fullName,
    required this.username,
    required this.password,
    required this.role,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'fullName': fullName,
      'username': username,
      'password': password,
      'role': role,
      'is_active': isActive,
    };
  }

  factory UserAccount.fromMap(Map map) {
    return UserAccount(
      id: map['id']?.toString(),
      fullName: map['fullName'] ?? map['full_name'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? 'User',
      isActive: map['is_active'] ?? true,
    );
  }
}

class DummyAuthService {
  static UserAccount? currentUser;

  static supabase.SupabaseClient get _client =>
      supabase.Supabase.instance.client;

  static Future<String?> login(String username, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: '$username@helpdesk.app',
        password: password,
      );

      final user = response.user;
      if (user == null) return 'Username atau password salah';

      final profile = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      // Cek apakah akun ini dinonaktifkan Admin
      if (profile['is_active'] == false) {
        await _client.auth.signOut();
        return 'Akun ini dinonaktifkan. Hubungi Admin untuk info lebih lanjut.';
      }

      currentUser = UserAccount(
        id: user.id,
        fullName: profile['full_name'],
        username: profile['username'],
        password: password,
        role: profile['role'],
        isActive: profile['is_active'] ?? true,
      );

      return null;
    } catch (e) {
      print('LOGIN ERROR: $e');
      return 'Username atau password salah';
    }
  }

  /// Cek apakah username sudah dipakai orang lain
  static Future<bool> usernameExists(String username) async {
    try {
      final existing = await _client
          .from('profiles')
          .select('id')
          .eq('username', username)
          .maybeSingle();
      return existing != null;
    } catch (e) {
      print('CHECK USERNAME ERROR: $e');
      return false;
    }
  }

  static Future<String?> register({
    required String fullName,
    required String username,
    required String password,
  }) async {
    try {
      // PENTING: pastikan gak ada sesi lama yang nyangkut sebelum
      // signUp baru. Kalau ada sesi aktif, signUp() bisa "reuse"
      // identitas sesi lama itu alih-alih bikin user beneran baru,
      // menyebabkan konflik id pas insert ke profiles.
      if (_client.auth.currentSession != null) {
        await _client.auth.signOut();
      }

      // Cek dulu apakah username sudah dipakai
      final existing = await _client
          .from('profiles')
          .select('id')
          .eq('username', username)
          .maybeSingle();

      if (existing != null) {
        return 'Username sudah dipakai, gunakan username lain';
      }

      final response = await _client.auth.signUp(
        email: '$username@helpdesk.app',
        password: password,
        data: {'full_name': fullName, 'username': username},
      );

      if (response.user == null) {
        return 'Gagal membuat akun. Coba lagi.';
      }

      return null;
    } catch (e) {
      print('REGISTER ERROR: $e');
      return e.toString();
    }
  }

  /// Ganti password saat user SUDAH LOGIN (dari halaman Profile)
  static Future<bool> resetPassword({
    required String username,
    required String newPassword,
  }) async {
    try {
      await _client.auth.updateUser(
        supabase.UserAttributes(password: newPassword),
      );
      return true;
    } catch (e) {
      print('RESET PASSWORD ERROR: $e');
      return false;
    }
  }

  /// Lupa password saat user BELUM LOGIN (dari halaman Login)
  /// Manggil Edge Function 'reset-password' yang jalan di server,
  /// bukan langsung ke Supabase Auth dari app (lebih aman).
  static Future<String?> forgotPassword({
    required String username,
    required String newPassword,
  }) async {
    try {
      final url = Uri.parse(
        '${SupabaseConfig.supabaseUrl}/functions/v1/reset-password',
      );

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${SupabaseConfig.anonKey}',
          'apikey': SupabaseConfig.anonKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return null; // null artinya sukses, gak ada error
      } else {
        return data['error'] ?? 'Gagal reset password';
      }
    } catch (e) {
      print('FORGOT PASSWORD ERROR: $e');
      return 'Terjadi kesalahan, coba lagi';
    }
  }

  static bool isLoggedIn() {
    return _client.auth.currentSession != null;
  }

  static Future<void> restoreSession() async {
    final session = _client.auth.currentSession;
    if (session == null) return;

    final userId = session.user.id;
    try {
      final profile = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      // Kalau ternyata akun ini dinonaktifkan pas lagi login, paksa logout
      if (profile['is_active'] == false) {
        await _client.auth.signOut();
        currentUser = null;
        return;
      }

      currentUser = UserAccount(
        id: userId,
        fullName: profile['full_name'],
        username: profile['username'],
        password: '',
        role: profile['role'],
        isActive: profile['is_active'] ?? true,
      );
    } catch (e) {
      print('RESTORE SESSION ERROR: $e');
      currentUser = null;
    }
  }

  static Future<void> logout() async {
    await _client.auth.signOut();
    currentUser = null;
  }

  static Future<List<UserAccount>> getUsers() async {
    try {
      final data = await _client.from('profiles').select();
      return (data as List).map((e) => UserAccount.fromMap(e)).toList();
    } catch (e) {
      print('GET USERS ERROR: $e');
      return [];
    }
  }

  static Future<void> saveUsers(List<UserAccount> users) async {
    for (final user in users) {
      if (user.id != null) {
        await _client
            .from('profiles')
            .update(user.toMap())
            .eq('id', user.id!);
      }
    }
  }

  /// Ubah role satu user spesifik (dipakai Admin di halaman Manage User)
  static Future<bool> updateUserRole(String userId, String newRole) async {
    try {
      await _client.from('profiles').update({'role': newRole}).eq('id', userId);
      return true;
    } catch (e) {
      print('UPDATE ROLE ERROR: $e');
      return false;
    }
  }

  /// Admin bikin akun baru langsung (lewat Edge Function, aman)
  static Future<String?> createUserByAdmin({
    required String fullName,
    required String username,
    required String password,
    required String role,
  }) async {
    try {
      final url = Uri.parse(
        '${SupabaseConfig.supabaseUrl}/functions/v1/admin-create-user',
      );

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${SupabaseConfig.anonKey}',
          'apikey': SupabaseConfig.anonKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fullName': fullName,
          'username': username,
          'password': password,
          'role': role,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return null;
      } else {
        return data['error'] ?? 'Gagal membuat user';
      }
    } catch (e) {
      print('CREATE USER BY ADMIN ERROR: $e');
      return 'Terjadi kesalahan, coba lagi';
    }
  }

  /// Admin non-aktifin atau aktifin kembali satu user
  static Future<bool> toggleUserActive(String userId, bool isActive) async {
    try {
      await _client.from('profiles').update({'is_active': isActive}).eq('id', userId);
      return true;
    } catch (e) {
      print('TOGGLE USER ACTIVE ERROR: $e');
      return false;
    }
  }

  static bool isAdmin() => currentUser?.role == 'Admin';
  static bool isHelpdesk() => currentUser?.role == 'Helpdesk';
  static bool isUser() => currentUser?.role == 'User';
  static bool canManageTicket() => isAdmin() || isHelpdesk();
  static bool canAssign() => isAdmin();
  static bool canCreateTicket() => isUser() || isHelpdesk() || isAdmin();
}