import 'package:hive/hive.dart';

class UserAccount {
  final String fullName;
  final String username;
  String password;
  final String role;

  UserAccount({
    required this.fullName,
    required this.username,
    required this.password,
    required this.role,
  });
}

class DummyAuthService {
  static final List<UserAccount> _users = [
    UserAccount(
      fullName: 'Administrator',
      username: 'admin',
      password: '123',
      role: 'Admin',
    ),
    UserAccount(
      fullName: 'Helpdesk Staff',
      username: 'helpdesk',
      password: '123',
      role: 'Helpdesk',
    ),
    UserAccount(
      fullName: 'User Biasa',
      username: 'user',
      password: '123',
      role: 'User',
    ),
  ];

  static UserAccount? currentUser;

  static Future<bool> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final user = _users.firstWhere(
            (u) => u.username == username && u.password == password,
      );

      currentUser = user;

      final box = Hive.box('appBox');
      box.put('token', 'fake-token-${user.username}');
      box.put('username', user.username);
      box.put('role', user.role);
      box.put('fullName', user.fullName);

      return true;
    } catch (_) {
      return false;
    }
  }

  static bool register({
    required String fullName,
    required String username,
    required String password,
  }) {
    final exists = _users.any((u) => u.username == username);
    if (exists) return false;

    _users.add(
      UserAccount(
        fullName: fullName,
        username: username,
        password: password,
        role: 'User',
      ),
    );

    return true;
  }

  static bool resetPassword({
    required String username,
    required String newPassword,
  }) {
    try {
      final user = _users.firstWhere((u) => u.username == username);
      user.password = newPassword;
      return true;
    } catch (_) {
      return false;
    }
  }

  static bool isLoggedIn() {
    final box = Hive.box('appBox');
    return box.get('token') != null;
  }

  static void restoreSession() {
    final box = Hive.box('appBox');
    final username = box.get('username');

    if (username == null) return;

    try {
      currentUser = _users.firstWhere((u) => u.username == username);
    } catch (_) {
      currentUser = null;
    }
  }

  static void logout() {
    final box = Hive.box('appBox');
    box.delete('token');
    box.delete('username');
    box.delete('role');
    box.delete('fullName');
    currentUser = null;
  }

  static bool isAdmin() => currentUser?.role == 'Admin';
  static bool isHelpdesk() => currentUser?.role == 'Helpdesk';
  static bool isUser() => currentUser?.role == 'User';

  static bool canManageTicket() => isAdmin() || isHelpdesk();
  static bool canAssign() => isAdmin();
  static bool canCreateTicket() => isUser();
}