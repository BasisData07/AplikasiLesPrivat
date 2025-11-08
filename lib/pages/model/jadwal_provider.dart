import 'dart:async';

import 'package:PRIVATE_AJA/pages/model/guru_mapel_model.dart';
import 'package:PRIVATE_AJA/pages/model/jadwal_les_model.dart';
import 'package:PRIVATE_AJA/repositories/jadwal-repositoris.dart';
import 'package:flutter/material.dart';
// Sesuaikan path-path ini dengan struktur folder Anda


// Provider adalah lapisan STATE. Ia MENYIMPAN data.
class JadwalProvider with ChangeNotifier {
  // Buat instance dari Repository
  final JadwalRepository _jadwalRepository = JadwalRepository();

  // --- State untuk Halaman "Jadwal Saya" (Guru) ---
  // Kita gunakan List<Map> karena datanya (dari 'getJadwalMilikGuru')
  // adalah data mentah yang spesifik untuk guru
  List<Map<String, dynamic>> _jadwalMilikGuru = [];
  bool _isLoadingJadwalGuru = false;
  
  List<Map<String, dynamic>> get jadwalMilikGuru => _jadwalMilikGuru;
  bool get isLoadingJadwalGuru => _isLoadingJadwalGuru;

  // --- State untuk Halaman "Buat Jadwal" (Guru) ---
  List<GuruMapelModel> _mapelMilikGuru = [];
  bool _isLoadingMapelGuru = false;

  List<GuruMapelModel> get mapelMilikGuru => _mapelMilikGuru;
  bool get isLoadingMapelGuru => _isLoadingMapelGuru;

  // --- State untuk Halaman Beranda Murid ---
  List<JadwalLesModel> _jadwalBeranda = [];
  bool _isLoadingBeranda = false;

  List<JadwalLesModel> get jadwalBeranda => _jadwalBeranda;
  bool get isLoadingBeranda => _isLoadingBeranda;

  // === Method untuk Halaman "Jadwal Saya" (Guru) ===
  Future<void> fetchJadwalMilikGuru(String guruId) async {
    _isLoadingJadwalGuru = true;
    notifyListeners();
    
    try {
      // Panggil Repository
      _jadwalMilikGuru = await _jadwalRepository.getJadwalMilikGuru(guruId);
    } catch (e) {
      print("Error fetchJadwalMilikGuru: $e");
      // Handle error, mungkin tampilkan pesan
    }
    
    _isLoadingJadwalGuru = false;
    notifyListeners();
  }

  // === Method untuk Halaman "Buat Jadwal" (Guru) ===
  Future<void> fetchMapelGuru(String guruId) async {
    _isLoadingMapelGuru = true;
    notifyListeners();
    
    try {
      _mapelMilikGuru = await _jadwalRepository.getMapelMilikGuru(guruId);
    } catch (e) {
      print("Error fetchMapelGuru: $e");
    }
    
    _isLoadingMapelGuru = false;
    notifyListeners();
  }
  
  // === Method (CREATE) ===
  Future<bool> createJadwalBaru({
    required int idGuruMapel, 
    required String hari,
    required String jamMulai, 
    required String jamSelesai, 
  }) async {
    try {
      final response = await _jadwalRepository.createJadwal(
        idGuruMapel: idGuruMapel,
        hari: hari,
        jamMulai: jamMulai,
        jamSelesai: jamSelesai,
      );
      // Jika sukses, refresh daftar jadwal
      if (response['success'] == true) {
        // Kita tidak bisa me-refresh karena kita tidak tahu 'guruId' di sini
        // Refresh akan dilakukan secara manual oleh UI
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // === Method (DELETE) ===
  Future<bool> deleteJadwal(int jadwalId, String guruIdPemilik) async {
    bool sukses = false;
    try {
      final response = await _jadwalRepository.deleteJadwal(
        jadwalId: jadwalId,
        guruIdPemilik: guruIdPemilik,
      );
      
      if (response['success'] == true) {
        // Jika sukses, HAPUS item dari list state
        _jadwalMilikGuru.removeWhere((jadwal) => jadwal['id'] == jadwalId);
        sukses = true;
      }
    } catch (e) {
      print("Error deleteJadwal: $e");
    }
    
    notifyListeners(); // Update UI
    return sukses;
  }

  // === Method untuk Halaman Beranda Murid ===
  Future<void> fetchJadwalUntukBeranda() async {
    _isLoadingBeranda = true;
    notifyListeners();

    try {
      // Panggil Repository
      _jadwalBeranda = await _jadwalRepository.getJadwalUntukBerandaMurid();
    } catch (e) {
      print("Error fetchJadwalUntukBeranda: $e");
      _jadwalBeranda = []; // Kosongkan list jika error
    }

    _isLoadingBeranda = false;
    notifyListeners();
  }

  getJadwalForGuru(String email) {}
}