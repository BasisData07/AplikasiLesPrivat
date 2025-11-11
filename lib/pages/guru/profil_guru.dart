// lib/pages/guru/profil_guru.dart

import 'dart:io'; // --- BARU ---
import 'package:image_picker/image_picker.dart'; // --- BARU ---
import 'package:PRIVATE_AJA/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

// --- PATH IMPORT YANG DIPERBAIKI ---
import '../model/user_model.dart';
import '../../login_page.dart';
import '../murid/help_center_page.dart';
import '../murid/terms_page.dart';
import '../murid/about_me_page.dart';
import '../model/ulasan_model.dart';
import '../model/ulasan_provider.dart';

class GuruProfilPage extends StatefulWidget {
  final UserModel user;
  const GuruProfilPage({super.key, required this.user});

  @override
  State<GuruProfilPage> createState() => _GuruProfilPageState();
}

class _GuruProfilPageState extends State<GuruProfilPage> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  final bool _isPasswordVisible = false;

  double _rating = 3.0;
  final TextEditingController _feedbackController = TextEditingController();

  static const Color mintHighlight = Color(0xFF3CB371);
  static const Color lightMintBackground = Color(0xFFF5FFFA);

  // --- BARU: Untuk Image Picker ---
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  // --- END BARU ---

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

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};
    try {
      if (kIsWeb) {
        deviceData = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
      } else {
        deviceData = switch (defaultTargetPlatform) {
          TargetPlatform.android => _readAndroidBuildData(
              await deviceInfoPlugin.androidInfo,
            ),
          TargetPlatform.iOS => _readIosDeviceInfo(
              await deviceInfoPlugin.iosInfo,
            ),
          TargetPlatform.windows => _readWindowsDeviceInfo(
              await deviceInfoPlugin.windowsInfo,
            ),
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

  // ... [Fungsi _read...Data() dan _getDeviceIcon() tetap sama] ...
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
      case 'name':
        return Icons.phone_android;
      case 'brand':
        return Icons.factory;
      case 'os version':
      case 'version':
      case 'system':
      case 'sdk':
        return Icons.android;
      case 'browser':
        return Icons.web;
      case 'platform':
      case 'product name':
        return Icons.laptop_chromebook;
      case 'computer name':
        return Icons.laptop_windows;
      default:
        return Icons.device_hub;
    }
  }

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
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Colors.amber),
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
                  const SnackBar(
                    content: Text("Terima kasih atas penilaian Anda!"),
                    backgroundColor: Colors.green,
                  ),
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
              child: const Text(
                "Ya, Keluar",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  // --- BARU: Fungsi untuk pilih sumber gambar ---
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  _pickAndUploadImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Kamera'),
                onTap: () {
                  _pickAndUploadImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- BARU: Fungsi untuk ambil dan upload gambar ---
Future<void> _pickAndUploadImage(ImageSource source) async {
  final XFile? pickedFile = await _picker.pickImage(
    source: source,
    imageQuality: 80, 
    maxWidth: 800, 
  );

  if (pickedFile == null) {
    return; // User membatalkan
  }

  setState(() {
    _isUploading = true;
  });

  final authService = AuthService();
  final scaffoldMessenger = ScaffoldMessenger.of(context);

  try {
    // --- PERBAIKAN DI SINI ---
    final result = await authService.uploadProfilePicture(
      pickedFile, // ← HAPUS "as XFile"
      widget.user.id.toString(), 
    );

    if (result['success'] == true) {
      final newImageUrl = result['url'];
      setState(() {
        widget.user.foto_profil_guru = newImageUrl;
      });
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text("Foto profil berhasil diperbarui!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? "Gagal mengunggah foto."),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text("Terjadi error: $e"),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() {
      _isUploading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.grey[900] : lightMintBackground;
    final cardColor = isDarkMode ? Colors.grey[800]! : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final String formattedDate = DateFormat(
      'EEEE, dd MMMM yyyy',
      'id_ID',
    ).format(DateTime.now());

    return Scaffold(
      backgroundColor: bgColor,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            formattedDate,
            style: TextStyle(fontSize: 16, color: textColor.withAlpha(204)),
          ),
          const SizedBox(height: 20),

          // --- BARU: Header Profil (Avatar & Nama) ---
          _buildProfileHeader(textColor),
          const SizedBox(height: 20),
          // --- END BARU ---

          _buildAccountInfoCard(cardColor, textColor), // --- DIUBAH ---
          const SizedBox(height: 10),
          _infoCard(
            icon: Icons.help_outline,
            title: "Pusat Bantuan",
            value: "Lihat pertanyaan umum (FAQ)",
            cardColor: cardColor,
            textColor: textColor,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpCenterPage()),
            ),
          ),
          const SizedBox(height: 10),
          _infoCard(
            icon: Icons.description_outlined,
            title: "Syarat dan Ketentuan",
            value: "Baca aturan penggunaan aplikasi",
            cardColor: cardColor,
            textColor: textColor,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TermsPage()),
            ),
          ),
          const SizedBox(height: 10),
          _infoCard(
            icon: Icons.info_outline,
            title: "Tentang Pencipta",
            value: "Latar belakang pembuat aplikasi",
            cardColor: cardColor,
            textColor: textColor,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutMePage()),
            ),
          ),
          const SizedBox(height: 10),
          _infoCard(
            icon: Icons.star_outline,
            title: "Beri Rating",
            value: "Bantu kami menjadi lebih baik",
            cardColor: cardColor,
            textColor: textColor,
            onTap: _showRatingDialog,
          ),
          const SizedBox(height: 25),
          Text(
            "Informasi Perangkat:",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),
          _buildDeviceInfoCard(cardColor, textColor),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                // WARNA DIUBAH DI SINI
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                _showDeleteAccountDialog();
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                "Delete Akun",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Konsisten dengan tombol delete
              foregroundColor: Colors.white, // Warna teks putih
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed:
                _showLogoutConfirmationDialog, // Fungsi logout sudah benar
            icon: const Icon(Icons.logout),
            label: const Text("Log Out", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // --- BARU: Widget untuk Header Profil ---
  Widget _buildProfileHeader(Color textColor) {
  // Cek apakah ada URL gambar profil
  final bool hasImage = widget.user.foto_profil_guru != null &&
      widget.user.foto_profil_guru!.isNotEmpty;

  return Column(
    children: [
      Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: hasImage 
                ? NetworkImage(widget.user.foto_profil_guru!) // ← PERBAIKAN DI SINI
                : null,
            child: !hasImage
                ? const Icon(Icons.person, size: 60, color: Colors.white)
                : null,
          ),
          if (_isUploading)
            const Positioned.fill(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: mintHighlight,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: IconButton(
                icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                onPressed: _isUploading ? null : _showImageSourceDialog,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Text(
        widget.user.name,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        widget.user.email,
        style: TextStyle(
          fontSize: 16,
          color: textColor.withAlpha(204),
        ),
      ),
    ],
  );
}
  // --- END BARU ---

  // --- DIUBAH: Menghapus Nama & Email dari Card ---
  Widget _buildAccountInfoCard(Color cardColor, Color textColor) {
    return Card(
      color: cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: mintHighlight.withAlpha(77), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: const Icon(
          Icons.account_circle_outlined,
          color: mintHighlight,
          size: 28,
        ),
        title: Text(
          "Informasi Akun",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        subtitle: Text(
          "Lihat detail username", // Subtitle diubah
          style: TextStyle(color: textColor.withAlpha(204)),
        ),
        iconColor: mintHighlight,
        collapsedIconColor: mintHighlight,
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        children: [
          const Divider(height: 1),
          // ListTile Nama & Email dihapus karena sudah ada di header
          ListTile(
            leading: Icon(Icons.person_outline, size: 22, color: textColor),
            title: Text("Username", style: TextStyle(color: textColor)),
            subtitle: Text(
              widget.user.username,
              style: TextStyle(color: textColor.withAlpha(204)),
            ),
            dense: true,
          ),
        ],
      ),
    );
  }
  // --- END DIUBAH ---

  Widget _buildDeviceInfoCard(Color cardColor, Color textColor) {
    return Card(
      color: cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: mintHighlight.withAlpha(77), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: _deviceData.entries.map((entry) {
          return ListTile(
            leading: Icon(_getDeviceIcon(entry.key), color: mintHighlight),
            title: Text(
              entry.key,
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            subtitle: Text(
              "${entry.value}",
              style: TextStyle(color: textColor.withAlpha(204)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    String? value,
    VoidCallback? onTap,
    required Color cardColor,
    required Color textColor,
  }) {
    return Card(
      color: cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: mintHighlight.withAlpha(77), width: 1),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: mintHighlight),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        subtitle: value != null
            ? Text(value, style: TextStyle(color: textColor.withAlpha(204)))
            : null,
        trailing: onTap != null
            ? Icon(Icons.arrow_forward_ios, size: 16, color: textColor)
            : null,
      ),
    );
  }

  // ... [Sisa fungsi _showDeleteAccountDialog, _showPasswordVerificationDialog, _deleteAccount tetap sama] ...
  // Method untuk show dialog konfirmasi
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Hapus Akun?"),
          content: Text(
            "Tindakan ini akan menghapus akun dan semua data Anda secara permanen. "
            "Anda tidak dapat mengembalikan akun setelah dihapus. "
            "Apakah Anda yakin ingin melanjutkan?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showPasswordVerificationDialog();
              },
              child: Text("Lanjutkan", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Dialog verifikasi password
  void _showPasswordVerificationDialog() {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Verifikasi Password"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Masukkan password Anda untuk konfirmasi penghapusan akun:",
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Batal"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    final password = passwordController.text.trim();
                    if (password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Password harus diisi")),
                      );
                      return;
                    }

                    // Panggil API hapus akun
                    await _deleteAccount(password);
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Hapus Akun",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Method hapus akun
  // Ini adalah fungsi di dalam file UI Anda (profil_guru.dart)

  Future<void> _deleteAccount(String password) async {
    // Tampilkan dialog loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Menghapus akun..."),
            ],
          ),
        );
      },
    );

    // Simpan context untuk digunakan setelah 'await'
    final currentContext = context;

    try {
      final authService = AuthService();
      final result = await authService.deleteAccount(
        currentUser: widget
            .user, // 'widget.user' adalah UserModel yang Anda dapatkan saat login
        password:
            password, // 'password' adalah parameter dari fungsi _deleteAccount
      );

      if (currentContext.mounted) {
        Navigator.pop(currentContext);
      }

      if (result['success'] == true) {
        // Jika sukses, lempar ke halaman Login
        if (currentContext.mounted) {
          Navigator.of(currentContext).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );

          // Tampilkan notifikasi sukses
          ScaffoldMessenger.of(currentContext).showSnackBar(
            const SnackBar(
              content: Text("Akun berhasil dihapus"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Jika gagal (misal: "Password salah")
        if (currentContext.mounted) {
          ScaffoldMessenger.of(currentContext).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? "Gagal menghapus akun"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Jika terjadi error (misal: tidak ada koneksi)
      if (currentContext.mounted) {
        Navigator.pop(currentContext); // Tutup dialog loading
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
}