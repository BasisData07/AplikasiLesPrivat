// lib/repositories/jadwal_repository.dart

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
    required String jamSelesai,
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

// [DIHAPUS] Definisi class GuruMapelModel dihapus dari sini