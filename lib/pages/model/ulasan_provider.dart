import 'package:flutter/material.dart';
import 'ulasan_model.dart';

class UlasanProvider with ChangeNotifier {
  final List<UlasanModel> _ulasanList = [];

  List<UlasanModel> get ulasanList => _ulasanList;

  void tambahUlasan(UlasanModel ulasan) {
    _ulasanList.insert(0, ulasan);
    notifyListeners();
  }
}
