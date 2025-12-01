/*lib/repositories/jadwal_repository.dart

// [DIBENAHI] Path import disesuaikan dengan struktur folder Anda

import 'package:PRIVATE_AJA/pages/model/guru_mapel_model.dart';
import 'package:PRIVATE_AJA/pages/model/jadwal_les_model.dart';
import 'package:PRIVATE_AJA/services/api_service.dart';

// [DITAMBAHKAN] Import untuk model yang hilang


// Repository adalah lapisan LOGIKA. Ia tahu CARA mengambil data.
class JadwalRepository {

  // === (READ) Untuk Beranda Murid ===
  Future<List<JadwalLesModel>> getJadwalUntukBerandaMurid() async {
    try {
      
      final response = await ApiService.get('jadwal/all');
      if (response['success'] == true) {
        List<JadwalLesModel> jadwalList = (response['data'] as List)
            .map((item) => JadwalLesModel.fromJson(item))
            .toList();
        return jadwalList;
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Gagal memuat jadwal: $e');
    }
  }
  
  // [DIBENAHI] Ini adalah fungsi untuk Dropdown "Pilih Mapel"
  Future<List<GuruMapelModel>> getMapelMilikGuru(String guruId) async {
    try {
      final response = await ApiService.get('guru-data/mapel-saya/$guruId');
      if (response['success'] == true) {
        List<GuruMapelModel> mapelList = (response['data'] as List)
            .map((item) => GuruMapelModel.fromJson(item))
            .toList();
        return mapelList;
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Gagal memuat daftar mapel guru: $e');
    }
  }
  
  // [DITAMBAHKAN] Ini adalah fungsi untuk "Jadwal Saya" di Beranda Guru
  Future<List<Map<String, dynamic>>> getJadwalMilikGuru(String guruId) async {
    try {
      final response = await ApiService.get('jadwal/guru/$guruId');
      if (response['success'] == true) {
        List<Map<String, dynamic>> jadwalList = 
            List<Map<String, dynamic>>.from(response['data']);
        return jadwalList;
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      throw Exception('Gagal memuat jadwal milik guru: $e');
    }
  }

  // === (CREATE) Untuk Guru Menambah Jadwal ===
  Future<Map<String, dynamic>> createJadwal({
    required int idGuruMapel, 
    required String hari,
    required String jamMulai, 
    required String jamSelesai, 
  }) async {
    final data = {
      'id_gurumapel': idGuruMapel,
      'hari': hari,
      'jam_mulai': jamMulai, 
      'jam_selesai': jamSelesai,
    };
    final response = await ApiService.post('jadwal/create', data);
    return response; 
  }

  // === (DELETE) Untuk Guru Menghapus Jadwal ===
  Future<Map<String, dynamic>> deleteJadwal({
    required int jadwalId,
    required String guruIdPemilik, 
  }) async {
    final data = {'guru_id_pemilik': guruIdPemilik};
    final response = await ApiService.post('jadwal/delete/$jadwalId', data);
    return response;
  }
  
  // === (UPDATE) Untuk Guru Mengubah Jadwal ===
  Future<Map<String, dynamic>> updateJadwal({
    required int jadwalId,
    required String guruIdPemilik, 
    required String hari,
    required String jamMulai,
    required String jamSelesai, required int idGuruMapel,
  }) async {
    final data = {
      'guru_id_pemilik': guruIdPemilik,
      'hari': hari,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
    };
    final response = await ApiService.post('jadwal/update/$jadwalId', data);
    return response;
  }

  // [DIHAPUS] Fungsi duplikat yang kosong dihapus dari sini
}

[DIHAPUS] Definisi class GuruMapelModel dihapus dari sini*/

// lib/repositories/jadwal_repository.dart

import 'package:PRIVATE_AJA/pages/model/guru_mapel_model.dart';
import 'package:PRIVATE_AJA/pages/model/jadwal_les_model.dart';
import 'package:PRIVATE_AJA/services/api_service.dart';
// Tambahkan untuk memastikan decoding error message

// Repository adalah lapisan LOGIKA. Ia tahu CARA mengambil data.
class JadwalRepository {

    // === (READ) Untuk Beranda Murid ===
    Future<List<JadwalLesModel>> getJadwalUntukBerandaMurid() async {
        try {
            final response = await ApiService.get('jadwal/all');
            
            if (response['success'] == true) {
                List<JadwalLesModel> jadwalList = (response['data'] as List)
                    .map((item) => JadwalLesModel.fromJson(item))
                    .toList();
                return jadwalList;
            } else {
                // Gunakan pesan dari API jika gagal
                throw Exception(response['message'] ?? 'Gagal memuat jadwal.');
            }
        } catch (e) {
            print("Error getJadwalUntukBerandaMurid: $e");
            throw Exception('Gagal memuat jadwal: $e');
        }
    }
    
