import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';
import 'package:flutter/foundation.dart';

import 'pages/splash_screen.dart';
import 'pages/login_page.dart';
import 'pages/SignUpPage.dart';
import 'pages/home_page.dart';
import 'pages/model/user_model.dart';
import 'pages/model/guru_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    WebViewPlatform.instance = WebWebViewPlatform();
  }

  await initializeDateFormatting('id_ID', null);
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => GuruProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LES MANIA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      home: const SplashWrapper(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        // UBAH BAGIAN DI BAWAH INI
        '/home': (context) => MyHomePage(
          user: UserModel(
            name: "Guest",
            username: "guest", // TAMBAHKAN USERNAME INI
            email: "guest@lesmania.com",
            password: "-",
          ),
        ),
      },
    );
  }
}

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showSplash ? const SplashScreen() : const LoginPage();
  }
}
