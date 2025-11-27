// lib/pages/guru/pengaturan_guru.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- IMPORT MODEL & HALAMAN TERKAIT ---
import 'package:PRIVATE_AJA/services/auth_service.dart';
import '../model/user_model.dart';
import '../model/ulasan_model.dart';
import '../model/ulasan_provider.dart';
import '../../login_page.dart';
import '../murid/help_center_page.dart';
import '../murid/terms_page.dart';
import '../murid/about_me_page.dart';

class GuruPengaturanPage extends StatefulWidget {
  final UserModel user;
  const GuruPengaturanPage({super.key, required this.user});

  @override
  State<GuruPengaturanPage> createState() => _GuruPengaturanPageState();
}

class _GuruPengaturanPageState extends State<GuruPengaturanPage> {
  // --- STATE UNTUK DEVICE INFO ---
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  // --- STATE UNTUK RATING ---
  double _rating = 3.0;
  final TextEditingController _feedbackController = TextEditingController();

  // Warna Tema
  static const Color mintHighlight = Color(0xFF3CB371);

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  // ==========================================
  // 1. LOGIC DEVICE INFO (LENGKAP)
  // ==========================================
  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};

    try {
      if (kIsWeb) {
        deviceData = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
      } else {
        deviceData = switch (defaultTargetPlatform) {
          TargetPlatform.android => _readAndroidBuildData(await deviceInfoPlugin.androidInfo),
          TargetPlatform.iOS => _readIosDeviceInfo(await deviceInfoPlugin.iosInfo),
          TargetPlatform.windows => _readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo),
          _ => <String, dynamic>{'Error': 'Platform tidak didukung'},
        };
      }
    } on PlatformException {
      deviceData = <String, dynamic>{'Error': 'Gagal mendapatkan info device'};
    }

    if (!mounted) return;
    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'OS Version': build.version.release,
      'SDK': build.version.sdkInt.toString(),
      'Brand': build.brand,
      'Model': build.model,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'Name': data.name,
      'System': data.systemName,
      'Version': data.systemVersion,
      'Model': data.model,
    };
  }

  Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      'Browser': data.browserName.name,
      'Platform': data.platform,
    };
  }

  Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      'Computer Name': data.computerName,
      'Product Name': data.productName,
    };
  }

  IconData _getDeviceIcon(String key) {
    switch (key.toLowerCase()) {
      case 'model':
      case 'name': return Icons.phone_android;
      case 'brand': return Icons.factory;
      case 'os version':
      case 'version':
      case 'system':
      case 'sdk': return Icons.android;
      case 'browser': return Icons.web;
      case 'platform':
      case 'product name': return Icons.laptop_chromebook;
      case 'computer name': return Icons.laptop_windows;
      default: return Icons.device_hub;
    }
  }

  // ==========================================
  // 2. LOGIC RATING
  // ==========================================
  void _showRatingDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: const Text("Beri Rating Aplikasi"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Seberapa puas Anda dengan aplikasi ini?"),
              const SizedBox(height: 20),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) {
                  _rating = rating;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _feedbackController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Tulis masukan Anda (opsional)...",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Kirim"),
              onPressed: () {
                final ulasanBaru = UlasanModel(
                  userName: widget.user.name,
                  rating: _rating,
                  feedback: _feedbackController.text,
                  timestamp: DateTime.now(),
                );
                context.read<UlasanProvider>().tambahUlasan(ulasanBaru);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Terima kasih atas penilaian Anda!"), backgroundColor: Colors.green),
                );
                _feedbackController.clear();
                setState(() => _rating = 3.0);
              },
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // 3. LOGIC LOGOUT
  // ==========================================
  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Logout"),
          content: const Text("Apakah Anda yakin ingin keluar?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text("Ya, Keluar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // 4. LOGIC HAPUS AKUN (LENGKAP)
  // ==========================================
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Hapus Akun?"),
          content: const Text(
            "Tindakan ini akan menghapus akun dan semua data Anda secara permanen. "
            "Anda tidak dapat mengembalikan akun setelah dihapus. "
            "Apakah Anda yakin ingin melanjutkan?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showPasswordVerificationDialog();
              },
              child: const Text("Lanjutkan", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showPasswordVerificationDialog() {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Verifikasi Password"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Masukkan password Anda untuk konfirmasi penghapusan akun:"),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    final password = passwordController.text.trim();
                    if (password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Password harus diisi")),
                      );
                      return;
                    }
                    await _deleteAccount(password);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text("Hapus Akun", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Di dalam file pengaturan_guru.dart

  Future<void> _deleteAccount(String password) async {
      // Simpan konteks halaman Pengaturan
      final pageContext = context; 
      
      // Konteks Khusus untuk Loading Dialog
      late BuildContext loadingDialogContext; 

      // --- 1. TAMPILKAN LOADING DIALOG ---
      showDialog(
        context: pageContext,
        barrierDismissible: false,
        builder: (BuildContext context) {
          loadingDialogContext = context; // Simpan konteks dialog
          return const Center(child: CircularProgressIndicator());
        },
      );

      try {
        final authService = AuthService();
        final result = await authService.deleteAccount(
          currentUser: widget.user,
          password: password,
        );

        // --- 2. TUTUP LOADING DIALOG HANYA SEKALI ---
        if (loadingDialogContext.mounted) Navigator.pop(loadingDialogContext); 

        // Di dalam _deleteAccount:

        if (result['success'] == true) {
            if (pageContext.mounted) {
                
                // 1. Tampilkan notifikasi terlebih dahulu
                ScaffoldMessenger.of(pageContext).showSnackBar(
                    const SnackBar(content: Text("Akun berhasil dihapus"), backgroundColor: Colors.green),
                );
                
                // 2. Tunda Navigasi sebentar untuk membiarkan SnackBar ditampilkan
                await Future.delayed(const Duration(milliseconds: 500)); 

                // 3. LAKUKAN NAVIGASI AMAN KE LOGIN PAGE
                Navigator.of(pageContext).pushAndRemoveUntil(
                    // Menggunakan MaterialPageRoute untuk memastikan route ditutup
                    MaterialPageRoute(builder: (context) => const LoginPage()), 
                    (route) => false,
                );
            }
        } else {
          // Tampilkan error jika gagal
          if (pageContext.mounted) {
              ScaffoldMessenger.of(pageContext).showSnackBar(
                  SnackBar(content: Text(result['message'] ?? "Gagal menghapus akun"), backgroundColor: Colors.red),
              );
          }
        }
      } catch (e) {
        if (loadingDialogContext.mounted) Navigator.pop(loadingDialogContext); // Tutup loading jika error
        
        if (pageContext.mounted) {
          ScaffoldMessenger.of(pageContext).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
          );
        }
      }
  }

  // ==========================================
  // 5. TAMPILAN (UI)
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.grey[900] : const Color(0xFFF5FFFA);
    final cardColor = isDarkMode ? Colors.grey[800]! : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: Text("Pengaturan"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
           // --- BAGIAN 1: INFO AKUN ---
           Padding(
             padding: const EdgeInsets.only(left: 5, bottom: 10),
             child: Text("Akun Saya", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
           ),
           Card(
             color: cardColor,
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
             child: Column(
               children: [
                 ListTile(
                   leading: const Icon(Icons.person, color: mintHighlight),
                   title: const Text("Username"),
                   subtitle: Text(widget.user.username),
                   dense: true,
                 ),
                 const Divider(height: 1),
                 ListTile(
                   leading: const Icon(Icons.email, color: mintHighlight),
                   title: const Text("Email"),
                   subtitle: Text(widget.user.email),
                   dense: true,
                 ),
               ],
             ),
           ),

           const SizedBox(height: 20),

           // --- BAGIAN 2: MENU UMUM ---
           Padding(
             padding: const EdgeInsets.only(left: 5, bottom: 10),
             child: Text("Umum", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
           ),
           _buildMenuCard("Pusat Bantuan", Icons.help_outline, cardColor, textColor, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterPage()));
           }),
           _buildMenuCard("Syarat & Ketentuan", Icons.description_outlined, cardColor, textColor, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsPage()));
           }),
           _buildMenuCard("Tentang Aplikasi", Icons.info_outline, cardColor, textColor, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutMePage()));
           }),
           _buildMenuCard("Beri Rating", Icons.star_outline, cardColor, textColor, _showRatingDialog),

           const SizedBox(height: 20),

           // --- BAGIAN 3: INFO PERANGKAT ---
           Padding(
             padding: const EdgeInsets.only(left: 5, bottom: 10),
             child: Text("Info Perangkat", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
           ),
           Card(
             color: cardColor,
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
             child: Column(
               children: _deviceData.entries.map((entry) {
                 return ListTile(
                   leading: Icon(_getDeviceIcon(entry.key), color: mintHighlight),
                   title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                   subtitle: Text("${entry.value}", style: const TextStyle(fontSize: 12)),
                   dense: true,
                 );
               }).toList(),
             ),
           ),

           const SizedBox(height: 30),
           
           // --- BAGIAN 4: AKSI BAHAYA ---
           ElevatedButton.icon(
             style: ElevatedButton.styleFrom(
               backgroundColor: Colors.grey, 
               padding: const EdgeInsets.all(15),
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
             ),
             onPressed: _showLogoutConfirmationDialog,
             icon: const Icon(Icons.logout, color: Colors.white),
             label: const Text("Log Out", style: TextStyle(color: Colors.white)),
           ),
           const SizedBox(height: 10),
           TextButton.icon(
             onPressed: _showDeleteAccountDialog,
             icon: const Icon(Icons.delete_forever, color: Colors.red),
             label: const Text("Hapus Akun Permanen", style: TextStyle(color: Colors.red)),
           ),
           const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuCard(String title, IconData icon, Color bg, Color text, VoidCallback onTap) {
    return Card(
      color: bg,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: mintHighlight),
        title: Text(title, style: TextStyle(color: text)),
        trailing: Icon(Icons.chevron_right, color: text.withOpacity(0.5)),
      ),
    );
  }
}