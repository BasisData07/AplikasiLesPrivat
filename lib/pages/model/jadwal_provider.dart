import 'dart:async';
import 'package:PRIVATE_AJA/pages/model/guru_mapel_model.dart';
import 'package:PRIVATE_AJA/pages/model/jadwal_les_model.dart';
import 'package:PRIVATE_AJA/repositories/jadwal-repositoris.dart';
import 'package:flutter/material.dart';

// Provider adalah lapisan STATE. Ia MENYIMPAN data dan menangani logika bisnis.
class JadwalProvider with ChangeNotifier {
    // Buat instance dari Repository (asumsi file ini ada)
    final JadwalRepository _jadwalRepository = JadwalRepository();

    // --- State untuk Halaman "Jadwal Saya" (Guru) ---
    List<Map<String, dynamic>> _jadwalMilikGuru = [];
    bool _isLoadingJadwalGuru = false;
    
    List<Map<String, dynamic>> get jadwalMilikGuru => _jadwalMilikGuru;
    bool get isLoadingJadwalGuru => _isLoadingJadwalGuru;

    // --- State untuk Halaman "Buat Jadwal" (Dropdown Mapel) ---
    List<GuruMapelModel> _mapelMilikGuru = [];
    bool _isLoadingMapelGuru = false;

    List<GuruMapelModel> get mapelMilikGuru => _mapelMilikGuru;
    bool get isLoadingMapelGuru => _isLoadingMapelGuru;

    // --- State untuk Halaman Beranda Murid (Contoh) ---
    List<JadwalLesModel> _jadwalBeranda = [];
    bool _isLoadingBeranda = false;

    List<JadwalLesModel> get jadwalBeranda => _jadwalBeranda;
    bool get isLoadingBeranda => _isLoadingBeranda;

    // -----------------------------------------------------------------
    // === READ METHODS ===
    // -----------------------------------------------------------------

    Future<void> fetchJadwalMilikGuru(String guruId) async {
        _isLoadingJadwalGuru = true;
        notifyListeners();
        
        try {
            _jadwalMilikGuru = await _jadwalRepository.getJadwalMilikGuru(guruId);
        } catch (e) {
            print("Error fetchJadwalMilikGuru: $e");
        }
        
        _isLoadingJadwalGuru = false;
        notifyListeners();
    }

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
    
    Future<void> fetchJadwalUntukBeranda() async {
        _isLoadingBeranda = true;
        notifyListeners();

        try {
            _jadwalBeranda = await _jadwalRepository.getJadwalUntukBerandaMurid();
        } catch (e) {
            print("Error fetchJadwalUntukBeranda: $e");
            _jadwalBeranda = []; 
        }

        _isLoadingBeranda = false;
        notifyListeners();
    }

    // -----------------------------------------------------------------
    // === CREATE METHOD ===
    // -----------------------------------------------------------------

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
            
            return response['success'] == true;
        } catch (e) {
            print("Error createJadwalBaru: $e");
            return false;
        }
    }

    // -----------------------------------------------------------------
    // === UPDATE METHODS (DIPERBAIKI) ===
    // -----------------------------------------------------------------

    Future<bool> updateJadwalStatus(int jadwalId, bool newStatus, String guruIdPemilik) async {
        bool sukses = false;
        try {
            // Panggil Repository untuk UPDATE STATUS (is_booked)
            final response = await _jadwalRepository.updateJadwalStatus(
                jadwalId: jadwalId,
                newStatus: newStatus,
                guruIdPemilik: guruIdPemilik,
            );
            
            if (response['success'] == true) {
                // Logika update lokal dihapus, kita biarkan UI yang me-fetch ulang
                sukses = true;
            }
        } catch (e) {
            print("Error updateJadwalStatus: $e");
        }
        
        // TIDAK perlu notifyListeners() di sini
        return sukses;
    }
    
    Future<bool> updateJadwal({
        required int jadwalId,
        required int idGuruMapel, 
        required String hari,
        required String jamMulai, 
        required String jamSelesai, 
    }) async {
        bool sukses = false;
        try {
            // Panggil Repository untuk UPDATE DATA
            final response = await _jadwalRepository.updateJadwal(
                jadwalId: jadwalId,
                idGuruMapel: idGuruMapel,
                hari: hari,
                jamMulai: jamMulai,
                jamSelesai: jamSelesai,
            );

            if (response['success'] == true) {
                // Logika update lokal dihapus, kita biarkan UI yang me-fetch ulang
                sukses = true;
            }
        } catch (e) {
            print("Error updateJadwal: $e");
        }
        // TIDAK perlu notifyListeners() di sini.
        return sukses;
    }

    // -----------------------------------------------------------------
    // === DELETE METHOD ===
    // -----------------------------------------------------------------

    Future<bool> deleteJadwal(int jadwalId, String guruIdPemilik) async {
        bool sukses = false;
        try {
            final response = await _jadwalRepository.deleteJadwal(
                jadwalId: jadwalId,
                guruIdPemilik: guruIdPemilik,
            );
            
            if (response['success'] == true) {
                // Jika sukses, HAPUS item dari list state secara lokal
                _jadwalMilikGuru.removeWhere((jadwal) => jadwal['jadwal_id'] == jadwalId); 
                sukses = true;
            }
        } catch (e) {
            print("Error deleteJadwal: $e");
        }
        
        notifyListeners(); // Update UI setelah delete lokal
        return sukses;
    }

    // -----------------------------------------------------------------
    // === UTILITY / LEGACY METHOD (DIPERBAIKI) ===
    // -----------------------------------------------------------------
    
    // 🔥 IMPLEMENTASI DARI UTILITY METHOD 🔥
    List<JadwalLesModel> getJadwalForGuru(String email) {
        // Mengambil jadwal yang sudah dimuat (_jadwalBeranda) berdasarkan email guru
        // ASUMSI: JadwalLesModel memiliki field 'emailGuru' (String)
        return _jadwalBeranda
          .where((jadwal) => jadwal.emailGuru.toLowerCase() == email.toLowerCase())
          .toList();
    }
}