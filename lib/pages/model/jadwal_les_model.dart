// lib/models/jadwal_les_model.dart

class JadwalLesModel {
  final int jadwalId;
  final String hari;
  final String jamMulai;
  final String jamSelesai;
  final String namaGuru;
  final String emailGuru; 
  final String namaMapel;
  final String kota;
  final String level;
  final bool isBooked;

  JadwalLesModel({
    required this.jadwalId,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.namaGuru,
    required this.emailGuru,
    required this.namaMapel,
    required this.kota,
    required this.level,
    required this.isBooked,
  });
  
  String get jam {
        return '$jamMulai - $jamSelesai';
    }

  factory JadwalLesModel.fromJson(Map<String, dynamic> json) {
    
    final int? isBookedValue = json['is_booked'] as int?;
    
    return JadwalLesModel(
      jadwalId: json['jadwal_id'],
      hari: json['hari'],
      jamMulai: json['jam_mulai'],
      jamSelesai: json['jam_selesai'],
      namaGuru: json['nama_guru'],
      emailGuru: json['email_guru'] as String? ?? '',
      namaMapel: json['nama_mapel'],
      kota: json['kota'] ?? '', 
      level: json['level'] ?? 'Semua',
      isBooked: isBookedValue == 1,
    );
  }
}