// lib/model/user_model.dart

class UserModel {
  final int id;
  final String name;
  final String username;
  final String email;
  final String? password;
  final String? role;
  final String? subject;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.password,
    this.role,
    this.subject,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'],
      subject: json['subject'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'role': role,
      'subject': subject,
    };
  }
}