import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/guru_model.dart';
import '../model/guru_provider.dart';

class EditGuruPage extends StatefulWidget {
  final Guru guru;
  final bool isDarkMode;

  const EditGuruPage({super.key, required this.guru, required this.isDarkMode});

  @override
  State<EditGuruPage> createState() => _EditGuruPageState();
}

class _EditGuruPageState extends State<EditGuruPage> {
  final _namaController = TextEditingController();
  final _gelarController =
      TextEditingController(); // Note: Backend might not support 'gelar' update? profile.js doesn't show it.
  final _noTeleponController = TextEditingController();
  final _mapelController =
      TextEditingController(); // Note: Will map to 'subject' or 'list_mapel'
  final _alamatController = TextEditingController();
  final _hargaController = TextEditingController();
  final _pengalamanController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _photoController = TextEditingController(); // Note: URL update only
  final _cvUrlController = TextEditingController();
  final _instansiController = TextEditingController();
  final _posisiController = TextEditingController();

  late String _selectedLevel;
  final List<String> _levels = ["SD", "SMP", "SMA/SMK", "Mahasiswa"];

  // Palet Warna Tema (Simple fallback)
  static const Color mintHighlight = Colors.blue;
  static const Color lightMintBackground = Colors.white;

  @override
  void initState() {
    super.initState();
    _namaController.text = widget.guru.nama;
    // _gelarController.text = widget.guru.gelar; // Guru model has no 'gelar' field in abstract!
    // Wait, let's check Guru model again.
    // abstract class Guru ... no 'gelar'. But subclasses might?
    // GuruSD has 'gelar'. Abstract Guru has 'nama', 'email', 'harga', 'rating', 'foto', 'kota', 'mapel', 'noTelepon', 'pengalaman', 'deskripsi', 'cvUrl'.
    // It does NOT have 'gelar'. The subclasses verify 'super.gelar' is NOT there?
    // In guru_model.dart:48 `class GuruSD extends Guru ... required super.nama ...`
    // It actually DOES NOT have 'gelar' in the super constructor calls!
    // Looking at guru_model.dart again (Step 80)...
    // `class GuruSD extends Guru { const GuruSD({...}) : super(...) }`
    // No 'gelar' property in GuruSD either!
    // So 'gelar' is likely invalid. I will comment it out or remove it.

    _noTeleponController.text = widget.guru.noTelepon;
    _mapelController.text = widget.guru.mapel;
    _alamatController.text = widget.guru.kota;
    _hargaController.text = widget.guru.harga.toString();
    _pengalamanController.text = widget.guru.pengalaman;
    _deskripsiController.text = widget.guru.deskripsi;
    _photoController.text = widget.guru.foto;
    _cvUrlController.text = widget.guru.cvUrl ?? '';
    _instansiController.text = widget.guru.instansi;
    _posisiController.text = widget.guru.posisi;

    // Level logic
    if (widget.guru is GuruSD)
      _selectedLevel = "SD";
    else if (widget.guru is GuruSMP)
      _selectedLevel = "SMP";
    else if (widget.guru is GuruSMA)
      _selectedLevel = "SMA/SMK";
    else
      _selectedLevel = "Mahasiswa";
  }