    // === (READ) Untuk Dropdown "Pilih Mapel" Guru ===
    Future<List<GuruMapelModel>> getMapelMilikGuru(String guruId) async {
        try {
            final response = await ApiService.get('guru-data/mapel-saya/$guruId');
            
            if (response['success'] == true) {
                List<GuruMapelModel> mapelList = (response['data'] as List)
                    .map((item) => GuruMapelModel.fromJson(item))
                    .toList();
                return mapelList;
            } else {
                throw Exception(response['message'] ?? 'Gagal memuat daftar mapel guru.');
            }
        } catch (e) {
            print("Error getMapelMilikGuru: $e");
            throw Exception('Gagal memuat daftar mapel guru: $e');
        }
    }
    
    // === (READ) Untuk "Jadwal Saya" di Beranda Guru ===
    Future<List<Map<String, dynamic>>> getJadwalMilikGuru(String guruId) async {
        try {
            final response = await ApiService.get('jadwal/guru/$guruId');
            
            if (response['success'] == true) {
                // Perkuat casting dari List<dynamic> ke List<Map<String, dynamic>>
                List<Map<String, dynamic>> jadwalList = 
                    (response['data'] as List).cast<Map<String, dynamic>>();
                return jadwalList;
            } else {
                throw Exception(response['message'] ?? 'Gagal memuat jadwal milik guru.');
            }
        } catch (e) {
            print("Error getJadwalMilikGuru: $e");
            throw Exception('Gagal memuat jadwal milik guru: $e');
        }
    }

    // -----------------------------------------------------------------
    // === (CREATE) Untuk Guru Menambah Jadwal ===
    // -----------------------------------------------------------------
    Future<Map<String, dynamic>> createJadwal({
        required int idGuruMapel, 
        required String hari,
        required String jamMulai, 
        required String jamSelesai, 
    }) async {
        final data = {
            'id_gurumapel': idGuruMapel,
            'hari': hari,
            'jam_mulai': jamMulai, 
            'jam_selesai': jamSelesai,
        };
        // Asumsi endpoint CREATE adalah POST
        return await ApiService.post('jadwal/create', data);
    }

    // -----------------------------------------------------------------
    // === (DELETE) Untuk Guru Menghapus Jadwal ===
    // -----------------------------------------------------------------
    Future<Map<String, dynamic>> deleteJadwal({
        required int jadwalId,
        required String guruIdPemilik, 
    }) async {
        // Asumsi API membutuhkan guru_id_pemilik sebagai verifikasi dalam body
        final data = {'guru_id_pemilik': guruIdPemilik};
        // Asumsi endpoint DELETE adalah POST dengan ID di URL
        return await ApiService.post('jadwal/delete/$jadwalId', data);
    }
    
    // -----------------------------------------------------------------
    // === (UPDATE STATUS) Untuk fitur Checklist ===
    // -----------------------------------------------------------------
    Future<Map<String, dynamic>> updateJadwalStatus({
        required int jadwalId,
        required bool newStatus, 
        required String guruIdPemilik, 
    }) async {
        // API endpoint untuk mengubah status is_booked
        final data = {
            'guru_id_pemilik': guruIdPemilik, // Untuk verifikasi keamanan
            'is_booked': newStatus ? 1 : 0, // Mengirim 1 atau 0 ke API
        };
        // Asumsi endpoint STATUS adalah POST/PUT ke URL jadwal/status/ID
        return await ApiService.post('jadwal/status/$jadwalId', data);
    }

    // -----------------------------------------------------------------
    // === (UPDATE DATA) Untuk Guru Mengubah Jadwal ===
    // -----------------------------------------------------------------
    Future<Map<String, dynamic>> updateJadwal({
        required int jadwalId,
        required int idGuruMapel, // Ditambahkan ke body data
        required String hari,
        required String jamMulai,
        required String jamSelesai, 
    }) async {
        final data = {
            'id_gurumapel': idGuruMapel, 
            'hari': hari,
            'jam_mulai': jamMulai,
            'jam_selesai': jamSelesai,
        };
        // Asumsi endpoint UPDATE DATA adalah POST/PUT ke URL jadwal/update/ID
        return await ApiService.post('jadwal/update/$jadwalId', data);
    }
}