import 'package:equatable/equatable.dart';

abstract class Guru extends Equatable {
  final String name;
  final String gelar;
  final String level;
  final int price;
  final double rating;
  final String photo;
  final String kota;
  final String mapel;
  final String noTelepon;
  final String pengalaman;
  final String deskripsi;
  final String? cvUrl;
  final bool isApproved;

  const Guru({
    required this.name,
    required this.gelar,
    required this.level,
    required this.price,
    required this.rating,
    required this.photo,
    required this.kota,
    required this.mapel,
    required this.noTelepon,
    required this.pengalaman,
    required this.deskripsi,
    this.cvUrl,
    this.isApproved = false,
  });

  @override
  String toString() {
    return "$name, $gelar ($level, $mapel di $kota) - Rp$price.000, Rating: $rating⭐, Telp: $noTelepon";
  }

  @override
  List<Object?> get props => [name, noTelepon, mapel];
}

class GuruSD extends Guru {
  const GuruSD({
    required super.name,
    required super.gelar,
    required super.price,
    required super.rating,
    required super.photo,
    required super.kota,
    required super.mapel,
    required super.noTelepon,
    required super.pengalaman,
    required super.deskripsi,
    super.cvUrl,
    super.isApproved,
  }) : super(level: "SD");
}

class GuruSMP extends Guru {
  const GuruSMP({
    required super.name,
    required super.gelar,
    required super.price,
    required super.rating,
    required super.photo,
    required super.kota,
    required super.mapel,
    required super.noTelepon,
    required super.pengalaman,
    required super.deskripsi,
    super.cvUrl,
    super.isApproved,
  }) : super(level: "SMP");
}

class GuruSMA extends Guru {
  const GuruSMA({
    required super.name,
    required super.gelar,
    required super.price,
    required super.rating,
    required super.photo,
    required super.kota,
    required super.mapel,
    required super.noTelepon,
    required super.pengalaman,
    required super.deskripsi,
    super.cvUrl,
    super.isApproved,
  }) : super(level: "SMA/SMK");
}