  @override
  void dispose() {
    _namaController.dispose();
    _gelarController.dispose();
    _noTeleponController.dispose();
    _mapelController.dispose();
    _alamatController.dispose();
    _hargaController.dispose();
    _pengalamanController.dispose();
    _deskripsiController.dispose();
    _photoController.dispose();
    _cvUrlController.dispose();
    _instansiController.dispose();
    _posisiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Menyesuaikan warna dengan tema
    final bgColor = widget.isDarkMode ? Colors.grey[900] : lightMintBackground;
    final cardColor = widget.isDarkMode ? Colors.grey[850] : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Data Guru"),
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.white,
      ),
      body: Container(
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
                    "Mengubah Data: ${widget.guru.nama}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(_namaController, "Nama Lengkap", textColor),
                  // _buildTextField(_gelarController, "Gelar (e.g., S.Pd.)", textColor), // Removed
                  _buildTextField(
                      _noTeleponController, "No. Telepon", textColor,
                      keyboardType: TextInputType.phone),
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
                      _mapelController, "Mata Pelajaran Utama", textColor),
                  _buildTextField(
                      _alamatController, "Kota Domisili", textColor),
                  _buildTextField(
                      _hargaController, "Tarif per Jam (Rp)", textColor,
                      keyboardType: TextInputType.number),
                  _buildTextField(_pengalamanController,
                      "Pengalaman (e.g., 5 tahun)", textColor),
                  _buildTextField(
                      _deskripsiController, "Deskripsi Singkat", textColor,
                      maxLines: 3),
                  _buildTextField(
                      _photoController, "URL Foto Profil", textColor),
                  _buildTextField(_instansiController,
                      "Instansi (e.g. Universitas X)", textColor),
                  _buildTextField(_posisiController,
                      "Posisi (e.g. Dosen, Mahasiswa)", textColor),
                  // _buildTextField(_cvUrlController, "URL CV Google Drive", textColor),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mintHighlight,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      "Simpan Perubahan",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    onPressed: _updateForm,
                  ),
                ],
              ),
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
      fillColor:
          widget.isDarkMode ? Colors.grey[800] : Colors.white.withOpacity(0.8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.orangeAccent, width: 2),
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

  void _updateForm() async {
    final nama = _namaController.text;
    final alamat = _alamatController.text;
    final mapel = _mapelController.text;
    final noTelepon = _noTeleponController.text;
    final pengalaman = _pengalamanController.text;
    final deskripsi = _deskripsiController.text;
    final harga = int.tryParse(_hargaController.text) ?? 0;
    final photo = _photoController.text;
    // final cvUrl = _cvUrlController.text;

    if (nama.isEmpty || alamat.isEmpty || mapel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("Nama, Kota, dan Mapel tidak boleh kosong!"),
        ),
      );
      return;
    }

    // Creating updated model to pass to logic (though we just need IDs and Fields)
    Guru updatedGuru;

    final instansi = _instansiController.text;
    final posisi = _posisiController.text;

    // Helper to create object
    if (_selectedLevel == "SD") {
      updatedGuru = GuruSD(
        idGuru: widget.guru.idGuru,
        email: widget.guru.email,
        nama: nama,
        harga: harga,
        rating: widget.guru.rating,
        foto: photo,
        kota: alamat,
        mapel: mapel,
        noTelepon: noTelepon,
        pengalaman: pengalaman,
        deskripsi: deskripsi,
        // cvUrl: cvUrl,
        instansi: instansi,
        posisi: posisi,
      );
    } else if (_selectedLevel == "SMP") {
      updatedGuru = GuruSMP(
        idGuru: widget.guru.idGuru,
        email: widget.guru.email,
        nama: nama,
        harga: harga,
        rating: widget.guru.rating,
        foto: photo,
        kota: alamat,
        mapel: mapel,
        noTelepon: noTelepon,
        pengalaman: pengalaman,
        deskripsi: deskripsi,
        instansi: instansi,
        posisi: posisi,
      );
    } else if (_selectedLevel == "SMA/SMK") {
      updatedGuru = GuruSMA(
        idGuru: widget.guru.idGuru,
        email: widget.guru.email,
        nama: nama,
        harga: harga,
        rating: widget.guru.rating,
        foto: photo,
        kota: alamat,
        mapel: mapel,
        noTelepon: noTelepon,
        pengalaman: pengalaman,
        deskripsi: deskripsi,
        instansi: instansi,
        posisi: posisi,
      );
    } else {
      updatedGuru = GuruMahasiswa(
        idGuru: widget.guru.idGuru,
        email: widget.guru.email,
        nama: nama,
        harga: harga,
        rating: widget.guru.rating,
        foto: photo,
        kota: alamat,
        mapel: mapel,
        noTelepon: noTelepon,
        pengalaman: pengalaman,
        deskripsi: deskripsi,
        instansi: instansi,
        posisi: posisi,
      );
    }

    try {
      await context.read<GuruProvider>().updateGuru(widget.guru, updatedGuru);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Data guru berhasil diperbarui!"),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
}
