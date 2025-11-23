import 'dart:convert';
import 'package:PRIVATE_AJA/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:PRIVATE_AJA/services/auth_service.dart';

// Import halaman terkait
import '../model/user_model.dart';
import 'edit_profil_guru.dart';
import 'pengaturan_guru.dart'; // <--- Kita akan buat file ini di bawah

class GuruProfilPage extends StatefulWidget {
  final UserModel user;
  const GuruProfilPage({super.key, required this.user});

  @override
  State<GuruProfilPage> createState() => _GuruProfilPageState();
}

class _GuruProfilPageState extends State<GuruProfilPage> {
  // --- STATE UNTUK PROFIL ---
  Map<String, dynamic>? _guruDetailData; // Data dari database
  bool _isLoadingDetail = true;

  // --- STATE UNTUK UPLOAD FOTO ---
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  static const Color mintHighlight = Color(0xFF3CB371);
  static const Color lightMintBackground = Color(0xFFF5FFFA);

  @override
  void initState() {
    super.initState();
    _fetchGuruDetail();
  }

  // 1. AMBIL DATA DETAIL
  Future<void> _fetchGuruDetail() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiService.getBaseUrl}/api/profile/detail/${widget.user.id}',
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (mounted) {
          setState(() {
            _guruDetailData = jsonResponse['data'];
            _isLoadingDetail = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingDetail = false);
      }
    } catch (e) {
      print("Error fetch: $e");
      if (mounted) setState(() => _isLoadingDetail = false);
    }
  }

  // 2. FUNGSI UPLOAD FOTO
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
        setState(() {
          widget.user.foto_profil_guru = result['url'];
        });
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
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.grey[900] : lightMintBackground;
    final cardColor = isDarkMode ? Colors.grey[800]! : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        actions: [
          // --- TOMBOL MENU PENGATURAN (GERIGI) ---
          IconButton(
            icon: Icon(Icons.settings, color: textColor),
            tooltip: "Pengaturan Akun",
            onPressed: () {
              // Navigasi ke Halaman Pengaturan
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. Header Profil (Foto & Nama)
            _buildProfileHeader(textColor),

            const SizedBox(height: 20),

            // 2. Statistik (Pengalaman & Harga)
            if (_isLoadingDetail)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_guruDetailData != null) ...[
              _buildStatsRow(cardColor, textColor),
              const SizedBox(height: 20),
              _buildBioSection(cardColor, textColor),
            ] else
              const Center(child: Text("Gagal memuat data profil.")),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

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
                child: CircularProgressIndicator(color: Colors.white),
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
            IconButton(
              icon: const Icon(Icons.edit_note, color: Colors.blue),
              onPressed: () async {
                if (_guruDetailData == null) return;
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilGuruPage(
                      user: widget.user,
                      currentData: _guruDetailData!,
                    ),
                  ),
                );
                if (result == true) {
                  setState(() => _isLoadingDetail = true);
                  _fetchGuruDetail();
                }
              },
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
          _statItem(
            "Pengalaman",
            "${_guruDetailData?['pengalaman_tahun'] ?? 0} Thn",
            textColor,
          ),
          Container(height: 40, width: 1, color: Colors.grey.shade300),
          _statItem(
            "Tarif/Jam",
            "Rp ${_guruDetailData?['harga_per_jam'] ?? 0}",
            textColor,
          ),
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

  Widget _buildBioSection(Color cardColor, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tentang Saya",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _guruDetailData?['bio_deskripsi'] ?? "Belum ada deskripsi.",
            style: TextStyle(color: textColor.withAlpha(200), height: 1.5),
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),

          Text(
            "Mata Pelajaran",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: (_guruDetailData?['list_mapel'] ?? "")
                .toString()
                .split(', ')
                .map<Widget>((mapel) {
                  if (mapel.trim().isEmpty) return const SizedBox();
                  return Chip(
                    label: Text(mapel, style: const TextStyle(fontSize: 12)),
                    backgroundColor: mintHighlight.withOpacity(0.1),
                  );
                })
                .toList(),
          ),
        ],
      ),
    );
  }
}
