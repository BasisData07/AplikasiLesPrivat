// SignUpPage.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model/user_model.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  // Controller baru untuk mata pelajaran
  final TextEditingController _subjectController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // PERUBAHAN: Menggunakan String untuk role, default 'murid'
  String _selectedRole = 'murid';

  static const Color mintHighlight = Color(0xFF3CB371);
  static const Color darkerMintButton = Color(0xFF2E8B57);

  @override
  void dispose() {
    // Pastikan semua controller di-dispose
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    String name = _nameController.text.trim();
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String pass = _passwordController.text.trim();
    // PERUBAHAN: Ambil data subject jika role adalah guru
    String? subject =
        _selectedRole == 'guru' ? _subjectController.text.trim() : null;

    // Simpan data ke SharedPreferences
    await prefs.setString('name', name);
    await prefs.setString('username', username);
    await prefs.setString('email', email);
    await prefs.setString('password', pass);
    await prefs.setString('role', _selectedRole);
    if (subject != null) {
      await prefs.setString('subject', subject);
    }
    await prefs.setBool('isLoggedIn', false);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Akun berhasil dibuat! Silakan login.")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Akun"),
        backgroundColor: mintHighlight,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(color: mintHighlight),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Image.asset("assets/panda.png", height: 80),
                const SizedBox(height: 10),
                const Text(
                  "PRIVATE AJA",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),

                // --- Dropdown untuk memilih peran (menggunakan String) ---
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: _buildInputDecoration("Daftar Sebagai"),
                  items: ['murid', 'guru'].map((String role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role == 'murid' ? 'Murid' : 'Guru'),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRole = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration("Nama Lengkap"),
                  validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _usernameController,
                  decoration: _buildInputDecoration("Username"),
                  validator: (v) => v!.isEmpty ? 'Username tidak boleh kosong' : null,
                ),
                const SizedBox(height: 12),

                // --- PERUBAHAN: Kolom Subject yang tampil kondisional ---
                if (_selectedRole == 'guru')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: TextFormField(
                      controller: _subjectController,
                      decoration: _buildInputDecoration("Mata Pelajaran yang Diajar"),
                      validator: (v) {
                        if (_selectedRole == 'guru' && (v == null || v.isEmpty)) {
                          return 'Mata pelajaran wajib diisi untuk guru';
                        }
                        return null;
                      },
                    ),
                  ),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration("Email"),
                  validator: (v) {
                    if (v!.isEmpty) return 'Email tidak boleh kosong';
                    if (!v.contains('@')) return 'Format email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _buildInputDecoration("Password").copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) => v!.length < 6 ? 'Password minimal 6 karakter' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: _buildInputDecoration("Konfirmasi Password").copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                  validator: (v) {
                    if (v!.isEmpty) return 'Konfirmasi password tidak boleh kosong';
                    if (v != _passwordController.text) return 'Password tidak cocok';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkerMintButton,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Daftar"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.white,
    );
  }
}