// lib/pages/guru/model/guru_mapel_model.dart

class GuruMapelModel {
  final int idGuruMapel; // <-- Ini yang akan disimpan di 'jadwal_les'
  final String namaMapel; // <-- Ini yang dilihat guru di dropdown

  GuruMapelModel({required this.idGuruMapel, required this.namaMapel});

  factory GuruMapelModel.fromJson(Map<String, dynamic> json) {
    return GuruMapelModel(
   idGuruMapel: json['id_gurumapel'],
    namaMapel: json['nama_mapel'],
);
  }
}