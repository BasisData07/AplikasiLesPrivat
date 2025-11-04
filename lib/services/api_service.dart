// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // 🔥 COBA URUTAN INI:
  
  // Opsi 1: Android Emulator
  //static const String baseUrl = 'http://10.0.2.2:5000/api';
  
  // Opsi 2: Localhost 
  static const String baseUrl = 'http://localhost:5000/api';
  
  // Opsi 3: IP komputer Anda (ganti 192.168.1.100 dengan IP Anda)
  // static const String baseUrl = 'http://192.168.1.100:5000/api';

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      print('🚀 API CALL: POST $baseUrl/$endpoint');
      print('📦 Data: $data');
      
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));

      print('✅ RESPONSE STATUS: ${response.statusCode}');
      print('📄 RESPONSE BODY: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ API ERROR: $e');
      throw Exception('Gagal terhubung ke server: $e');
    }
  }
}