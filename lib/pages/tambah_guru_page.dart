// lib/pages/tambah_guru_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'model/guru_model.dart';
import 'model/guru_provider.dart';

class TambahGuruPage extends StatefulWidget {
  final bool isDarkMode;

  const TambahGuruPage({super.key, required this.isDarkMode});

  @override
  State<TambahGuruPage> createState() => _TambahGuruPageState();
}

class _TambahGuruPageState extends State<TambahGuruPage> {
  // --- Text Editing Controllers ---
  final _namaController = TextEditingController();
  final _gelarController = TextEditingController();
  final _noTeleponController = TextEditingController();
  final _mapelController = TextEditingController();
  final _alamatController = TextEditingController();
  final _hargaController = TextEditingController();
  final _pengalamanController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _photoController = TextEditingController();
  final _cvUrlController = TextEditingController();

  String _selectedLevel = "SD";
  final List<String> _levels = ["SD", "SMP", "SMA/SMK"];

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDarkMode
        ? Colors.grey[900]
        : const Color(0xFFF692B3);
    final cardColor = widget.isDarkMode
        ? Colors.grey[850]
        : const Color(0xFFFFD2E1);
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;

    return Container(
      color: bgColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: cardColor,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Form Pendaftaran Guru",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 24),

                _buildTextField(_namaController, "Nama Lengkap", textColor),
                _buildTextField(
                  _gelarController,
                  "Gelar (e.g., S.Pd.)",
                  textColor,
                ),
                _buildTextField(
                  _noTeleponController,
                  "No. Telepon",
                  textColor,
                  keyboardType: TextInputType.phone,
                ),

                DropdownButtonFormField<String>(
                  value: _selectedLevel,
                  decoration: _inputDecoration("Level Mengajar", textColor),
                  dropdownColor: cardColor,
                  items: _levels.map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text(level, style: TextStyle(color: textColor)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedLevel = value);
                  },
                ),
                const SizedBox(height: 12),

                _buildTextField(
                  _mapelController,
                  "Mata Pelajaran Utama",
                  textColor,
                ),
                _buildTextField(_alamatController, "Kota Domisili", textColor),
                _buildTextField(
                  _hargaController,
                  "Tarif per Jam (contoh: 50)",
                  textColor,
                  keyboardType: TextInputType.number,
                ),
                _buildTextField(
                  _pengalamanController,
                  "Pengalaman (e.g., 5 tahun)",
                  textColor,
                ),
                _buildTextField(
                  _deskripsiController,
                  "Deskripsi Singkat",
                  textColor,
                  maxLines: 3,
                ),
                _buildTextField(
                  _photoController,
                  "URL Foto Profil (Opsional)",
                  textColor,
                ),
                _buildTextField(
                  _cvUrlController,
                  "URL CV Google Drive (Opsional)",
                  textColor,
                ),

                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink[700],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
                  label: const Text(
                    "Tambahkan Guru",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  onPressed: _submitForm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, Color textColor) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: textColor.withAlpha(204)),
      filled: true,
      fillColor: widget.isDarkMode ? Colors.grey[800] : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.pink, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    Color textColor, {
    TextInputType? keyboardType,
    int? maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        decoration: _inputDecoration(label, textColor),
        style: TextStyle(color: textColor),
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }

  void _submitForm() {
    final nama = _namaController.text;
    final gelar = _gelarController.text;
    final alamat = _alamatController.text;
    final mapel = _mapelController.text;
    final noTelepon = _noTeleponController.text;
    final pengalaman = _pengalamanController.text;
    final deskripsi = _deskripsiController.text;
    final harga = int.tryParse(_hargaController.text) ?? 0;
    final photo = _photoController.text;
    final cvUrl = _cvUrlController.text;

    if (nama.isEmpty ||
        gelar.isEmpty ||
        alamat.isEmpty ||
        mapel.isEmpty ||
        noTelepon.isEmpty ||
        pengalaman.isEmpty ||
        deskripsi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("Mohon isi semua kolom yang wajib!"),
        ),
      );
      return;
    }

    Guru guru;
    if (_selectedLevel == "SD") {
      guru = GuruSD(
        name: nama,
        gelar: gelar,
        price: harga,
        rating: 0.0,
        photo: photo,
        kota: alamat,
        mapel: mapel,
        noTelepon: noTelepon,
        pengalaman: pengalaman,
        deskripsi: deskripsi,
        cvUrl: cvUrl,
      );
    } else if (_selectedLevel == "SMP") {
      guru = GuruSMP(
        name: nama,
        gelar: gelar,
        price: harga,
        rating: 0.0,
        photo: photo,
        kota: alamat,
        mapel: mapel,
        noTelepon: noTelepon,
        pengalaman: pengalaman,
        deskripsi: deskripsi,
        cvUrl: cvUrl,
      );
    } else {
      guru = GuruSMA(
        name: nama,
        gelar: gelar,
        price: harga,
        rating: 0.0,
        photo: photo,
        kota: alamat,
        mapel: mapel,
        noTelepon: noTelepon,
        pengalaman: pengalaman,
        deskripsi: deskripsi,
        cvUrl: cvUrl,
      );
    }

    context.read<GuruProvider>().tambahGuru(guru);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text("Guru baru berhasil ditambahkan!"),
      ),
    );
    _namaController.clear();
    _gelarController.clear();
    _alamatController.clear();
    _mapelController.clear();
    _hargaController.clear();
    _photoController.clear();
    _noTeleponController.clear();
    _pengalamanController.clear();
    _deskripsiController.clear();
    _cvUrlController.clear(); //
    setState(() => _selectedLevel = "SD");
  }
}
