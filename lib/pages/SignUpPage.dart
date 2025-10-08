import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model/user_model.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>(); // Tambahkan GlobalKey untuk validasi
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController =
      TextEditingController(); // Controller untuk username
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController(); // Controller untuk konfirmasi password

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _signUp() async {
    // Validasi form terlebih dahulu
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String name = _nameController.text.trim();
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String pass = _passwordController.text.trim();
    String confirmPass = _confirmPasswordController.text.trim();

    // Validasi tambahan jika password tidak cocok
    if (pass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password dan Konfirmasi Password tidak cocok!"),
        ),
      );
      return;
    }

    UserModel newUser = UserModel(
      name: name,
      username: username,
      email: email,
      password: pass,
    );

    final prefs = await SharedPreferences.getInstance();

    // Simpan user ke SharedPreferences
    await prefs.setString('name', newUser.name);
    await prefs.setString('username', newUser.username); // Simpan username
    await prefs.setString('email', newUser.email);
    await prefs.setString('password', newUser.password);
    // Kita set isLoggedIn menjadi false, karena user harus login dulu setelah daftar
    await prefs.setBool('isLoggedIn', false);

    print("✅ User disimpan ke SharedPreferences: $newUser");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Akun berhasil dibuat! Silakan login.")),
    );

    Navigator.pop(context); // Kembali ke halaman login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Akun")),
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 233, 152, 179),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            // Bungkus dengan widget Form
            key: _formKey,
            child: ListView(
              children: [
                Image.asset("assets/panda.png", height: 100),
                const SizedBox(height: 10),
                const Text(
                  "LES MANIA",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),

                // Field Nama Lengkap
                TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration("Nama Lengkap"),
                  validator: (value) =>
                      value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 12),

                // Field Username
                TextFormField(
                  controller: _usernameController,
                  decoration: _buildInputDecoration("Username"),
                  validator: (value) =>
                      value!.isEmpty ? 'Username tidak boleh kosong' : null,
                ),
                const SizedBox(height: 12),

                // Field Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration("Email"),
                  validator: (value) {
                    if (value!.isEmpty) return 'Email tidak boleh kosong';
                    if (!value.contains('@')) return 'Format email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Field Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _buildInputDecoration("Password").copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) =>
                      value!.length < 6 ? 'Password minimal 6 karakter' : null,
                ),
                const SizedBox(height: 12),

                // Field Konfirmasi Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: _buildInputDecoration("Konfirmasi Password")
                      .copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          ),
                        ),
                      ),
                  validator: (value) {
                    if (value!.isEmpty)
                      return 'Konfirmasi password tidak boleh kosong';
                    if (value != _passwordController.text)
                      return 'Password tidak cocok';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(233, 64, 137, 1),
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

  // Helper method untuk dekorasi TextField agar tidak berulang
  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
