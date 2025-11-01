// login_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/user_model.dart';
import 'murid/home_page.dart';
import 'SignUpPage.dart';
import 'admin/admin_page.dart';
import 'guru/guru_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isLoggedIn') ?? false) {
      final user = UserModel(
        name: prefs.getString('name') ?? "",
        username: prefs.getString('username') ?? "",
        email: prefs.getString('email') ?? "",
        password: prefs.getString('password') ?? "",
        role: prefs.getString('role'),
        subject: prefs.getString('subject'),
      );
      if (user.email.isNotEmpty && context.mounted) {
        _navigateByUserRole(user);
      }
    }
  }

  void _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username == 'admin' && password == 'admin123') {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPage()),
        );
      }
      return;
    }

    if (username.isEmpty || password.isEmpty) {
      _showMessage("Email dan Password wajib diisi!");
      return;
    }
    if (!_emailRegex.hasMatch(username)) {
      _showMessage("Format email tidak valid!");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('email');
    String? savedPassword = prefs.getString('password');

    if (savedEmail == null) {
      _showMessage("Akun tidak ditemukan!");
      return;
    }
    if (savedEmail != username || savedPassword != password) {
      _showMessage("Email atau Password salah!");
      return;
    }

    await prefs.setBool('isLoggedIn', true);

    // ## INI BAGIAN YANG DIPERBAIKI ##
    // Kita menambahkan tanda seru (!) untuk meyakinkan Dart bahwa savedEmail
    // dan savedPassword tidak akan null di baris ini.
    final user = UserModel(
      name: prefs.getString('name') ?? "",
      username: prefs.getString('username') ?? "",
      email: savedEmail!, // <-- PERBAIKAN DI SINI
      password: savedPassword!, // <-- PERBAIKAN DI SINI
      role: prefs.getString('role'),
      subject: prefs.getString('subject'),
    );

    if (context.mounted) {
      _navigateByUserRole(user);
    }
  }

  void _navigateByUserRole(UserModel user) {
    if (user.role == 'guru') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GuruHomePage(user: user)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage(user: user)),
      );
    }
  }

  void _goToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpPage()),
    );
  }

  void _showMessage(String msg) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color mintBackground = Colors.orange;
    const Color darkerMintButton = Colors.orangeAccent;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: mintBackground),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/panda.png', height: 150),
                    const SizedBox(height: 10),
                    const Text(
                      "PRIVATE AJA",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _usernameController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkerMintButton,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Login'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _goToSignUp,
                      child: const Text(
                        'Belum punya akun? Daftar di sini',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  "Created by Kelompok 8",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
