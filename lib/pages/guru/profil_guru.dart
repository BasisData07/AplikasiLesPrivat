import 'dart:convert';
import 'package:PRIVATE_AJA/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:PRIVATE_AJA/services/auth_service.dart';

// Import halaman terkait
import '../model/user_model.dart';
import 'edit_profil_guru.dart';
import 'pengaturan_guru.dart';

class GuruProfilPage extends StatefulWidget {
  final UserModel user;
  const GuruProfilPage({super.key, required this.user});

  @override
  State<GuruProfilPage> createState() => _GuruProfilPageState();
}

class _GuruProfilPageState extends State<GuruProfilPage> {
  Map<String, dynamic>? _guruDetailData;
  bool _isLoadingDetail = true;

  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  static const Color mintHighlight = Color(0xFF3CB371);
  static const Color lightMintBackground = Color(0xFFF5FFFA);

  @override
  void initState() {
    super.initState();
    _fetchGuruDetail();
  }

  // 1. AMBIL DATA DETAIL & REFRESH
  Future<void> _fetchGuruDetail() async {
    if (!mounted) return;
    setState(() => _isLoadingDetail = true);
    try {
      final response = await http.get(
        Uri.parse('${ApiService.getBaseUrl}/profile/detail/${widget.user.id}'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (mounted) {
          setState(() {
            _guruDetailData = jsonResponse['data'];
          });
        }
      }
    } catch (e) {
      if (mounted) print("Error fetch: $e");
    } finally {
      if (mounted) setState(() => _isLoadingDetail = false);
    }
  }

  // 2. NAVIGASI KE EDIT PROFILE (Mendukung Refresh Otomatis)
  Future<void> _goToEditProfile() async {
    final initialData = _guruDetailData ?? {};

    // Menunggu hasil dari halaman edit
    final bool? shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditProfilGuruPage(user: widget.user, currentData: initialData),
      ),
    );

