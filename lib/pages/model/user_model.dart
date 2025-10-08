class UserModel {
  String _name;
  String _username;
  String _email;
  String _password;
  String? _role;
  String? _subject;

  UserModel({
    required String name,
    required String username,
    required String email,
    required String password,
    String? role,
    String? subject,
  }) : _name = name,
       _username = username,
       _email = email,
       _password = password,
       _role = role,
       _subject = subject;

  // Getter
  String get name => _name;
  String get username => _username;
  String get email => _email;
  String get password => _password;
  String? get role => _role;
  String? get subject => _subject;

  // Setter
  set name(String value) => _name = value;
  set username(String value) => _username = value;
  set email(String value) => _email = value;
  set password(String value) => _password = value;
  set role(String? value) => _role = value;
  set subject(String? value) => _subject = value;

  @override
  String toString() {
    return "UserModel{name: $_name, username: $_username, email: $_email, role: $_role, subject: $_subject}";
  }
}
