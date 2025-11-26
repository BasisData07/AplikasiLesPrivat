import 'dart:convert';
import 'package:PRIVATE_AJA/services/api_service.dart'; // Pastikan ApiService memiliki getBaseUrl, get, put, dan delete
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class GuruService {
  // ===================================
  // FUNGSI 1: AMBIL DETAIL GURU (GET)
  // ===================================
  static Future<Map<String, dynamic>?> getDetailGuru(String id) async {
    final result = await ApiService.get('profile/detail/$id'); // Asumsi endpoint ini ada
    if (result['success'] == true) {
      return result['data'];
    }
    return null;
  }

  // ===================================
  // FUNGSI 2: UPDATE PROFIL GURU (PUT)
  // ===================================
  static Future<Map<String, dynamic>> updateProfil(String id, Map<String, dynamic> data) async {
    // Memanggil PUT ke endpoint: profile/update-info/:id
    return await ApiService.put('profile/update-info/$id', data);
  }

  // ===================================
  // FUNGSI 3: HAPUS PROFIL GURU (DELETE)
  // ===================================
  static Future<Map<String, dynamic>> deleteProfil(String id) async {
    // Memanggil DELETE ke endpoint: profile/delete-profile/:id
    return await ApiService.delete('profile/delete-profile/$id');
  }


  // ===================================
  // FUNGSI 4: UPLOAD FOTO PROFIL (POST)
  // ===================================
  static Future<Map<String, dynamic>> uploadProfilePicture(
      XFile imageFile, String userId) async {

    // Sesuaikan URL jika ApiService belum menanganinya.
    // Contoh di sini menggunakan URL lengkap:
    final uri = Uri.parse('${ApiService.getBaseUrl}/api/profile/upload-profile-picture');

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
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        return {
          'success': true,
          'url': responseData['url'],
        };
      } else {
        // Handle error response
        try {
          var responseData = json.decode(response.body);
          return {
            'success': false,
            'message': responseData['message'] ?? 'Gagal mengunggah file. Status ${response.statusCode}',
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'Error server: Status ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      if (kDebugMode) { print('💥 Error jaringan: $e'); }
      return {
        'success': false,
        'message': 'Terjadi error jaringan: $e',
      };
    }
  }
}