import 'package:flutter/material.dart';
import '../model/user_model.dart';
// Hapus import http & dart:convert, ganti dengan service
import '../../services/guru_service.dart';

class EditProfilGuruPage extends StatefulWidget {
  final UserModel user;
  final Map<String, dynamic> currentData;

  const EditProfilGuruPage({
    super.key,
    required this.user,
    required this.currentData,
  });

  @override
  State<EditProfilGuruPage> createState() => _EditProfilGuruPageState();
}

class _EditProfilGuruPageState extends State<EditProfilGuruPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  late TextEditingController _bioController;
  late TextEditingController _pengalamanController;
  late TextEditingController _hargaController;
  late TextEditingController _domisiliController;
  late TextEditingController _telponController;
  late TextEditingController _instansiController;
  late TextEditingController _posisiController;

  // Logic Jenjang
  final List<String> _opsiJenjang = ["SD", "SMP", "SMA", "MAHASISWA"];
  List<String> _selectedJenjang = [];

  static const Color mintColor = Color(0xFF3CB371);

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    _bioController = TextEditingController(
      text: widget.currentData['bio_deskripsi'] ?? '',
    );
    _pengalamanController = TextEditingController(
      text: widget.currentData['pengalaman_tahun']?.toString() ?? '0',
    );
    _hargaController = TextEditingController(
      text: widget.currentData['harga_per_jam']?.toString() ?? '0',
    );
    _domisiliController = TextEditingController(
      text: widget.currentData['domisili'] ?? '',
    );
    _telponController = TextEditingController(
      text: widget.currentData['no_telpon']?.toString() ?? '',
    );
    _instansiController = TextEditingController(
      text: widget.currentData['nama_instansi'] ?? '',
    );
    _posisiController = TextEditingController(
      text: widget.currentData['posisi'] ?? '',
    );

    String jenjangString = widget.currentData['list_jenjang'] ?? "";
    if (jenjangString.isNotEmpty) {
      _selectedJenjang = jenjangString
          .split(',')
          .map((e) => e.trim())
          .where((e) => _opsiJenjang.contains(e))
          .toList();
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _pengalamanController.dispose();
    _hargaController.dispose();
    _domisiliController.dispose();
    _telponController.dispose();
    _instansiController.dispose();
    _posisiController.dispose();
    super.dispose();
  }

   //--- FUNGSI SIMPAN (JADI SANGAT RINGKAS) ---
  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // 1. Siapkan Data
    final dataToSend = {
      "bio_deskripsi": _bioController.text,
      "pengalaman_tahun": _pengalamanController.text,
      "harga_per_jam": _hargaController.text,
      "domisili": _domisiliController.text,
      "no_telpon": _telponController.text,
      "nama_instansi": _instansiController.text,
      "posisi": _posisiController.text,
      "jenjang": _selectedJenjang.join(", "),
    };

    // 2. Panggil Service (Pelayan)
    final result = await GuruService.updateProfil(widget.user.id.toString(), dataToSend);

    if (!mounted) return;
    setState(() => _isLoading = false);

    // 3. Cek Hasil
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil berhasil diperbarui!"), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true); // Kembali & Refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (KODE UI BUILD SAMA PERSIS SEPERTI SEBELUMNYA) ...
    // ... Copy paste bagian build() dari kode sebelumnya, tidak ada yang berubah di UI ...

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profil"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Informasi Dasar"),
              const SizedBox(height: 15),
              _buildTextField(
                label: "Domisili / Kota",
                controller: _domisiliController,
                icon: Icons.location_city,
                hint: "Contoh: Surabaya",
              ),
              _buildTextField(
                label: "Nomor WhatsApp",
                controller: _telponController,
                icon: Icons.phone,
                inputType: TextInputType.phone,
              ),

              const SizedBox(height: 25),

              _sectionTitle("Latar Belakang"),
              const SizedBox(height: 15),
              _buildTextField(
                label: "Nama Instansi / Universitas",
                controller: _instansiController,
                icon: Icons.school,
                hint: "Contoh: Universitas Brawijaya",
              ),
              _buildTextField(
                label: "Posisi / Jurusan",
                controller: _posisiController,
                icon: Icons.work_outline,
                hint: "Contoh: Pendidikan Matematika",
              ),

              const SizedBox(height: 25),

              _sectionTitle("Detail Pengajaran"),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: "Pengalaman (Thn)",
                      controller: _pengalamanController,
                      inputType: TextInputType.number,
                      icon: Icons.history,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildTextField(
                      label: "Harga/Jam (Rp)",
                      controller: _hargaController,
                      inputType: TextInputType.number,
                      icon: Icons.attach_money,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),
              const Text(
                "Tingkat yang diajar:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                children: _opsiJenjang.map((jenjang) {
                  final isSelected = _selectedJenjang.contains(jenjang);
                  return FilterChip(
                    label: Text(jenjang),
                    selected: isSelected,
                    selectedColor: mintColor.withOpacity(0.2),
                    checkmarkColor: mintColor,
                    labelStyle: TextStyle(
                      color: isSelected ? mintColor : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedJenjang.add(jenjang);
                        } else {
                          _selectedJenjang.remove(jenjang);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: _bioController,
                maxLines: 5,
                maxLength: 500,
                decoration: InputDecoration(
                  labelText: "Tentang Saya (Bio)",
                  hintText: "Ceritakan metode mengajar Anda...",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mintColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "SIMPAN PERUBAHAN",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    TextInputType inputType = TextInputType.text,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon != null
              ? Icon(icon, size: 20, color: Colors.grey)
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
        ),
        validator: (val) =>
            (val == null || val.isEmpty) ? "$label tidak boleh kosong" : null,
      ),
    );
  }
}
