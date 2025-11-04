import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../model/user_model.dart';
import '../../login_page.dart';
import '../murid/help_center_page.dart';
import '../murid/terms_page.dart';
import '../murid/about_me_page.dart';
import '../model/ulasan_model.dart';
import '../model/ulasan_provider.dart';

class ProfilPage extends StatefulWidget {
  final UserModel user;
  final bool isDarkMode;

  const ProfilPage({super.key, required this.user, required this.isDarkMode});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  final bool _isPasswordVisible = false;

  double _rating = 3.0;
  final TextEditingController _feedbackController = TextEditingController();

  // Palet warna tema hijau mint
  static const Color mintHighlight = Color(0xFF3CB371);
  static const Color lightMintBackground = Color(0xFFF5FFFA);

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
          TargetPlatform.android =>
              _readAndroidBuildData(await deviceInfoPlugin.androidInfo),
          TargetPlatform.iOS =>
              _readIosDeviceInfo(await deviceInfoPlugin.iosInfo),
          TargetPlatform.windows =>
              _readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo),
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
      'Device': build.device,
      'Manufacturer': build.manufacturer,
      'Model': build.model,
      'Product': build.product,
      'Physical Device?': build.isPhysicalDevice,
      'Supported ABIs': build.supportedAbis.join(', '),
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'Name': data.name,
      'System': data.systemName,
      'Version': data.systemVersion,
      'Model': data.model,
      'Machine': data.utsname.machine,
      'Physical Device?': data.isPhysicalDevice,
      'Identifier': data.identifierForVendor,
    };
  }

  Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      'Browser': data.browserName.name,
      'User Agent': data.userAgent,
      'Vendor': data.vendor,
      'Platform': data.platform,
      'Languages': data.languages?.join(', '),
      'Device Memory': data.deviceMemory?.toString(),
    };
  }

  Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      'Computer Name': data.computerName,
      'Product Name': data.productName,
      'Edition': data.editionId,
      'Build': data.buildNumber.toString(),
      'Install Date': data.installDate.toLocal().toString(),
      'Cores': data.numberOfCores.toString(),
      'Memory (MB)': data.systemMemoryInMegabytes.toString(),
    };
  }

  IconData _getDeviceIcon(String key) {
    switch (key.toLowerCase()) {
      case 'model':
      case 'device':
      case 'name':
      case 'machine':
        return Icons.phone_android;
      case 'brand':
      case 'manufacturer':
      case 'vendor':
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
      case 'cores':
      case 'memory (mb)':
      case 'device memory':
        return Icons.memory;
      case 'physical device?':
        return Icons.check_circle_outline;
      case 'user agent':
        return Icons.article;
      case 'identifier':
        return Icons.perm_identity;
      case 'install date':
        return Icons.calendar_today;
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
              onPressed: () {
                Navigator.of(context).pop();
              },
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
                setState(() {
                  _rating = 3.0;
                });
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
          content: const Text("Apakah Anda yakin ingin keluar dari akun Anda?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Ya, Keluar"),
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

  @override
  Widget build(BuildContext context) {
    // WARNA DIUBAH DI SINI
    final bgColor = widget.isDarkMode ? Colors.grey[900] : lightMintBackground;
    final cardColor = widget.isDarkMode ? Colors.grey[800]! : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
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
          Card(
            color: cardColor,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              // WARNA DIUBAH DI SINI
              side: BorderSide(color: mintHighlight.withAlpha(77), width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              // WARNA DIUBAH DI SINI
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
                "Lihat detail nama, email, & password",
                style: TextStyle(color: textColor.withAlpha(204)),
              ),
              // WARNA DIUBAH DI SINI
              iconColor: mintHighlight,
              collapsedIconColor: mintHighlight,
              childrenPadding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
              ),
              children: [
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.badge_outlined,
                    size: 22,
                    color: textColor,
                  ),
                  title: Text(
                    "Nama Lengkap",
                    style: TextStyle(color: textColor),
                  ),
                  subtitle: Text(
                    widget.user.name,
                    style: TextStyle(color: textColor.withAlpha(204)),
                  ),
                  dense: true,
                ),
                ListTile(
                  leading: Icon(
                    Icons.person_outline,
                    size: 22,
                    color: textColor,
                  ),
                  title: Text("Username", style: TextStyle(color: textColor)),
                  subtitle: Text(
                    widget.user.username,
                    style: TextStyle(color: textColor.withAlpha(204)),
                  ),
                  dense: true,
                ),
                ListTile(
                  leading: Icon(
                    Icons.email_outlined,
                    size: 22,
                    color: textColor,
                  ),
                  title: Text("Email", style: TextStyle(color: textColor)),
                  subtitle: Text(
                    widget.user.email,
                    style: TextStyle(color: textColor.withAlpha(204)),
                  ),
                  dense: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _infoCard(
            icon: Icons.help_outline,
            title: "Pusat Bantuan",
            value: "Lihat pertanyaan umum (FAQ)",
            cardColor: cardColor,
            textColor: textColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpCenterPage()),
              );
            },
          ),
          const SizedBox(height: 10),
          _infoCard(
            icon: Icons.description_outlined,
            title: "Syarat dan Ketentuan",
            value: "Baca aturan penggunaan aplikasi",
            cardColor: cardColor,
            textColor: textColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TermsPage()),
              );
            },
          ),
          const SizedBox(height: 10),
          _infoCard(
            icon: Icons.info_outline,
            title: "Tentang Pencipta",
            value: "Latar belakang pembuat aplikasi",
            cardColor: cardColor,
            textColor: textColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutMePage()),
              );
            },
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
            "Device Information:",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            color: cardColor,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              // WARNA DIUBAH DI SINI
              side: BorderSide(color: mintHighlight.withAlpha(77), width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: _deviceData.entries.map((entry) {
                return ListTile(
                  leading: Icon(
                    _getDeviceIcon(entry.key),
                    // WARNA DIUBAH DI SINI
                    color: mintHighlight,
                  ),
                  title: Text(
                    entry.key,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
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
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                // WARNA DIUBAH DI SINI
                backgroundColor: mintHighlight,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                _showLogoutConfirmationDialog();
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                "Log Out",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
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
    Widget? trailing,
  }) {
    return Card(
      color: cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // WARNA DIUBAH DI SINI
        side: BorderSide(color: mintHighlight.withAlpha(77), width: 1),
      ),
      child: ListTile(
        onTap: onTap,
        // WARNA DIUBAH DI SINI
        leading: Icon(icon, color: mintHighlight),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        subtitle: value != null
            ? Text(value, style: TextStyle(color: textColor.withAlpha(204)))
            : null,
        trailing: trailing ??
            (onTap != null
                ? Icon(Icons.arrow_forward_ios, size: 16, color: textColor)
                : null),
      ),
    );
  }
}