    // Cek apakah sinyal refresh diterima (true)
    if (shouldRefresh == true) {
      if (mounted) {
        // Langsung panggil refresh data
        await _fetchGuruDetail();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil berhasil diperbarui."),
            duration: Duration(seconds: 1),
            backgroundColor: mintHighlight,
          ),
        );
      }
    }
  }

  // 3. FUNGSI UPLOAD FOTO (Tidak Berubah)
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                _pickAndUploadImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Kamera'),
              onTap: () {
                _pickAndUploadImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (pickedFile == null) return;

    setState(() => _isUploading = true);
    final authService = AuthService();

    try {
      final result = await authService.uploadProfilePicture(
        pickedFile,
        widget.user.id.toString(),
      );

      if (result['success'] == true) {
        // Update state lokal dan panggil fetch data lagi
        await _fetchGuruDetail();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Foto berhasil diupdate!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Gagal"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.grey[900] : lightMintBackground;
    final cardColor = isDarkMode ? Colors.grey[800]! : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.grey[600];

    // --- Data yang ditampilkan ---
    final data = _guruDetailData;
    final String displayInstansi = data?['nama_instansi'] ?? "Belum diatur";
    final String displayPosisi = data?['posisi'] ?? "Belum diatur";
    final String displayJenjangString = data?['list_jenjang'] ?? "";
    final String displayMapelString = data?['list_mapel'] ?? "";

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Profil Saya", style: TextStyle(color: textColor)),
        backgroundColor: bgColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: textColor),
            tooltip: "Pengaturan Akun",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GuruPengaturanPage(user: widget.user),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchGuruDetail,
        child: _isLoadingDetail
            ? const Center(
                child: CircularProgressIndicator(color: mintHighlight),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 1. Header Profil (Foto & Nama)
                  _buildProfileHeader(textColor),

                  const SizedBox(height: 20),

                  // 2. Statistik (Pengalaman & Harga)
                  if (_guruDetailData != null) ...[
                    _buildStatsRow(cardColor, textColor),
                    const SizedBox(height: 20),
                    // --- DETAIL TAMBAHAN (Instansi & Posisi) ---
                    _buildSectionTitle("Latar Belakang", textColor),
                    const SizedBox(height: 8),
                    _buildDetailCard(
                      cardColor,
                      textColor,
                      subTextColor!,
                      displayInstansi,
                      displayPosisi,
                    ),
                    const SizedBox(height: 20),

                    // --- BIO ---
                    _buildSectionTitle("Tentang Saya", textColor),
                    const SizedBox(height: 8),
                    _buildBioText(cardColor, textColor),
                    const SizedBox(height: 20),

                    // --- JENJANG ---
                    _buildSectionTitle("Jenjang yang Diajar", textColor),
                    const SizedBox(height: 8),
                    _buildChips(
                      displayJenjangString,
                      mintHighlight.withOpacity(0.1),
                      textColor,
                    ),
                    const SizedBox(height: 20),

                    // --- MAPEL ---
                    _buildSectionTitle("Mata Pelajaran", textColor),
                    const SizedBox(height: 8),
                    _buildChips(
                      displayMapelString,
                      mintHighlight,
                      Colors.white,
                    ),
                    const SizedBox(height: 30),
                  ] else
                    const Center(child: Text("Gagal memuat data profil.")),
                ],
              ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String title,
    String value,
    Color? subTextColor,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: subTextColor, size: 20),
          const SizedBox(width: 16),
          Text(title, style: TextStyle(fontSize: 15, color: subTextColor)),
          const Spacer(),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget baru untuk menampilkan Instansi & Posisi
  Widget _buildDetailCard(
    Color cardColor,
    Color textColor,
    Color subTextColor,
    String instansi,
    String posisi,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.school_outlined,
            "Instansi",
            instansi,
            subTextColor,
            textColor,
          ),
          const Divider(height: 1),
          _buildInfoRow(
            Icons.work_outline,
            "Posisi/Jurusan",
            posisi,
            subTextColor,
            textColor,
          ),
        ],
      ),
    );
  }

  // Widget baru untuk menampilkan Bio
  Widget _buildBioText(Color cardColor, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _guruDetailData?['bio_deskripsi'] ?? "Belum ada deskripsi.",
        style: TextStyle(color: textColor.withAlpha(200), height: 1.5),
      ),
    );
  }

  // Widget untuk Chip (Jenjang/Mapel)
  Widget _buildChips(String listString, Color bgColor, Color labelColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: listString.split(', ').map<Widget>((item) {
        if (item.trim().isEmpty) return const SizedBox();
        return Chip(
          label: Text(item, style: TextStyle(fontSize: 12, color: labelColor)),
          backgroundColor: bgColor,
        );
      }).toList(),
    );
  }

  Widget _buildProfileHeader(Color textColor) {
    final bool hasImage =
        widget.user.foto_profil_guru != null &&
        widget.user.foto_profil_guru!.isNotEmpty;

    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: hasImage
                  ? NetworkImage(
                      widget.user.foto_profil_guru!.startsWith('http')
                          ? widget.user.foto_profil_guru!
                          : "${ApiService.baseImgUrl}${widget.user.foto_profil_guru!}",
                    )
                  : null,
              child: !hasImage
                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                  : null,
            ),
            if (_isUploading)
              const Positioned.fill(
                child: CircularProgressIndicator(color: mintHighlight),
              ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: mintHighlight,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                  onPressed: _isUploading ? null : _showImageSourceDialog,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Nama & Tombol Edit Profil
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.user.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            // Tombol Edit Info Profil
            IconButton(
              icon: const Icon(Icons.edit_note, color: Colors.blue),
              onPressed:
                  _goToEditProfile, // Memanggil fungsi navigasi yang mendukung refresh
            ),
          ],
        ),
        Text(
          _guruDetailData?['domisili'] ?? "Lokasi belum diatur",
          style: TextStyle(fontSize: 14, color: textColor.withAlpha(150)),
        ),
      ],
    );
  }

  Widget _buildStatsRow(Color cardColor, Color textColor) {
    // Pastikan data tidak null sebelum ditampilkan
    final String pengalaman =
        "${_guruDetailData?['pengalaman_tahun'] ?? 0} Thn";
    final String harga = "Rp ${_guruDetailData?['harga_per_jam'] ?? 0}";

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("Pengalaman", pengalaman, textColor),
          Container(height: 40, width: 1, color: Colors.grey.shade300),
          _statItem("Tarif/Jam", harga, textColor),
        ],
      ),
    );
  }

  Widget _statItem(String label, String val, Color textColor) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: mintHighlight,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: textColor.withAlpha(150)),
        ),
      ],
    );
  }
}
