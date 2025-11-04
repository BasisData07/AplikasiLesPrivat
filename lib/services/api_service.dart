import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io'; // Untuk Platform
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'dart:async';

class ApiService {
  // === KONFIGURASI BASE URL OTOMATIS ===
  // Akan menyesuaikan platform (web, emulator, atau device fisik)
  static String getBaseUrl() {
    if (kIsWeb) {
      // 🟢 Jika dijalankan di browser (Chrome)
      return 'http://localhost:5000/api';
    }

    if (Platform.isAndroid) {
      // 🟢 Jika di emulator Android, gunakan IP khusus
      return 'http://10.0.2.2:5000/api';
    }

    if (Platform.isIOS) {
      // 🟢 Jika di simulator iOS
      return 'http://127.0.0.1:5000/api';
    }

    // 🟢 Jika di HP fisik (pastikan pakai IP laptop kamu di jaringan WiFi yang sama)
    // Ganti IP di bawah ini dengan IP laptop kamu
    return 'http://192.168.1.8:5000/api'; // ⚠️ GANTI sesuai IP lokal laptop kamu
  }

  // === METHOD POST ===
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final String baseUrl = getBaseUrl();
    final String fullUrl = '$baseUrl/$endpoint';

    print('🌍 Base URL: $baseUrl');
    print('🚀 API CALL: POST $fullUrl');
    print('📦 Data: ${jsonEncode(data)}');

    try {
      final response = await http
          .post(
            Uri.parse(fullUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15)); // Timeout 15 detik

      print('✅ RESPONSE STATUS: ${response.statusCode}');
      print('📄 RESPONSE BODY: ${response.body}');

      // Coba decode JSON dari server
      Map<String, dynamic> responseBody = jsonDecode(response.body);

      // Jika server mengirim success=true
      if (responseBody['success'] == true) {
        return responseBody;
      } else {
        // Jika success=false
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Terjadi kesalahan pada server'
        };
      }
    } on SocketException catch (_) {
      print('❌ ERROR: Tidak bisa menjangkau server (SocketException)');
      return {
        'success': false,
        'message':
            'Tidak bisa terhubung ke server. Pastikan server Node.js berjalan dan perangkat satu jaringan.'
      };
    } on FormatException catch (_) {
      print('❌ ERROR: Response bukan JSON valid');
      return {
        'success': false,
        'message': 'Respon dari server tidak valid (bukan JSON).'
      };
    } on HttpException catch (_) {
      print('❌ ERROR: HTTP Exception');
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat menghubungi server.'
      };
    } on TimeoutException catch (_) {
      print('❌ ERROR: Request timeout');
      return {
        'success': false,
        'message': 'Koneksi ke server terlalu lama (timeout).'
      };
    } catch (e) {
      print('💥 ERROR UMUM: $e');
      return {
        'success': false,
        'message': 'Gagal terhubung ke server. Pastikan server berjalan.'
      };
    }
  }

  // === METHOD GET (opsional, jika dibutuhkan) ===
  static Future<Map<String, dynamic>> get(String endpoint) async {
    final String baseUrl = getBaseUrl();
    final String fullUrl = '$baseUrl/$endpoint';

    print('🌍 GET Request: $fullUrl');

    try {
      final response = await http
          .get(Uri.parse(fullUrl), headers: {
            'Accept': 'application/json',
          })
          .timeout(const Duration(seconds: 15));

      print('✅ RESPONSE STATUS: ${response.statusCode}');
      print('📄 RESPONSE BODY: ${response.body}');

      return jsonDecode(response.body);
    } catch (e) {
      print('💥 ERROR (GET): $e');
      return {'success': false, 'message': 'Gagal menghubungi server'};
    }
  }
}
