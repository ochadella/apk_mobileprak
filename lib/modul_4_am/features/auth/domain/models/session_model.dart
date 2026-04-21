class SessionModel {
  final String token;
  final String fullName;
  final String username;
  final String role;

  SessionModel({
    required this.token,
    required this.fullName,
    required this.username,
    required this.role,
  });

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      token: map['token'] ?? '',
      fullName: map['fullName'] ?? '',
      username: map['username'] ?? '',
      role: map['role'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'token': token,
      'fullName': fullName,
      'username': username,
      'role': role,
    };
  }
}