import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'model/guru_model.dart';
import 'model/guru_provider.dart';

class EditGuruPage extends StatefulWidget {
  final Guru guru; // Menerima data guru yang akan diedit
  final bool isDarkMode;

  const EditGuruPage({super.key, required this.guru, required this.isDarkMode});

  @override
  State<EditGuruPage> createState() => _EditGuruPageState();
}

class _EditGuruPageState extends State<EditGuruPage> {
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

  late String _selectedLevel;
  final List<String> _levels = ["SD", "SMP", "SMA/SMK"];

  @override
  void initState() {
    super.initState();
    // Mengisi semua form dengan data guru yang ada saat halaman pertama kali dibuka
    _namaController.text = widget.guru.name;
    _gelarController.text = widget.guru.gelar;
    _noTeleponController.text = widget.guru.noTelepon;
    _mapelController.text = widget.guru.mapel;
    _alamatController.text = widget.guru.kota;
    _hargaController.text = widget.guru.price.toString();
    _pengalamanController.text = widget.guru.pengalaman;
    _deskripsiController.text = widget.guru.deskripsi;
    _photoController.text = widget.guru.photo;
    _cvUrlController.text = widget.guru.cvUrl ?? '';
    _selectedLevel = widget.guru.level;
  }

  @override
  void dispose() {
    // Membersihkan controller untuk mencegah kebocoran memori (memory leak)
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDarkMode
        ? Colors.grey[900]
        : const Color(0xFFF692B3);
    final cardColor = widget.isDarkMode
        ? Colors.grey[850]
        : const Color(0xFFFFD2E1);
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Data Guru"),
        backgroundColor: Colors.blue[700],
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
                    "Mengubah Data: ${widget.guru.name}",
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
                  _buildTextField(
                    _alamatController,
                    "Kota Domisili",
                    textColor,
                  ),
                  _buildTextField(
                    _hargaController,
                    "Tarif per Jam",
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
                      backgroundColor:
                          Colors.blue[700], // Warna berbeda untuk tombol update
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

  // Helper Widgets (Tidak ada perubahan)
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
        borderSide: const BorderSide(color: Colors.blue, width: 2),
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

  // Fungsi untuk menyimpan perubahan data
  void _updateForm() {
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

    if (nama.isEmpty || alamat.isEmpty || mapel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("Nama, Alamat, dan Mapel tidak boleh kosong!"),
        ),
      );
      return;
    }

    Guru updatedGuru;

    // Membuat objek Guru BARU dengan data yang sudah diupdate
    if (_selectedLevel == "SD") {
      updatedGuru = GuruSD(
        name: nama,
        gelar: gelar,
        price: harga,
        rating: widget.guru.rating,
        photo: photo,
        kota: alamat,
        mapel: mapel,
        noTelepon: noTelepon,
        pengalaman: pengalaman,
        deskripsi: deskripsi,
        cvUrl: cvUrl,
        isApproved: widget.guru.isApproved, // Pertahankan status approval
      );
    } else if (_selectedLevel == "SMP") {
      updatedGuru = GuruSMP(
        name: nama,
        gelar: gelar,
        price: harga,
        rating: widget.guru.rating,
        photo: photo,
        kota: alamat,
        mapel: mapel,
        noTelepon: noTelepon,
        pengalaman: pengalaman,
        deskripsi: deskripsi,
        cvUrl: cvUrl,
        isApproved: widget.guru.isApproved,
      );
    } else {
      updatedGuru = GuruSMA(
        name: nama,
        gelar: gelar,
        price: harga,
        rating: widget.guru.rating,
        photo: photo,
        kota: alamat,
        mapel: mapel,
        noTelepon: noTelepon,
        pengalaman: pengalaman,
        deskripsi: deskripsi,
        cvUrl: cvUrl,
        isApproved: widget.guru.isApproved,
      );
    }

    // Memanggil fungsi update dari provider, mengirim data lama dan data baru
    context.read<GuruProvider>().updateGuru(widget.guru, updatedGuru);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text("Data guru berhasil diperbarui!"),
      ),
    );

    // Kembali ke halaman admin setelah update berhasil
    Navigator.of(context).pop();
  }
}
