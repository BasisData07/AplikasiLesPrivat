// lib/model/user_model.dart

class UserModel {
  final int id;
  final String name;
  final String username;
  final String email;
  final String? password;
  final String? role;
  final String? subject;
  
  // Hapus final agar bisa di-update langsung saat upload foto (sesuai kodingan profilmu)
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
      // 1. LOGIKA ID PINTAR: Cek segala kemungkinan nama ID dari backend
      id: json['id'] ?? json['user_id'] ?? json['guru_id'] ?? json['murid_id'] ?? 0,
      
      name: json['name'] ?? json['nama_lengkap'] ?? json['username'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'],
      subject: json['subject'],
      
      // 2. LOGIKA FOTO PINTAR: Cek 'foto_profil_guru' ATAU 'foto_profile_url'
      // Karena endpoint detail profil mengembalikan 'foto_profile_url', sedangkan login 'foto_profil_guru'
      foto_profil_guru: json['foto_profil_guru'] ?? json['foto_profile_url'],
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