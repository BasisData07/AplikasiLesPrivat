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
    final listJenjang =
        g["list_jenjang"]; // Ini string, tapi kita pakai untuk jenjangModel
    final String namaLengkap = g["nama_lengkap"]?.toString() ?? 'Anonim';
    final String emailGuru = g["email"]?.toString() ?? '';
    final String noTelepon = g["no_telpon"]?.toString() ?? 'N/A';
    final String pengalamanTahun = g["pengalaman_tahun"]?.toString() ?? '';
    final String kota = g["domisili"]?.toString() ?? 'Tidak diketahui';
    final String mapel = g["list_mapel"]?.toString() ?? 'Umum';
    final String deskripsi = g["deskripsi"]?.toString() ?? '';
    final String cvUrl = g["file_sertifikat"]?.toString() ?? '';

    // New Fields for Admin
    final String instansi = g["nama_instansi"]?.toString() ?? '-';
    final String posisi = g["posisi"]?.toString() ?? '-';

    // 1. Ambil jenjang pertama
    final rawJenjang =
        listJenjang != null ? listJenjang.split(', ')[0] : "Semua";

    final jenjangModel = rawJenjang.toUpperCase();

    // Konversi tipe data numerik
    int harga = 0;
    // Cek key 'harga' atau 'harga_per_jam'
    final rawHarga = g["harga"] ?? g["harga_per_jam"];
    if (rawHarga != null) {
      // Ubah ke string, hapus semua karakter selain angka
      String cleanHarga = rawHarga.toString().replaceAll(RegExp(r'[^0-9]'), '');
      harga = int.tryParse(cleanHarga) ?? 0;
    }

    double rating = 0.0;
    if (g["rating"] != null) {
      if (g["rating"] is num) {
        rating = (g["rating"] as num).toDouble();
      } else if (g["rating"] is String) {
        rating = double.tryParse(g["rating"]) ?? 0.0;
      }
    }

    // Pemrosesan URL Foto
    String fotoGuru = g["foto_profil_guru"]?.toString() ?? 'default_avatar.png';
    if (!fotoGuru.startsWith('http') && !fotoGuru.startsWith('assets')) {
      fotoGuru = ApiService.ApiService.baseImgUrl + fotoGuru;
    }

    // MEMBANGUN MODEL DENGAN FIELD BARU
    switch (jenjangModel) {
      // JENJANG MODEL SUDAH UPPERCASE
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
          instansi: instansi,
          posisi: posisi,
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
          instansi: instansi,
          posisi: posisi,
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
          instansi: instansi,
          posisi: posisi,
        );

      case "MAHASISWA":
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
          instansi: instansi,
          posisi: posisi,
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
          instansi: instansi,
          posisi: posisi,
        );
    }
  }

  // =======================================================
  // 🔥 UPDATE GURU (Admin Feature)
  // =======================================================
  Future<void> updateGuru(Guru oldData, Guru newData) async {
    isLoading = true;
    notifyListeners();

    try {
      final data = {
        'nama_lengkap': newData.nama, // Requires backend update
        'bio_deskripsi': newData.deskripsi,
        'pengalaman_tahun': newData.pengalaman,
        'no_telpon': newData.noTelepon,
        'domisili': newData.kota,
        'harga_per_jam': newData.harga.toString(),
        'jenjang': newData.kategori_jenjang,
        'nama_instansi': newData.instansi,
        'posisi': newData.posisi,
      };

      final response = await ApiService.ApiService.put(
          '$apiEndpoint/update-info/${newData.idGuru}', data);

      if (response['success'] == true) {
        // Update local list
        final index = _guruList.indexWhere((g) => g.idGuru == newData.idGuru);
        if (index != -1) {
          _guruList[index] = newData;
        }
        await fetchGuruList(); // Refresh to be sure
      } else {
        throw Exception(response['message'] ?? 'Gagal update guru');
      }
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
