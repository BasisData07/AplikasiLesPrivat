// lib/models/jadwal_les_model.dart

class JadwalLesModel {
  final int jadwalId;
  final String hari;
  final String jamMulai;
  final String jamSelesai;
  final String namaGuru;
  final String namaMapel;

  JadwalLesModel({
    required this.jadwalId,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.namaGuru,
    required this.namaMapel,
  });

  factory JadwalLesModel.fromJson(Map<String, dynamic> json) {
    return JadwalLesModel(
      jadwalId: json['jadwal_id'],
      hari: json['hari'],
      jamMulai: json['jam_mulai'],
      jamSelesai: json['jam_selesai'],
      namaGuru: json['nama_guru'],
      namaMapel: json['nama_mapel'],
    );
  }
}