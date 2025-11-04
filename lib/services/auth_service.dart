import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
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
  
  // --- FUNGSI LAMA DIHAPUS ---
  // static Future<Map<String, dynamic>> lupaPassword(String email) async { ... }
  // static Future<Map<String, dynamic>> resetPassword(String token, String newPassword) async { ... }
  // --- END FUNGSI LAMA ---


  // --- FUNGSI BARU (TIDAK AMAN) DITAMBAHKAN ---
  // Fungsi ini dipanggil dari 'lupa_password_page.dart' yang baru.
  // Pastikan endpoint 'auth/update-password-direct' mengarah ke file
  // 'update_password_direct.php' yang saya berikan sebelumnya.
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

}