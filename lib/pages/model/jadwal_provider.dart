// lib/pages/model/jadwal_provider.dart

import 'package:flutter/material.dart';
import 'jadwal_model.dart';

class JadwalProvider extends ChangeNotifier {
  final Map<String, List<JadwalSlot>> _jadwalDatabase = {
    'anisa.putri@email.com': [
      JadwalSlot(hari: "Senin", tanggal: "27 Okt 2025", jam: "15:00 - 16:00"),
      JadwalSlot(hari: "Senin", tanggal: "27 Okt 2025", jam: "16:00 - 17:00", isBooked: true),
      JadwalSlot(hari: "Selasa", tanggal: "28 Okt 2025", jam: "15:00 - 16:00"),
    ],
    'citra.dewi@email.com': [
      JadwalSlot(hari: "Rabu", tanggal: "29 Okt 2025", jam: "19:00 - 20:00"),
    ],
    'eka.wijaya@email.com': [
       JadwalSlot(hari: "Jumat", tanggal: "31 Okt 2025", jam: "14:00 - 15:00", isBooked: true),
    ]
  };

  List<JadwalSlot> getJadwalForGuru(String guruEmail) {
    _jadwalDatabase.putIfAbsent(guruEmail, () => []);
    return _jadwalDatabase[guruEmail]!;
  }

  void toggleJadwalStatus(String guruEmail, int jadwalIndex) {
    if (_jadwalDatabase.containsKey(guruEmail)) {
      final jadwalGuru = _jadwalDatabase[guruEmail]!;
      if (jadwalIndex >= 0 && jadwalIndex < jadwalGuru.length) {
        jadwalGuru[jadwalIndex].isBooked = !jadwalGuru[jadwalIndex].isBooked;
        notifyListeners();
      }
    }
  }

  // --- FUNGSI YANG HILANG ADA DI SINI ---
  // Tambahkan fungsi ini ke dalam kelas JadwalProvider Anda
  void tambahJadwal(String guruEmail, JadwalSlot jadwalBaru) {
    // Pastikan list untuk guru tersebut ada
    _jadwalDatabase.putIfAbsent(guruEmail, () => []);
    
    // Tambahkan jadwal baru ke list
    _jadwalDatabase[guruEmail]!.add(jadwalBaru);
    
    // Beri tahu UI untuk update
    notifyListeners();
  }
}