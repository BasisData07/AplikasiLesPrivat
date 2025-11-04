// lupa_password.dart
// VERSI TIDAK AMAN - Perbaikan Error

import 'package:flutter/material.dart';
// Ganti path ini jika 'auth_service.dart' Anda ada di folder lain
import 'services/auth_service.dart'; 

class LupaPassword extends StatefulWidget {
  const LupaPassword({super.key});

  @override
  State<LupaPassword> createState() => _LupaPasswordState();
}

class _LupaPasswordState extends State<LupaPassword> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'); // Regex ini tidak dipakai di sini, dipindah ke Form
  
  bool _isLoading = false;

  void _updatePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      
      String email = _emailController.text.trim();
      String newPassword = _newPasswordController.text.trim();
      String confirmPassword = _confirmPasswordController.text.trim();

      // Validasi apakah password baru dan konfirmasi sama
      if (newPassword != confirmPassword) {
        _showMessage('Password Baru dan Konfirmasi Password tidak cocok');
        return; // Hentikan proses
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Memanggil fungsi baru yang (tidak aman) dari AuthService
        final result = await AuthService.updatePasswordTanpaVerifikasi(email, newPassword);
        
        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          _showMessage('Password berhasil diperbarui. Silakan login.');
          // Kembali ke halaman login setelah 2 detik
          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) {
              Navigator.pop(context);
            }
          });
        } else {
          if (context.mounted) {
            _showMessage(result['message'] ?? 'Gagal memperbarui password');
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (context.mounted) {
          _showMessage('Error: $e');
        }
      }
    }
  }

  void _kembaliKeLogin() {
    Navigator.pop(context);
  }

  void _showMessage(String msg) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'), // Judul diubah
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _kembaliKeLogin,
        ),
      ),
      body: Center(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : isSmallScreen
                ? SingleChildScrollView(
                    child: Padding( // Tambah padding agar tidak mepet
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const _LupaPasswordLogo(),
                          _LupaPasswordForm(
                            formKey: _formKey,
                            emailController: _emailController,
                            newPasswordController: _newPasswordController,
                            confirmPasswordController: _confirmPasswordController,
                            onUpdatePassword: _updatePassword,
                            onKembali: _kembaliKeLogin,
                            isLoading: _isLoading,
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(32.0),
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Row(
                      children: [
                        const Expanded(child: _LupaPasswordLogo()),
                        Expanded(
                          child: Center(
                            child: _LupaPasswordForm(
                              formKey: _formKey,
                              emailController: _emailController,
                              newPasswordController: _newPasswordController,
                              confirmPasswordController: _confirmPasswordController,
                              onUpdatePassword: _updatePassword,
                              onKembali: _kembaliKeLogin,
                              isLoading: _isLoading,
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

// Logo tetap sama, tidak perlu diubah
class _LupaPasswordLogo extends StatelessWidget {
  const _LupaPasswordLogo();
  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/panda.png', height: isSmallScreen ? 100 : 150),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "LUPA PASSWORD",
            textAlign: TextAlign.center,
            style: isSmallScreen
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 20,
                    )
                : Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 24,
                    ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Reset password Anda dengan mudah",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
        ),
      ],
    );
  }
}


// Form diubah
class _LupaPasswordForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onUpdatePassword;
  final VoidCallback onKembali;
  final bool isLoading;

  const _LupaPasswordForm({
    required this.formKey,
    required this.emailController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.onUpdatePassword,
    required this.onKembali,
    required this.isLoading,
  });

  @override
  State<_LupaPasswordForm> createState() => __LupaPasswordFormState();
}

class __LupaPasswordFormState extends State<_LupaPasswordForm> {
  // Regex dipindah ke sini karena hanya dipakai di form ini
  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Form(
        key: widget.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ..._buildFormState(), // Hanya ada satu state (form)
            _gap(),
            // Footer
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                "Created by Kelompok 8",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFormState() {
    return [
      const Icon(
        Icons.lock_reset,
        size: 64,
        color: Colors.orange,
      ),
      _gap(),
      const Text(
        "Masukkan email dan password baru Anda",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
      _gap(),
      _gap(),
      
      // Field Email
      TextFormField(
        controller: widget.emailController,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Email harus diisi';
          }
          // Gunakan regex yang ada di class ini
          bool emailValid = _emailRegex.hasMatch(value); 
          if (!emailValid) {
            return 'Format email tidak valid';
          }
          return null;
        },
        decoration: const InputDecoration( // <-- Boleh const di sini
          labelText: 'Email',
          hintText: 'Masukkan email yang terdaftar',
          prefixIcon: Icon(Icons.email_outlined),
          border: OutlineInputBorder(),
        ),
      ),
      _gap(),
      
      // Field Password Baru
      TextFormField(
        controller: widget.newPasswordController,
        obscureText: !_isPasswordVisible,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Password baru harus diisi';
          }
          if (value.length < 6) {
            return 'Password minimal 6 karakter';
          }
          return null;
        },
        decoration: InputDecoration( // <-- Hapus 'const' dari sini
          labelText: 'Password Baru',
          hintText: 'Masukkan password baru',
          prefixIcon: const Icon(Icons.lock_outline_rounded),
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
      ),
      _gap(),

      // Field Konfirmasi Password Baru
      TextFormField(
        controller: widget.confirmPasswordController,
        obscureText: !_isConfirmPasswordVisible,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Konfirmasi password harus diisi';
          }
          if (value != widget.newPasswordController.text) {
            return 'Password tidak cocok';
          }
          return null;
        },
        decoration: InputDecoration( // <-- Hapus 'const' dari sini
          labelText: 'Konfirmasi Password Baru',
          hintText: 'Ketik ulang password baru',
          // PERBAIKAN ICON: ganti 'lock_check_outlined' jadi 'lock_outline'
          prefixIcon: const Icon(Icons.lock_outline), 
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(
              _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
          ),
        ),
      ),
      _gap(),
      _gap(),
      
      // Tombol Simpan
      SizedBox(
        width: double.infinity,
        child: widget.isLoading
            ? ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.withOpacity(0.6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('Menyimpan...'),
                  ],
                ),
              )
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: widget.onUpdatePassword, // Panggil fungsi update
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_outlined),
                    SizedBox(width: 8),
                    Text(
                      'Simpan Password Baru',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
      ),
      _gap(),
      
      TextButton(
        onPressed: widget.isLoading ? null : widget.onKembali,
        child: const Text(
          'Kembali ke Login',
          style: TextStyle(color: Colors.orange),
        ),
      ),
    ];
  }

  Widget _gap() => const SizedBox(height: 16);
}
