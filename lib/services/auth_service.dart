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
  
  static Future<Map<String, dynamic>> lupaPassword(String email) async {
    try {
      print('📧 Requesting password reset for: $email');
      
      final response = await ApiService.post('auth/forgot-password', {
        'email': email,
      });

      print('📡 Forgot password response: ${response['success']}');
      
      if (response['success'] == true) {
        return {'success': true, 'message': response['message']};
      } else {
        return {'success': false, 'message': response['message']};
      }
    } catch (e) {
      print('💥 Forgot password error: $e');
      return {'success': false, 'message': 'Gagal terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> resetPassword(String token, String newPassword) async {
    try {
      final response = await ApiService.post('auth/reset-password', {
        'token': token,
        'newPassword': newPassword,
      });

      if (response['success'] == true) {
        return {'success': true, 'message': response['message']};
      } else {
        return {'success': false, 'message': response['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server'};
    }
  }
}