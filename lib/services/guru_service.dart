import 'dart:convert';
import 'package:PRIVATE_AJA/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class GuruService {
  // Fungsi 1: Ambil Detail Guru (GET)
  // Ambil Detail Guru
  static Future<Map<String, dynamic>?> getDetailGuru(String id) async {
    // Panggil ApiService.get (otomatis pakai baseUrl yang benar)
    final result = await ApiService.get('guru-data/detail/$id');

    if (result['success'] == true) {
      return result['data'];
    } else {
      print("Gagal ambil data: ${result['message']}");
      return null;
    }
  }

  // Update Profil
  static Future<Map<String, dynamic>> updateProfil(String id, Map<String, dynamic> data) async {
    // Panggil ApiService.put
    return await ApiService.put('profile/update-info/$id', data);
  }
  }

  // Fungsi 2: Update Profil Guru (PUT) - (Opsional, jika Anda ingin pindahkan yang edit juga)
  // --- TAMBAHKAN FUNGSI INI ---
  Future<Map<String, dynamic>> updateProfil(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.put(
        Uri.parse("${ApiService.getBaseUrl}/api/profile/update-info/$id"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      final result = json.decode(response.body);

      if (response.statusCode == 200 && result['success'] == true) {
        return {'success': true, 'message': 'Profil berhasil diperbarui!'};
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Gagal update',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
  
  Future<Map<String, dynamic>> uploadProfilePicture(
    XFile imageFile, String userId) async {
  
    // --- DEBUG 1: CEK URL & PARAMETER ---
    print('🔗 [DEBUG] Mengirim request ke: http://localhost:5000/api/profile/upload-profile-picture');
    print('📤 [DEBUG] User ID: $userId');
    print('📁 [DEBUG] File: ${imageFile.name}');
    
    final uri = Uri.parse('http://localhost:5000/api/profile/upload-profile-picture');
        
    try {
      var request = http.MultipartRequest('POST', uri);
      request.fields['user_id'] = userId.toString();

      http.MultipartFile multipartFile;

      if (kIsWeb) {
        var bytes = await imageFile.readAsBytes();
        multipartFile = http.MultipartFile.fromBytes(
          'profile_picture',
          bytes,
          filename: imageFile.name,
        );
      } else {
        multipartFile = await http.MultipartFile.fromPath(
          'profile_picture',
          imageFile.path,
        );
      }

      request.files.add(multipartFile);

      // --- DEBUG 2: SEBELUM KIRIM REQUEST ---
    print('🚀 [DEBUG] Mengirim request...');
    
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    
    // --- DEBUG 3: SETELAH DAPAT RESPONSE ---
      print('✅ [DEBUG] Status Code: ${response.statusCode}');
      print('📄 [DEBUG] Response Body (50 karakter pertama): ${response.body.length > 500 ? "${response.body.substring(0, 50)}..." : response.body}');
      
      // --- DEBUG 4: CEK APAKAH RESPONSE HTML ---
      if (response.body.trim().startsWith('<!DOCTYPE') || response.body.trim().startsWith('<html')) {
        print('❌ [DEBUG] SERVER MENGEMBALIKAN HTML, BUKAN JSON!');
        print('📄 [DEBUG] Full response: ${response.body}');
        return {
          'success': false,
          'message': 'Server error: Mengembalikan HTML bukan JSON. Endpoint mungkin salah.',
        };
      }

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        return {
          'success': true,
          'url': responseData['url'], 
        };
      } else {
        var responseData = json.decode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal mengunggah file.',
        };
      }
    } catch (e) {
      // --- DEBUG 5: JIKA ADA ERROR ---
      print('💥 [DEBUG] Error catch: $e');
      return {
        'success': false,
        'message': 'Terjadi error: $e',
      };
    }
  }
  
