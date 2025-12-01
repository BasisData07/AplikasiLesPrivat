// lib/cadangan/guru_provider.dart

import 'package:PRIVATE_AJA/services/api_service.dart' as ApiService;
import 'package:flutter/material.dart';
import '../model/guru_model.dart'; 

class GuruProvider with ChangeNotifier {
    // =======================================================
    // 🔹 STATE MANAGEMENT
    // =======================================================
    List<Guru> _guruList = [];
    List<Guru> get guruList => _guruList;

    bool isLoading = false;
    String? errorMessage;
    final String apiEndpoint = "profile"; 

    // ... (Fungsi CRUD lainnya disisihkan untuk fokus pada mapping)
    
    // =======================================================
    // 🔥 FETCH SEMUA GURU DARI API
    // =======================================================
    Future<void> fetchGuruList() async {
        isLoading = true;
        errorMessage = null;
        notifyListeners();

        try {
            final response = await ApiService.ApiService.get('$apiEndpoint/detail');

            if (response['success'] != true) {
                errorMessage = response['message'] ?? "Gagal memuat data guru.";
                _guruList = []; 
            } else {
                List<dynamic> data = response["data"] ?? [];
                _guruList = data.map((g) => convertGuruFromJson(g)).toList();
            }
            
        } catch (e) {
            errorMessage = "Error Internal: ${e.toString()}";
            _guruList = [];
        } finally {
            isLoading = false;
            notifyListeners();
        }
    }
    
    // =======================================================
    // 🔥 CONVERT JSON → MODEL GURU (Mapping Backend ke Frontend)
    // =======================================================
    Guru convertGuruFromJson(Map<String, dynamic> g) {

        // --- KONVERSI KUAT UNTUK SEMUA FIELD STRING ---
        // Ini memastikan field INT (seperti ID atau no_telpon INT) dikonversi ke String
        final String guruId = g["id"]?.toString() ?? '';
        final listJenjang = g["list_jenjang"]; // Ini string, tapi kita pakai untuk jenjangModel
        final String namaLengkap = g["nama_lengkap"]?.toString() ?? 'Anonim';
        final String emailGuru = g["email"]?.toString() ?? '';
        final String noTelepon = g["no_telpon"]?.toString() ?? 'N/A';
        final String pengalamanTahun = g["pengalaman_tahun"]?.toString() ?? '';
        final String kota = g["domisili"]?.toString() ?? 'Tidak diketahui';
        final String mapel = g["list_mapel"]?.toString() ?? 'Umum';
        final String deskripsi = g["deskripsi"]?.toString() ?? '';
        final String cvUrl = g["file_sertifikat"]?.toString() ?? '';


        // 1. Ambil jenjang pertama
        final rawJenjang = listJenjang != null 
            ? listJenjang.split(', ')[0] 
            : "Semua";

        final jenjangModel = rawJenjang.toUpperCase(); 

        // Konversi tipe data numerik
        final harga = (g["harga"] is num) ? (g["harga"] as num).toInt() : 0;
        final rating = (g["rating"] is num) ? (g["rating"] as num).toDouble() : 0.0;
        
        // Pemrosesan URL Foto
        String fotoGuru = g["foto_profil_guru"]?.toString() ?? 'default_avatar.png'; 
        if (!fotoGuru.startsWith('http') && !fotoGuru.startsWith('assets')) {
            fotoGuru = ApiService.ApiService.baseImgUrl + fotoGuru;
        }

        // MEMBANGUN MODEL DENGAN FIELD BARU
        switch (jenjangModel) { // JENJANG MODEL SUDAH UPPERCASE
            case "SD":
                return GuruSD(
                    idGuru: guruId,
                    nama: namaLengkap, 
                    email: emailGuru, 
                    harga: harga, 
                    rating: rating,
                    foto: fotoGuru, 
                    kota: kota, 
                    mapel: mapel, 
                    noTelepon: noTelepon, 
                    pengalaman: pengalamanTahun, 
                    deskripsi: deskripsi, 
                    cvUrl: cvUrl, 
                );

            case "SMP":
                return GuruSMP(
                    idGuru: guruId,
                    nama: namaLengkap, 
                    email: emailGuru, 
                    harga: harga, 
                    rating: rating,
                    foto: fotoGuru, 
                    kota: kota, 
                    mapel: mapel, 
                    noTelepon: noTelepon, 
                    pengalaman: pengalamanTahun, 
                    deskripsi: deskripsi, 
                    cvUrl: cvUrl, 
                );

            case "SMA/SMK": // Menggunakan SMA/SMK karena modelnya GuruSMA
            case "SMA": // Menambahkan SMA untuk mencakup jenjang yang mungkin terpisah
                return GuruSMA(
                    idGuru: guruId,
                    nama: namaLengkap, 
                    email: emailGuru, 
                    harga: harga, 
                    rating: rating,
                    foto: fotoGuru, 
                    kota: kota, 
                    mapel: mapel, 
                    noTelepon: noTelepon, 
                    pengalaman: pengalamanTahun, 
                    deskripsi: deskripsi, 
                    cvUrl: cvUrl, 
                );

            case "Mahasiswa":
                return GuruMahasiswa(
                    idGuru: guruId,
                    nama: namaLengkap, 
                    email: emailGuru, 
                    harga: harga, 
                    rating: rating,
                    foto: fotoGuru, 
                    kota: kota, 
                    mapel: mapel, 
                    noTelepon: noTelepon, 
                    pengalaman: pengalamanTahun, 
                    deskripsi: deskripsi, 
                    cvUrl: cvUrl, 
                );
            
            default:
                // Fallback default
                return GuruSMA(
                    idGuru: guruId,
                    nama: namaLengkap, 
                    email: emailGuru, 
                    harga: harga, 
                    rating: rating,
                    foto: fotoGuru, 
                    kota: kota, 
                    mapel: mapel, 
                    noTelepon: noTelepon, 
                    pengalaman: pengalamanTahun, 
                    deskripsi: deskripsi, 
                    cvUrl: cvUrl, 
                );
        }
    }
}