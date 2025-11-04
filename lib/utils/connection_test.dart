import 'package:http/http.dart' as http;

class ConnectionTest {
  static Future<void> testAllConnections() async {
    final testUrls = [
      //'http://10.0.2.2:5000/',
      'http://localhost:5000/',
      //'http://127.0.0.1:5000/',
    ];

    print('🔍 TESTING CONNECTIONS...');
    
    for (var url in testUrls) {
      try {
        final response = await http.get(Uri.parse(url)).timeout(Duration(seconds: 5));
        print('✅ $url -> STATUS: ${response.statusCode}');
        if (response.statusCode == 200) {
          print('🎯 GUNAKAN URL INI: $url');
          return;
        }
      } catch (e) {
        print('❌ $url -> ERROR: $e');
      }
    }
    
    print('💥 SEMUA KONEKSI GAGAL!');
  }
}