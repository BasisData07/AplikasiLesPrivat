// login_page.dart

import 'dart:convert';
import 'package:PRIVATE_AJA/lupa_password.dart';
import 'package:PRIVATE_AJA/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/model/user_model.dart';
import 'pages/murid/home_page.dart';
import 'SignUpPage.dart';
import 'pages/admin/admin_page.dart';
import 'pages/guru/guru_home_page.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isLoggedIn') ?? false) {
      final userDataString = prefs.getString('userData');
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        final user = UserModel.fromJson(userData);
        if (user.email.isNotEmpty && context.mounted) {
          _navigateByUserRole(user);
        }
      }
    }
  }

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      String email = _usernameController.text.trim();
      String password = _passwordController.text.trim();

      try {
        final result = await AuthService.login(email, password);
        
        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          final userData = result['data'];
          final user = UserModel.fromJson(userData);

          if (context.mounted) {
            _navigateByUserRole(user);
          }
        } else {
          if (context.mounted) {
            _showMessage(result['message'] ?? 'Login gagal');
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

  void _navigateByUserRole(UserModel user) {
    if (user.role == 'guru') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GuruHomePage(user: user)),
      );
    } else if (user.role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminPage()),
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
  
  void _LupaPasswordForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LupaPassword()),
    );
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
                        const _Logo(),
                        _FormContent(
                          formKey: _formKey,
                          usernameController: _usernameController,
                          passwordController: _passwordController,
                          onLogin: _login,
                          onSignUp: _goToSignUp,
                          isLoading: _isLoading,
                          onPassword: _LupaPasswordForm,
                        ),
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(32.0),
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Row(
                      children: [
                        const Expanded(child: _Logo()),
                        Expanded(
                          child: Center(
                            child: _FormContent(
                              formKey: _formKey,
                              usernameController: _usernameController,
                              passwordController: _passwordController,
                              onLogin: _login,
                              onSignUp: _goToSignUp,
                              isLoading: _isLoading,
                              onPassword: _LupaPasswordForm,
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

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/panda.png', height: isSmallScreen ? 100 : 200),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "PRIVATE AJA",
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
            "Selamat Datang di PRIVATE AJA",
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

class _FormContent extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;
  final VoidCallback onSignUp;
  final VoidCallback onPassword;
  final bool isLoading;

  const _FormContent({
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.onLogin,
    required this.onSignUp,
    required this.isLoading,
    required this.onPassword,
  });

  @override
  State<_FormContent> createState() => __FormContentState();
}

class __FormContentState extends State<_FormContent> {
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Form(
        key: widget.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: widget.usernameController,
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
                hintText: 'Masukkan email Anda',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            _gap(),
            TextFormField(
              controller: widget.passwordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password harus diisi';
                }

                if (value.length < 6) {
                  return 'Password minimal 6 karakter';
                }
                return null;
              },
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Masukkan password Anda',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
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
            CheckboxListTile(
              value: _rememberMe,
              onChanged: widget.isLoading
                  ? null
                  : (value) {
                      if (value == null) return;
                      setState(() {
                        _rememberMe = value;
                      });
                    },
              title: const Text('Remember me'),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              contentPadding: const EdgeInsets.all(0),
            ),
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
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: widget.onLogin,
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          'Sign in',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
            ),
            _gap(),
            TextButton(
              onPressed: widget.isLoading ? null : widget.onPassword,
              child: const Text(
                'Lupa Password?',
                style: TextStyle(color: Colors.orange),
              ),
            ),
            _gap(),
            TextButton(
              onPressed: widget.isLoading ? null : widget.onSignUp,
              child: const Text(
                'Belum punya akun? Daftar di sini',
                style: TextStyle(color: Colors.orange),
              ),
            ),
            _gap(),
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

  Widget _gap() => const SizedBox(height: 16);
}