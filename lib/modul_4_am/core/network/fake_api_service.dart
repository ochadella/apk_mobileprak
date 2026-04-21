import 'package:dio/dio.dart';

class FakeApiService {
  FakeApiService._internal();

  static final FakeApiService instance = FakeApiService._internal();

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://fake-helpdesk.local/api',
      connectTimeout: const Duration(seconds: 3),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );

  final List<Map<String, String>> _users = [
    {
      'fullName': 'Administrator',
      'username': 'admin',
      'password': '123',
      'role': 'Admin',
    },
    {
      'fullName': 'Helpdesk Staff',
      'username': 'helpdesk',
      'password': '123',
      'role': 'Helpdesk',
    },
  ];

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    try {
      final user = _users.firstWhere(
            (u) => u['username'] == username && u['password'] == password,
      );

      return {
        'success': true,
        'token': 'fake_token_${user['username']}',
        'user': {
          'fullName': user['fullName'],
          'username': user['username'],
          'role': user['role'],
        },
      };
    } catch (_) {
      return {
        'success': false,
        'message': 'Username atau password salah',
      };
    }
  }
}