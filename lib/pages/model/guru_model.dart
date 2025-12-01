// lib/model/guru_model.dart

import 'package:equatable/equatable.dart';

abstract class Guru extends Equatable {
    final String idGuru;
    final String nama;
    final String email; 
    final String kategori_jenjang; 
    final int harga; 
    final double rating;
    final String foto; 
    final String kota;
    final String mapel;
    final String noTelepon;
    final String pengalaman;
    final String deskripsi;
    final String? cvUrl;

    const Guru({
        required this.idGuru,
        required this.nama, 
        required this.email, 
        required this.kategori_jenjang, 
        required this.harga, 
        required this.rating,
        required this.foto, 
        required this.kota,
        required this.mapel,
        required this.noTelepon,
        required this.pengalaman,
        required this.deskripsi,
        this.cvUrl,
    });

    @override
    String toString() {
        return "$nama, ($kategori_jenjang, $mapel di $kota) - Rp$harga.000, Rating: $rating⭐, Telp: $noTelepon";
    }
    
    @override
    String get id => idGuru;

    @override
    List<Object?> get props => [nama, email, noTelepon, mapel];
}

class GuruSD extends Guru {
    const GuruSD({
        required super.idGuru,
        required super.nama,
        required super.email, 
        required super.harga, 
        required super.rating,
        required super.foto, 
        required super.kota,
        required super.mapel,
        required super.noTelepon,
        required super.pengalaman,
        required super.deskripsi,
        super.cvUrl,
    }) : super(kategori_jenjang: "SD");
}

class GuruSMP extends Guru {
    const GuruSMP({
        required super.idGuru,
        required super.nama,
        required super.email, 
        required super.harga,
        required super.rating,
        required super.foto,
        required super.kota,
        required super.mapel,
        required super.noTelepon,
        required super.pengalaman,
        required super.deskripsi,
        super.cvUrl,
    }) : super(kategori_jenjang: "SMP");
}

class GuruSMA extends Guru {
    const GuruSMA({
        required super.idGuru,
        required super.nama,
        required super.email, 
        required super.harga,
        required super.rating,
        required super.foto,
        required super.kota,
        required super.mapel,
        required super.noTelepon,
        required super.pengalaman,
        required super.deskripsi,
        super.cvUrl,
    }) : super(kategori_jenjang: "SMA");
}

class GuruMahasiswa extends Guru {
    const GuruMahasiswa({
        required super.idGuru,
        required super.nama,
        required super.email, 
        required super.harga,
        required super.rating,
        required super.foto,
        required super.kota,
        required super.mapel,
        required super.noTelepon,
        required super.pengalaman,
        required super.deskripsi,
        super.cvUrl,
    }) : super(kategori_jenjang: "Mahasiswa");
}