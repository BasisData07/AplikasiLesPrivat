// main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';
import 'package:flutter/foundation.dart';

// --- PERBAIKAN UTAMA ADA DI BAGIAN IMPORT INI ---
// Pastikan semua path ini sesuai dengan struktur folder Anda.
// Jika file tidak ditemukan, VS Code akan memberi garis bawah merah di sini.
import 'pages/splash_screen.dart';
import 'pages/login_page.dart';
import 'pages/SignUpPage.dart';
import 'pages/murid/home_page.dart';
import 'pages/model/user_model.dart';
import 'pages/model/guru_provider.dart';
import 'pages/model/ulasan_provider.dart';
import 'pages/model/jadwal_provider.dart'; // <-- Pastikan path ini benar

void main() async {
  // Pastikan Flutter siap sebelum menjalankan kode async
  WidgetsFlutterBinding.ensureInitialized();

  // Konfigurasi WebView untuk platform web
  if (kIsWeb) {
    WebViewPlatform.instance = WebWebViewPlatform();
  }

  // Inisialisasi format tanggal untuk bahasa Indonesia
  await initializeDateFormatting('id_ID', null);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GuruProvider()),
        ChangeNotifierProvider(create: (_) => UlasanProvider()),
        ChangeNotifierProvider(create: (_) => JadwalProvider()), // <-- Jika ini masih error, masalahnya ada di path import di atas
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color mintSeedColor = Color(0xFF3CB371);

    return MaterialApp(
      title: 'PRIVATE AJA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: mintSeedColor),
        useMaterial3: true,
      ),
      home: const SplashWrapper(), // Halaman awal adalah Splash
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => MyHomePage(
              // User default jika route '/home' diakses langsung
              user: UserModel(
                name: "Guest",
                username: "guest",
                email: "guest@privateaja.com",
                password: "-",
                role: 'murid', // Role default
              ),
            ),
      },
    );
  }
}

// Widget untuk menampilkan SplashScreen lalu mengarahkan ke LoginPage
class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  void _navigateToLogin() async {
    // Tampilkan splash selama 3 detik
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      // Ganti halaman splash dengan halaman login
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Selama penundaan, tampilkan SplashScreen
    return const SplashScreen();
  }
}