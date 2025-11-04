// lupa_password_page.dart

import 'package:flutter/material.dart';
import 'package:PRIVATE_AJA/services/auth_service.dart';

class LupaPassword extends StatefulWidget {
  const LupaPassword({super.key});

  @override
  State<LupaPassword> createState() => _LupaPasswordState();
}

class _LupaPasswordState extends State<LupaPassword> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  
  bool _isLoading = false;
  bool _emailSent = false;

  void _resetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      String email = _emailController.text.trim();

      try {
        final result = await AuthService.lupaPassword(email);
        
        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          setState(() {
            _emailSent = true;
          });
        } else {
          if (context.mounted) {
            _showMessage(result['message'] ?? 'Gagal mengirim email reset password');
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
        title: const Text('Lupa Password'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _kembaliKeLogin,
        ),
      ),
      body: Center(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : isSmallScreen
                ? SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _LupaPasswordLogo(),
                        _LupaPasswordForm(
                          formKey: _formKey,
                          emailController: _emailController,
                          onResetPassword: _resetPassword,
                          onKembali: _kembaliKeLogin,
                          isLoading: _isLoading,
                          emailSent: _emailSent,
                        ),
                      ],
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
                              onResetPassword: _resetPassword,
                              onKembali: _kembaliKeLogin,
                              isLoading: _isLoading,
                              emailSent: _emailSent,
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

class _LupaPasswordForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final VoidCallback onResetPassword;
  final VoidCallback onKembali;
  final bool isLoading;
  final bool emailSent;

  const _LupaPasswordForm({
    required this.formKey,
    required this.emailController,
    required this.onResetPassword,
    required this.onKembali,
    required this.isLoading,
    required this.emailSent,
  });

  @override
  State<_LupaPasswordForm> createState() => __LupaPasswordFormState();
}

class __LupaPasswordFormState extends State<_LupaPasswordForm> {
  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

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
            if (widget.emailSent) ..._buildSuccessState(),
            if (!widget.emailSent) ..._buildFormState(),
            
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
        "Masukkan email Anda untuk mereset password",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
      _gap(),
      _gap(),
      
      TextFormField(
        controller: widget.emailController,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Email harus diisi';
          }
          bool emailValid = _emailRegex.hasMatch(value);
          if (!emailValid) {
            return 'Format email tidak valid';
          }
          return null;
        },
        decoration: const InputDecoration(
          labelText: 'Email',
          hintText: 'Masukkan email yang terdaftar',
          prefixIcon: Icon(Icons.email_outlined),
          border: OutlineInputBorder(),
        ),
      ),
      _gap(),
      _gap(),
      
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
                    Text('Mengirim...'),
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
                onPressed: widget.onResetPassword,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send_outlined),
                    SizedBox(width: 8),
                    Text(
                      'Kirim Link Reset',
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

  List<Widget> _buildSuccessState() {
    return [
      const Icon(
        Icons.mark_email_read_outlined,
        size: 80,
        color: Colors.green,
      ),
      _gap(),
      const Text(
        "Email Terkirim!",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
      _gap(),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          "Kami telah mengirim link reset password ke email Anda. "
          "Silakan cek inbox email dan ikuti instruksi untuk membuat password baru.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            height: 1.5,
          ),
        ),
      ),
      _gap(),
      _gap(),
      
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: widget.onKembali,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline),
              SizedBox(width: 8),
              Text(
                'Kembali ke Login',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      _gap(),
      
      TextButton(
        onPressed: () {
          setState(() {
            // Reset state untuk mengirim ulang
          });
        },
        child: const Text(
          'Kirim ulang email',
          style: TextStyle(color: Colors.orange),
        ),
      ),
    ];
  }

  Widget _gap() => const SizedBox(height: 16);
}