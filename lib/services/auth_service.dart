import 'dart:convert';
import 'dart:io';

import 'package:PRIVATE_AJA/pages/model/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  get _baseUrl => null;

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await ApiService.post('auth/login', {
      'email': email,
      'password': password,
    });

    if (response['success'] == true) {
      // Save user data to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userData', jsonEncode(response['data']));
      
      return {'success': true, 'data': response['data']};
    } else {
      return {'success': false, 'message': response['message']};
    }
  }

  
  static Future<Map<String, dynamic>> register(
    String name, String username, String email, String password, String role, String? subject) async {
    
    try {
      print('📝 Attempting registration for: $email');
      
      final response = await ApiService.post('auth/register', {
        'name': name,
        'username': username,
        'email': email,
        'password': password,
        'role': role,
        'subject': subject,
      });

      print('📡 Registration response: ${response['success']}');
      
      if (response['success'] == true) {
        print('✅ Registration successful');
        return {'success': true, 'data': response['data']};
      } else {
        print('❌ Registration failed: ${response['message']}');
        return {'success': false, 'message': response['message']};
      }
    } catch (e) {
      print('💥 Registration error: $e');
      return {'success': false, 'message': 'Gagal terhubung ke server'};
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userData');
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');
    
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return {};
  }
  
 
  static Future<Map<String, dynamic>> updatePasswordTanpaVerifikasi(String email, String password) async {
    try {
      print('🔒 (INSECURE) Attempting password update for: $email');
      
      final response = await ApiService.post('auth/update-password-direct', {
        'email': email,
        'new_password': password, // Mengirim 'new_password' sesuai harapan file PHP
      });

      print('📡 Update password response: ${response['success']}');

      if (response['success'] == true) {
        return {'success': true, 'message': response['message']};
      } else {
        return {'success': false, 'message': response['message']};
      }
    } catch (e) {
      print('💥 Update Password error: $e');
      return {'success': false, 'message': 'Gagal terhubung ke server'};
    }
  }
  // --- END FUNGSI BARU ---
  // Di dalam file: auth_service.dart

Future<Map<String, dynamic>> deleteAccount({
  required UserModel currentUser, // Berisi ID dan ROLE
  required String password,
}) async {
  try {
    print('🗑️ Requesting account deletion for user: ${currentUser.id}');
    
    // Siapkan data yang BENAR untuk backend
    final data = {
      'userId': currentUser.id,
      'role': currentUser.role,     // Mengirim 'role' (BUKAN 'email')
      'password': password,
    };

    // Panggil ApiService.post
    final response = await ApiService.post('auth/delete-account', data);

    print('📡 Delete account response: ${response['success']}');
    
    if (response['success'] == true) {
      // ... (logika logout) ...
      return {'success': true, 'message': response['message']};
    } else {
      return {'success': false, 'message': response['message']};
    }
  } catch (e) {
    print('💥 Delete account error: $e');
    return {'success': false, 'message': 'Gagal terhubung ke server'};
  }
}

  static Future<Map<String, dynamic>> getAllUsers() async {
    try {
      print('👥 Requesting all users');
      final response = await ApiService.get('auth/users');

      if (response['success'] == true) {
        return {'success': true, 'data': response['data']};
      } else {
        return {'success': false, 'message': response['message']};
      }
    } catch (e) {
      print('💥 Get all users error: $e');
      return {'success': false, 'message': 'Gagal mengambil data pengguna'};
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
    print('📄 [DEBUG] Response Body (50 karakter pertama): ${response.body.length > 500 ? response.body.substring(0, 50) + "..." : response.body}');
    
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

}