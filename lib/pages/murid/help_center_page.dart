import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart'; // Untuk rootBundle

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  late final WebViewController _controller;
  bool _isLoading = true; // Indikator loading agar tidak blank putih

  @override
  void initState() {
    super.initState();

    // 1. Inisialisasi Controller Standar (Tanpa logika Web)
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Wajib on untuk JS
      ..setBackgroundColor(const Color(0x00000000)) // Transparan
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView Error: ${error.description}');
          },
        ),
      );

    // 2. Load File HTML
    _loadHtmlFromAssets();
  }

  Future<void> _loadHtmlFromAssets() async {
    try {
      // Pastikan file ini ada di folder 'assets/html/' dan terdaftar di pubspec.yaml
      final String htmlContent = await rootBundle.loadString(
        'assets/html/help_center.html',
      );
      
      // Load konten HTML ke WebView
      await _controller.loadHtmlString(htmlContent);
    } catch (e) {
      debugPrint('Error loading HTML: $e');
      // Jika error, tampilkan pesan sederhana di WebView
      if (mounted) {
        _controller.loadHtmlString('''
          <html><body>
            <h2>Gagal memuat halaman</h2>
            <p>Pastikan file assets/html/help_center.html sudah dibuat dan didaftarkan di pubspec.yaml.</p>
            <p>Error: $e</p>
          </body></html>
        ''');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pusat Bantuan'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),
        ],
      ),
    );
  }
}