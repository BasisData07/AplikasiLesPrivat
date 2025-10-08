import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'; // <-- TAMBAHKAN IMPORT INI

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController();

    _loadHtmlFromAssets();

    if (!kIsWeb) {
      _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    }
  }

  // ===== UBAH FUNGSI INI SEPERTI DI BAWAH =====
  Future<void> _loadHtmlFromAssets() async {
    try {
      // 1. Baca isi file HTML dari assets sebagai sebuah String
      final String htmlContent = await rootBundle.loadString(
        'assets/html/help_center.html',
      );

      // 2. Muat String HTML tersebut ke dalam WebView
      await _controller.loadHtmlString(htmlContent);
    } catch (e) {
      // Menangani jika ada error saat memuat file
      debugPrint('Error loading HTML from assets: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pusat Bantuan'),
        backgroundColor: Colors.pink[700],
        foregroundColor: Colors.white,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
