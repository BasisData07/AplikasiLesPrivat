// lib/pages/ProfilPage.dart

import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/user_model.dart';
import 'login_page.dart';
import 'help_center_page.dart';
import 'terms_page.dart';

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
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
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

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDarkMode
        ? Colors.grey[900]
        : const Color(0xFFF692B3);
    final cardColor = widget.isDarkMode
        ? Colors.grey[800]!
        : const Color(0xFFFFD2E1);
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;
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
              side: BorderSide(color: Colors.pink.withAlpha(77), width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              leading: Icon(
                Icons.account_circle_outlined,
                color: Colors.pink[700],
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
              iconColor: Colors.pink[700],
              collapsedIconColor: Colors.pink[700],
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
                ListTile(
                  leading: Icon(Icons.lock_outline, size: 22, color: textColor),
                  title: Text("Password", style: TextStyle(color: textColor)),
                  subtitle: Text(
                    _isPasswordVisible
                        ? widget.user.password
                        : '•' * widget.user.password.length,
                    style: TextStyle(color: textColor.withAlpha(204)),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: textColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
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
              side: BorderSide(color: Colors.pink.withAlpha(77), width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: _deviceData.entries.map((entry) {
                return ListTile(
                  leading: Icon(
                    _getDeviceIcon(entry.key),
                    color: Colors.pink[700],
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
                backgroundColor: Colors.pink[700],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
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
        side: BorderSide(color: Colors.pink.withAlpha(77), width: 1),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.pink[700]),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        subtitle: value != null
            ? Text(value, style: TextStyle(color: textColor.withAlpha(204)))
            : null,
        trailing:
            trailing ??
            (onTap != null
                ? Icon(Icons.arrow_forward_ios, size: 16, color: textColor)
                : null),
      ),
    );
  }
}
