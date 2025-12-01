// lib/services/ulasan_service.dart

import 'package:PRIVATE_AJA/pages/model/ulasan_model.dart';
import 'package:PRIVATE_AJA/services/api_service.dart';// Import model yang akan dibuat

class UlasanService {
  // 1. Mengambil semua ulasan untuk guru tertentu
  static Future<List<UlasanModel>> getUlasanByGuruId(String guruId) async {
    try {
      final response = await ApiService.get('ulasan/guru/$guruId');
      
      if (response['success'] == true) {
        if (response['data'] is List) {
          return (response['data'] as List)
              .map((item) => UlasanModel.fromJson(item))
              .toList();
        }
      }
      return []; // Mengembalikan list kosong jika gagal
    } catch (e) {
      print("Error fetching ulasan: $e");
      // throw Exception('Gagal mengambil ulasan.'); // Lebih baik handle di UI
      return [];
    }
  }

  // 2. Murid mengirim rating dan komentar (CREATE)
  static Future<Map<String, dynamic>> submitUlasan({
    required String guruId,
    required String penggunaId, // Sesuai kolom database: pengguna_id
    required double rating,
    required String komentar,
  }) async {
    final data = {
      'guru_id': guruId,
      'pengguna_id': penggunaId,
      'rating': rating,
      'komentar': komentar,
    };
    return await ApiService.post('ulasan/create', data);
  }

  // 3. Guru membalas ulasan (CREATE REPLY)
  static Future<Map<String, dynamic>> submitBalasan({
    required int ulasanId,
    required String guruId,
    required String balasan,
  }) async {
    final data = {
      'ulasan_id': ulasanId,
      'guru_id': guruId,
      'balasan': balasan,
    };
    return await ApiService.post('ulasan/reply', data);
  }
}