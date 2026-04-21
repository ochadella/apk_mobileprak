import '../../../core/network/fake_api_service.dart';
import '../../../core/storage/hive_service.dart';
import '../domain/models/session_model.dart';

class AuthRepository {
  AuthRepository._internal();

  static final AuthRepository instance = AuthRepository._internal();

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    final response = await FakeApiService.instance.login(
      username: username,
      password: password,
    );

    if (response['success'] == true) {
      final user = response['user'] as Map<String, dynamic>;

      final session = SessionModel(
        token: response['token'] ?? '',
        fullName: user['fullName'] ?? '',
        username: user['username'] ?? '',
        role: user['role'] ?? '',
      );

      await HiveService.authBox.put('session', session.toMap());
      return true;
    }

    return false;
  }

  bool get isLoggedIn => HiveService.authBox.get('session') != null;

  SessionModel? get currentSession {
    final data = HiveService.authBox.get('session');
    if (data == null) return null;
    return SessionModel.fromMap(Map<String, dynamic>.from(data));
  }

  Future<void> saveRegisteredUser({
    required String fullName,
    required String username,
    required String password,
  }) async {
    final users = List<Map<String, dynamic>>.from(
      HiveService.appBox.get('registered_users', defaultValue: []),
    );

    users.add({
      'fullName': fullName,
      'username': username,
      'password': password,
      'role': 'User',
    });

    await HiveService.appBox.put('registered_users', users);
  }

  bool usernameExists(String username) {
    final users = List<Map<String, dynamic>>.from(
      HiveService.appBox.get('registered_users', defaultValue: []),
    );

    return users.any((u) => u['username'] == username);
  }

  bool resetPassword({
    required String username,
    required String newPassword,
  }) {
    final users = List<Map<String, dynamic>>.from(
      HiveService.appBox.get('registered_users', defaultValue: []),
    );

    final index = users.indexWhere((u) => u['username'] == username);
    if (index == -1) return false;

    users[index]['password'] = newPassword;
    HiveService.appBox.put('registered_users', users);
    return true;
  }

  Future<void> logout() async {
    await HiveService.authBox.delete('session');
  }
}