import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io'; // Untuk Platform
import 'package:flutter/foundation.dart'; // Untuk kIsWeb

class ApiService {
  
  // --- PENTING: PILIH BASE URL ANDA ---

  // Dapatkan IP yang benar berdasarkan platform
  static String getBaseUrl() {
    if (kIsWeb) {
      // Opsi 1: Jika tes di Web (Chrome)
      return 'http://localhost:5000/api';
    }
    
    // Opsi 2: Jika tes di Emulator Android
    // Gunakan 10.0.2.2 untuk merujuk ke 'localhost' komputer Anda
    return 'http://10.0.2.2:5000/api';

    // Opsi 3: Jika tes di HP Fisik (Ganti 192.168... dengan IP Anda)
    // return 'http://192.168.1.100:5000/api'; 
  }

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final String baseUrl = getBaseUrl();
    
    try {
      print('🚀 API CALL: POST $baseUrl/$endpoint');
      print('📦 Data: ${jsonEncode(data)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15)); // Perpanjang timeout

      print('✅ RESPONSE STATUS: ${response.statusCode}');
      print('📄 RESPONSE BODY: ${response.body}');
      
      // PERBAIKAN: Server Node.js kita selalu mengirim JSON, 
      // bahkan saat error (seperti 400, 404, 500).
      // Kita harus selalu membaca body-nya.
      Map<String, dynamic> responseBody = jsonDecode(response.body);

      // 'success' field dikirim dari Node.js
      if (responseBody['success'] == true) {
        return responseBody;
      } else {
        // Ini akan melempar error yang bisa dibaca oleh AuthService
        // (misal: "Email tidak terdaftar")
        throw Exception(responseBody['message'] ?? 'Terjadi kesalahan');
      }

    } catch (e) {
      // Ini adalah error jaringan (koneksi ditolak, timeout, dll)
      print('❌ API ERROR (Jaringan/Koneksi): $e');
      // 'e' akan berisi "Gagal terhubung ke server: ..."
      // Kita lempar ulang agar AuthService bisa menangkapnya
      throw Exception('Gagal terhubung ke server. Pastikan server Node.js berjalan dan baseUrl sudah benar.');
    }
  }
}
