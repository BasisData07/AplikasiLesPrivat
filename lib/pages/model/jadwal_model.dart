// lib/model/jadwal_model.dart

class JadwalSlot {
  final String hari;
  final String tanggal;
  final String jam;
  bool isBooked;

  JadwalSlot({
    required this.hari,
    required this.tanggal,
    required this.jam,
    this.isBooked = false,
  });
}