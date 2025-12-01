// lib/models/ulasan_model.dart

class UlasanModel {
    final int ulasanId;
    final double rating;
    final String komentarMurid; // dari kolom 'komentar' di DB
    final String namaMurid;     // dari join tabel murid (asumsi 'nama_murid' di JSON)
    final String? balasanGuru;  // dari kolom 'balasan_guru' di JSON (nullable)
    final DateTime createdAt;

    UlasanModel({
        required this.ulasanId,
        required this.rating,
        required this.komentarMurid,
        required this.namaMurid,
        this.balasanGuru,
        required this.createdAt,
    });

    factory UlasanModel.fromJson(Map<String, dynamic> json) {
        final rawRating = json['rating']; // Bisa berupa int atau double
        //final rawRating = (json['rating'] as num?)?.toDouble() ?? 0.0;
        final rawDate = json['created_at'] as String? ?? DateTime.now().toIso8601String();
        
        double parsedRating;

        if (rawRating is String) {
            // Jika rating datang sebagai String ("5.0"), parse ke double
            parsedRating = double.tryParse(rawRating) ?? 0.0;
        } else if (rawRating is num) {
            // Jika rating datang sebagai num (int atau double), konversi ke double
            parsedRating = rawRating.toDouble();
        } else {
            parsedRating = 0.0;
        }

        return UlasanModel(
            ulasanId: json['ulasan_id'] as int? ?? 0,
            rating: parsedRating,
            komentarMurid: json['komentar'] as String? ?? 'Tidak ada komentar',
            // Asumsi backend mengembalikan 'nama_murid' dari tabel akun_murid/akun_pengguna
            namaMurid: json['nama_murid'] as String? ?? 'Murid Anonim', 
            balasanGuru: json['balasan_guru'] as String?, // Ini bisa null
            createdAt: DateTime.tryParse(rawDate) ?? DateTime.now(),
        );
    }
}