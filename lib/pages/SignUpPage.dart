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
  final TextEditingController _subjectController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String _selectedRole = 'murid';

  @override
  void dispose() {
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
    String? subject =
        _selectedRole == 'guru' ? _subjectController.text.trim() : null;

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
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    final bool isMediumScreen = MediaQuery.of(context).size.width < 1000;

    return Scaffold(
      body: Center(
        child: isSmallScreen
            ? SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _Logo(),
                    _FormRegistrasi(
                      formKey: _formKey,
                      nameController: _nameController,
                      usernameController: _usernameController,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      confirmPasswordController: _confirmPasswordController,
                      subjectController: _subjectController,
                      selectedRole: _selectedRole,
                      onRoleChanged: (newValue) {
                        setState(() {
                          _selectedRole = newValue;
                        });
                      },
                      onSignUp: _signUp,
                    ),
                  ],
                ),
              )
            : Container(
                padding: const EdgeInsets.all(32.0),
                constraints: const BoxConstraints(maxWidth: 1200),
                child: isMediumScreen
                    ? Column(
                        children: [
                          const _Logo(),
                          Expanded(
                            child: SingleChildScrollView(
                              child: _FormRegistrasi(
                                formKey: _formKey,
                                nameController: _nameController,
                                usernameController: _usernameController,
                                emailController: _emailController,
                                passwordController: _passwordController,
                                confirmPasswordController: _confirmPasswordController,
                                subjectController: _subjectController,
                                selectedRole: _selectedRole,
                                onRoleChanged: (newValue) {
                                  setState(() {
                                    _selectedRole = newValue;
                                  });
                                },
                                onSignUp: _signUp,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          const Expanded(child: _Logo()),
                          Expanded(
                            child: SingleChildScrollView(
                              child: _FormRegistrasi(
                                formKey: _formKey,
                                nameController: _nameController,
                                usernameController: _usernameController,
                                emailController: _emailController,
                                passwordController: _passwordController,
                                confirmPasswordController: _confirmPasswordController,
                                subjectController: _subjectController,
                                selectedRole: _selectedRole,
                                onRoleChanged: (newValue) {
                                  setState(() {
                                    _selectedRole = newValue;
                                  });
                                },
                                onSignUp: _signUp,
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
            "DAFTAR AKUN",
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
            "Bergabung dengan PRIVATE AJA",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
        ),
        const SizedBox(height: 15),
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
    );
  }
}

class _FormRegistrasi extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController subjectController;
  final String selectedRole;
  final Function(String) onRoleChanged;
  final VoidCallback onSignUp;

  const _FormRegistrasi({
    required this.formKey,
    required this.nameController,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.subjectController,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.onSignUp,
  });

  @override
  State<_FormRegistrasi> createState() => __FormRegistrasiState();
}

class __FormRegistrasiState extends State<_FormRegistrasi> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    final bool isMediumScreen = MediaQuery.of(context).size.width < 1000;

    return Container(
      constraints: BoxConstraints(
        maxWidth: isSmallScreen ? 400 : 600,
      ),
      child: Form(
        key: widget.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSmallScreen) ..._buildMobileLayout(),
            if (!isSmallScreen) ..._buildDesktopLayout(isMediumScreen),
            
            _gap(),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Daftar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                onPressed: widget.onSignUp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMobileLayout() {
    return [
      DropdownButtonFormField<String>(
        value: widget.selectedRole,
        decoration: const InputDecoration(
          labelText: 'Daftar Sebagai',
          prefixIcon: Icon(Icons.person_outline),
          border: OutlineInputBorder(),
        ),
        items: [
          DropdownMenuItem(
            value: 'murid',
            child: Text('Murid'),
          ),
          DropdownMenuItem(
            value: 'guru',
            child: Text('Guru'),
          ),
        ],
        onChanged: (String? newValue) {
          if (newValue != null) {
            widget.onRoleChanged(newValue);
          }
        },
      ),
      _gap(),
      
      TextFormField(
        controller: widget.nameController,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Nama lengkap harus diisi';
          }
          return null;
        },
        decoration: const InputDecoration(
          labelText: 'Nama Lengkap',
          hintText: 'Masukkan nama lengkap',
          prefixIcon: Icon(Icons.person),
          border: OutlineInputBorder(),
        ),
      ),
      _gap(),
      
      TextFormField(
        controller: widget.usernameController,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Username harus diisi';
          }
          return null;
        },
        decoration: const InputDecoration(
          labelText: 'Username',
          hintText: 'Masukkan username',
          prefixIcon: Icon(Icons.badge),
          border: OutlineInputBorder(),
        ),
      ),
      _gap(),
      
      if (widget.selectedRole == 'guru')
        Column(
          children: [
            TextFormField(
              controller: widget.subjectController,
              validator: (value) {
                if (widget.selectedRole == 'guru' && (value == null || value.isEmpty)) {
                  return 'Mata pelajaran wajib diisi untuk guru';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Mata Pelajaran',
                hintText: 'Masukkan mata pelajaran yang diajar',
                prefixIcon: Icon(Icons.book),
                border: OutlineInputBorder(),
              ),
            ),
            _gap(),
          ],
        ),
      
      TextFormField(
        controller: widget.emailController,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Email harus diisi';
          }
          if (!value.contains('@')) {
            return 'Format email tidak valid';
          }
          return null;
        },
        decoration: const InputDecoration(
          labelText: 'Email',
          hintText: 'Masukkan email',
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
          hintText: 'Masukkan password',
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
      
      TextFormField(
        controller: widget.confirmPasswordController,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Konfirmasi password harus diisi';
          }
          if (value != widget.passwordController.text) {
            return 'Password tidak cocok';
          }
          return null;
        },
        obscureText: !_isConfirmPasswordVisible,
        decoration: InputDecoration(
          labelText: 'Konfirmasi Password',
          hintText: 'Masukkan ulang password',
          prefixIcon: const Icon(Icons.lock_reset),
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(
              _isConfirmPasswordVisible
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildDesktopLayout(bool isMediumScreen) {
    return [
      Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: widget.selectedRole,
              decoration: const InputDecoration(
                labelText: 'Daftar Sebagai',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: 'murid',
                  child: Text('Murid'),
                ),
                DropdownMenuItem(
                  value: 'guru',
                  child: Text('Guru'),
                ),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  widget.onRoleChanged(newValue);
                }
              },
            ),
          ),
          _gapHorizontal(),
          Expanded(
            child: TextFormField(
              controller: widget.nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama lengkap harus diisi';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                hintText: 'Masukkan nama lengkap',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
      _gap(),
      
      if (widget.selectedRole == 'guru')
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.usernameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username harus diisi';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'Masukkan username',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            _gapHorizontal(),
            Expanded(
              child: TextFormField(
                controller: widget.subjectController,
                validator: (value) {
                  if (widget.selectedRole == 'guru' && (value == null || value.isEmpty)) {
                    return 'Mata pelajaran wajib diisi';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Mata Pelajaran',
                  hintText: 'Mata pelajaran yang diajar',
                  prefixIcon: Icon(Icons.book),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        )
      else
        TextFormField(
          controller: widget.usernameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Username harus diisi';
            }
            return null;
          },
          decoration: const InputDecoration(
            labelText: 'Username',
            hintText: 'Masukkan username',
            prefixIcon: Icon(Icons.badge),
            border: OutlineInputBorder(),
          ),
        ),
      _gap(),
      
      TextFormField(
        controller: widget.emailController,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Email harus diisi';
          }
          if (!value.contains('@')) {
            return 'Format email tidak valid';
          }
          return null;
        },
        decoration: const InputDecoration(
          labelText: 'Email',
          hintText: 'Masukkan email',
          prefixIcon: Icon(Icons.email_outlined),
          border: OutlineInputBorder(),
        ),
      ),
      _gap(),
      
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: widget.passwordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password harus diisi';
                }
                if (value.length < 6) {
                  return 'Minimal 6 karakter';
                }
                return null;
              },
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Masukkan password',
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
          ),
          _gapHorizontal(),
          Expanded(
            child: TextFormField(
              controller: widget.confirmPasswordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Konfirmasi password harus diisi';
                }
                if (value != widget.passwordController.text) {
                  return 'Password tidak cocok';
                }
                return null;
              },
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Konfirmasi Password',
                hintText: 'Masukkan ulang password',
                prefixIcon: const Icon(Icons.lock_reset),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _gap() => const SizedBox(height: 16);
  Widget _gapHorizontal() => const SizedBox(width: 16);
}