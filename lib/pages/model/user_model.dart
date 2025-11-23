// lib/model/user_model.dart

class UserModel {
  final int id;
  final String name;
  final String username;
  final String email;
  final String? password;
  final String? role;
  final String? subject;
  String? foto_profil_guru;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.password,
    this.role,
    this.subject,
    this.foto_profil_guru,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'],
      subject: json['subject'],
      foto_profil_guru: json['foto_profil_guru'],
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
      'foto_profil_guru': foto_profil_guru,
    };
  }
}