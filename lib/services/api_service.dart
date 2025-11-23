// lib/services/api_service.dart

import 'dart:convert';
import 'dart:io'; // Untuk Platform
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Untuk kIsWeb

class ApiService {
  
  // =======================================================================
  // 1. KONFIGURASI URL (DYNAMIC)
  // =======================================================================
  
  // GANTI IP INI SESUAI LAPTOP ANDA SAAT INI
  static const String _laptopIp = '192.168.1.8'; 
  static const String _port = '5000';

  // ✅ KITA GUNAKAN NAMA 'getBaseUrl' AGAR SESUAI DENGAN FILE LAIN
  static String get getBaseUrl {
    // 1. Jika Web, pakai localhost
    if (kIsWeb) {
      return 'http://localhost:$_port/api';
    }

    // 2. Cek Platform Mobile (Dibungkus try-catch agar aman)
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:$_port/api'; // Emulator Android
      }
      if (Platform.isIOS) {
        return 'http://127.0.0.1:$_port/api'; // Simulator iOS
      }
    } catch (e) {
      print('Info: Bukan platform mobile native');
    }

    // 3. Fallback ke IP Laptop (Untuk HP Fisik di jaringan sama)
    return 'http://$_laptopIp:$_port/api'; 
  }

  // Getter Gambar
  static String get baseImgUrl {
    // Mengubah '.../api' menjadi '.../uploads/'
    return getBaseUrl.replaceAll('/api', '/uploads/');
  }

  // =======================================================================
  // 2. METHOD GENERIC (POST, GET, PUT, DELETE)
  // =======================================================================

  // --- GET ---
  static Future<Map<String, dynamic>> get(String endpoint) async {
    final String fullUrl = '$getBaseUrl/$endpoint'; // Pakai getBaseUrl
    print('🌍 GET: $fullUrl');

    try {
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 20));

      return _processResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // --- POST ---
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final String fullUrl = '$getBaseUrl/$endpoint'; // Pakai getBaseUrl
    print('🚀 POST: $fullUrl');
    print('📦 Data: ${jsonEncode(data)}');

    try {
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 20));

      return _processResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // --- PUT (Untuk Edit Profil) ---
  static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    final String fullUrl = '$getBaseUrl/$endpoint'; // Pakai getBaseUrl
    print('✏️ PUT: $fullUrl');
    
    try {
      final response = await http.put(
        Uri.parse(fullUrl),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));

      return _processResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // --- DELETE ---
  static Future<Map<String, dynamic>> delete(String endpoint, {Map<String, dynamic>? data}) async {
    final String fullUrl = '$getBaseUrl/$endpoint'; // Pakai getBaseUrl
    print('🗑️ DELETE: $fullUrl');

    try {
      final response = await http.delete(
        Uri.parse(fullUrl),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: data != null ? jsonEncode(data) : null,
      ).timeout(const Duration(seconds: 15));

      return _processResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // =======================================================================
  // 4. HELPER
  // =======================================================================

  static Map<String, dynamic> _processResponse(http.Response response) {
    print('✅ STATUS: ${response.statusCode}');
    
    try {
      if (response.body.isEmpty) {
         return {'success': false, 'message': 'Server tidak memberikan respon (Body Kosong)'};
      }

      final body = jsonDecode(response.body);
      
      if (body is Map<String, dynamic>) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          if (!body.containsKey('success')) body['success'] = true; 
          return body;
        } else {
          return {
            'success': false,
            'message': body['message'] ?? 'Gagal. Kode: ${response.statusCode}'
          };
        }
      }
      return {'success': false, 'message': 'Format respon server salah.'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal memproses respon server: $e'};
    }
  }

  static Map<String, dynamic> _handleError(dynamic e) {
    print('💥 ERROR KONEKSI: $e');
    if (e is SocketException) {
      return {'success': false, 'message': 'Tidak ada koneksi internet / Server mati.'};
    } else if (e is TimeoutException) {
      return {'success': false, 'message': 'Waktu habis (Timeout). Cek koneksi Anda.'};
    } else {
      return {'success': false, 'message': 'Terjadi kesalahan aplikasi: $e'};
    }
  }
}