/*import 'package:PRIVATE_AJA/services/api_service.dart';
import 'package:http/http.dart' as http;

class ConnectionTest {
  static Future<void> testAllConnections() async {
    final testUrls = [
      ApiService.getBaseUrl,
      // Tambahkan URL lain jika perlu
    ];

    print('🔍 TESTING CONNECTIONS...');
    
    for (var url in testUrls) {
      try {
        final response = await http.get(Uri.parse(ApiService.getBaseUrl)).timeout(Duration(seconds: 5));
        print('✅ ${ApiService.getBaseUrl} -> STATUS: ${response.statusCode}');
        if (response.statusCode == 200) {
          print('🎯 GUNAKAN URL INI: ${ApiService.getBaseUrl}');
          return;
        }
      } catch (e) {
        print('❌ ${ApiService.getBaseUrl} -> ERROR: $e');
      }
    }
    
    print('💥 SEMUA KONEKSI GAGAL!');
  }
}*/

import 'package:PRIVATE_AJA/services/api_service.dart';
import 'package:http/http.dart' as http;

class ConnectionTest {
  // Fungsi sederhana untuk cek apakah Server Railway Hidup
  static Future<void> testAllConnections() async {
    final String url = ApiService.getBaseUrl;
    
    print('🔍 SEDANG MENGECEK KONEKSI KE RAILWAY...');
    print('👉 URL: $url');

    try {
      // Kita coba 'ping' server dengan timeout 10 detik
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      print('✅ Respon Server Diterima!');
      print('📊 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('🚀 Mantap! Server Railway ONLINE dan siap dipakai.');
      } else if (response.statusCode == 404) {
        // 404 artinya server NYALA tapi alamat/rute spesifik ini tidak ada kontennya.
        // Ini tetap pertanda BAGUS karena artinya server merespon.
        print('⚠️ Server Hidup (Tapi endpoint root kosong/404). Koneksi Aman!');
      } else {
        print('⚠️ Server merespon dengan kode lain: ${response.statusCode}');
      }
      
    } catch (e) {
      // Ini kalau internet mati atau server railway down total
      print('❌ GAGAL TERHUBUNG KE SERVER!');
      print('Penyebab: $e');
    }
  }
}