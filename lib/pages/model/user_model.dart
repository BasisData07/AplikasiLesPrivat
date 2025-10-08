// lib/pages/model/user_model.dart

class UserModel {
  String _name;
  String _username; // TAMBAHKAN INI
  String _email;
  String _password;
  String? _role;
  String? _subject;

  UserModel({
    required String name,
    required String username, // TAMBAHKAN INI
    required String email,
    required String password,
    String? role,
    String? subject,
  }) : _name = name,
       _username = username, // TAMBAHKAN INI
       _email = email,
       _password = password,
       _role = role,
       _subject = subject;

  // Getter
  String get name => _name;
  String get username => _username; // TAMBAHKAN INI
  String get email => _email;
  String get password => _password;
  String? get role => _role;
  String? get subject => _subject;

  // Setter
  set name(String value) => _name = value;
  set username(String value) => _username = value; // TAMBAHKAN INI
  set email(String value) => _email = value;
  set password(String value) => _password = value;
  set role(String? value) => _role = value;
  set subject(String? value) => _subject = value;

  @override
  String toString() {
    // Perbarui toString untuk debugging yang lebih mudah
    return "UserModel{name: $_name, username: $_username, email: $_email, role: $_role, subject: $_subject}";
  }
}
