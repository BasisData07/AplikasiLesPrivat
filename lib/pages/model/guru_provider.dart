// lib/model/guru_provider.dart

import 'package:flutter/material.dart';
import '../model/guru_model.dart';

class GuruProvider with ChangeNotifier {
  List<Guru> _guruList = [
    // --- PERBAIKAN: Menambahkan field 'email' pada setiap guru ---
    GuruSD(
      name: "Anisa Putri",
      email: "anisa.putri@email.com", // <-- EMAIL DITAMBAHKAN
      gelar: "S.Pd.",
      price: 55,
      rating: 4.8,
      photo: "assets/guru/guru1.jpg", // Pastikan path asset benar
      kota: "Jakarta Selatan",
      mapel: "Tematik & Calistung",
      noTelepon: "0812-1111-2222",
      pengalaman: "4 tahun mengajar di sekolah dasar internasional.",
      deskripsi:
          "Lulusan PGSD Universitas Negeri Jakarta. Sabar dan ahli dalam membuat anak-anak semangat belajar melalui metode bermain.",
      cvUrl:
          "https://drive.google.com/file/d/1lf08OAgq07kF8FwjmhY0R0tPMdxzUy52/view?usp=drive_link",
      isApproved: true,
    ),
    GuruSMP(
      name: "Citra Dewi",
      email: "citra.dewi@email.com", // <-- EMAIL DITAMBAHKAN
      gelar: "M.Pd.",
      price: 65,
      rating: 4.7,
      photo: "assets/guru/guru2.jpg", // Pastikan path asset benar
      kota: "Surabaya",
      mapel: "Matematika",
      noTelepon: "0814-3333-4444",
      pengalaman:
          "6 tahun pengalaman, spesialis persiapan Ujian Nasional dan masuk SMA favorit.",
      deskripsi:
          "Master Pendidikan Matematika dari Unesa. Dikenal dengan metode mengajar yang terstruktur dan mudah dipahami, membantu siswa meningkatkan nilai secara signifikan.",
      cvUrl:
          "https://drive.google.com/file/d/1lf08OAgq07kF8FwjmhY0R0tPMdxzUy52/view?usp=drive_link",
      isApproved: true,
    ),
    GuruSMA(
      name: "Eka Wijaya",
      email: "eka.wijaya@email.com", // <-- EMAIL DITAMBAHKAN
      gelar: "M.Si.",
      price: 85,
      rating: 5.0,
      photo: "assets/guru/guru3.jpg", // Pastikan path asset benar
      kota: "Yogyakarta",
      mapel: "Fisika",
      noTelepon: "0816-5555-6666",
      pengalaman:
          "7 tahun menjadi guru Fisika dan pembimbing olimpiade tingkat nasional.",
      deskripsi:
          "Lulusan S2 Fisika UGM. Memiliki passion untuk membuat Fisika menjadi pelajaran yang menyenangkan dan bukan sekadar rumus. Sangat direkomendasikan untuk persiapan UTBK.",
      cvUrl:
          "https://drive.google.com/file/d/1lf08OAgq07kF8FwjmhY0R0tPMdxzUy52/view?usp=drive_link",
      isApproved: true,
    ),
  ];

  List<Guru> get guruList => _guruList;

  void tambahGuru(Guru guru) {
    _guruList = [..._guruList, guru];
    notifyListeners();
  }

  void hapusGuru(Guru guru) {
    _guruList = _guruList.where((g) => g != guru).toList();
    notifyListeners();
  }

  void updateGuru(Guru guruLama, Guru guruBaru) {
    final index = _guruList.indexOf(guruLama);
    if (index != -1) {
      final newList = List<Guru>.from(_guruList);
      newList[index] = guruBaru;
      _guruList = newList;
      notifyListeners();
    }
  }

  void approveGuru(Guru guru) {
    final index = _guruList.indexOf(guru);
    if (index == -1) return;

    final oldGuru = _guruList[index];
    Guru newApprovedGuru;

    // --- PERBAIKAN: Menambahkan 'email' saat membuat objek guru baru ---
    if (oldGuru.level == "SD") {
      newApprovedGuru = GuruSD(
        name: oldGuru.name,
        email: oldGuru.email, // <-- EMAIL DITAMBAHKAN
        gelar: oldGuru.gelar,
        price: oldGuru.price,
        rating: oldGuru.rating,
        photo: oldGuru.photo,
        kota: oldGuru.kota,
        mapel: oldGuru.mapel,
        noTelepon: oldGuru.noTelepon,
        pengalaman: oldGuru.pengalaman,
        deskripsi: oldGuru.deskripsi,
        cvUrl: oldGuru.cvUrl,
        isApproved: true,
      );
    } else if (oldGuru.level == "SMP") {
      newApprovedGuru = GuruSMP(
        name: oldGuru.name,
        email: oldGuru.email, // <-- EMAIL DITAMBAHKAN
        gelar: oldGuru.gelar,
        price: oldGuru.price,
        rating: oldGuru.rating,
        photo: oldGuru.photo,
        kota: oldGuru.kota,
        mapel: oldGuru.mapel,
        noTelepon: oldGuru.noTelepon,
        pengalaman: oldGuru.pengalaman,
        deskripsi: oldGuru.deskripsi,
        cvUrl: oldGuru.cvUrl,
        isApproved: true,
      );
    } else {
      newApprovedGuru = GuruSMA(
        name: oldGuru.name,
        email: oldGuru.email, // <-- EMAIL DITAMBAHKAN
        gelar: oldGuru.gelar,
        price: oldGuru.price,
        rating: oldGuru.rating,
        photo: oldGuru.photo,
        kota: oldGuru.kota,
        mapel: oldGuru.mapel,
        noTelepon: oldGuru.noTelepon,
        pengalaman: oldGuru.pengalaman,
        deskripsi: oldGuru.deskripsi,
        cvUrl: oldGuru.cvUrl,
        isApproved: true,
      );
    }

    final newList = List<Guru>.from(_guruList);
    newList[index] = newApprovedGuru;
    _guruList = newList;
    notifyListeners();
  }
}