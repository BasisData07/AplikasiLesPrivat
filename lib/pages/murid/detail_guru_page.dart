import 'package:PRIVATE_AJA/services/api_service.dart';
import 'package:PRIVATE_AJA/services/guru_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// --- HAPUS IMPORT HTTP & CONVERT ---

// --- TAMBAHKAN IMPORT SERVICE ---
import '../model/guru_model.dart';
import '../model/user_model.dart';
import '../model/jadwal_provider.dart';
import '../murid/home_page.dart';
import '../chat_page.dart';

class DetailGuruPage extends StatefulWidget {
  final Guru guru;
  final bool isDarkMode;
  final List<Guru> favoriteTeachers;
  final UserModel user;

  const DetailGuruPage({
    super.key,
    required this.guru,
    required this.isDarkMode,
    this.favoriteTeachers = const [],
    required this.user,
  });

  @override
  State<DetailGuruPage> createState() => _DetailGuruPageState();
}

class _DetailGuruPageState extends State<DetailGuruPage> {
  static const Color mintHighlight = Colors.orange;
  static const Color lightMintBackground = Color(0xFFF5FFFA);

  bool _isLoading = true;
  Map<String, dynamic>? _detailGuruData;
  
  @override
  void initState() {
    super.initState();
    _fetchGuruDetail();
  }

  // --- FUNGSI JADI LEBIH BERSIH ---
  Future<void> _fetchGuruDetail() async {
    // Panggil "Pelayan" (Service) untuk ambil data
    final data = await GuruService.getDetailGuru(widget.guru.id.toString());

    // Update Tampilan
    if (mounted) {
      setState(() {
        _detailGuruData = data; // Data bisa ada, bisa null
        _isLoading = false;     // Loading selesai
      });
    }
  }

  // Helper untuk gambar
  ImageProvider getImage(String? path) {
    if (path == null || path.isEmpty) {
      return const AssetImage("assets/panda.png");
    }
    try {
      if (path.startsWith('http')) {
        return NetworkImage(path);
      } else {
        if (path.contains("assets/")) {
          return AssetImage(path);
        }
        // Gunakan AppConfig.baseImgUrl
        return NetworkImage("${ApiService.baseImgUrl}$path");
      }
    } catch (e) {
      return const AssetImage("assets/panda.png");
    }
  }

  Future<void> _launchCV(BuildContext context) async {
    String? cvFile = _detailGuruData?['file_sertifikat'] ?? widget.guru.cvUrl;
    
    if (cvFile != null && cvFile.isNotEmpty) {
      // Gunakan AppConfig.baseImgUrl
      final String fullUrl = cvFile.startsWith('http') ? cvFile : "${ApiService.getBaseUrl}$cvFile";
      
      final Uri url = Uri.parse(fullUrl);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tidak dapat membuka dokumen')),
          );
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CV/Sertifikat guru belum tersedia.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (Kode Build Widget ke bawah SAMA PERSIS, tidak perlu diubah) ...
    // ... Copy paste sisa kode build dari jawaban sebelumnya ...
    
    final bgColor = widget.isDarkMode ? Colors.grey[900] : lightMintBackground;
    final cardColor = widget.isDarkMode ? Colors.grey[850] : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.grey[600];

    final String displayName = _detailGuruData?['nama_lengkap'] ?? widget.guru.name;
    final String displayBio = _detailGuruData?['bio_deskripsi'] ?? widget.guru.deskripsi;
    final String displayLokasi = _detailGuruData?['domisili'] ?? widget.guru.kota;
    final String displayTelpon = _detailGuruData?['no_telpon'] ?? widget.guru.noTelepon;
    final String displayPengalaman = "${_detailGuruData?['pengalaman_tahun'] ?? widget.guru.pengalaman} Thn";
    final String displayHarga = "Rp ${_detailGuruData?['harga_per_jam'] ?? widget.guru.price}";
    final String displayMapelString = _detailGuruData?['list_mapel'] ?? widget.guru.mapel;
    
    final String? displayFoto = _detailGuruData?['foto_profile_url'] ?? widget.guru.photo;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Profil Guru"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: _isLoading 
          ? Center(child: CircularProgressIndicator(color: mintHighlight))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 45, 
                        backgroundColor: Colors.grey[200],
                        backgroundImage: getImage(displayFoto)
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(displayName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 14, color: subTextColor),
                                Text(" $displayLokasi", style: TextStyle(fontSize: 14, color: subTextColor)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildStatsCard(cardColor, textColor, subTextColor, displayPengalaman, displayHarga),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Tentang Guru", textColor),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      displayBio.isEmpty ? "Guru belum mengisi deskripsi diri." : displayBio,
                      style: TextStyle(fontSize: 15, height: 1.5, color: textColor),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Mata Pelajaran", textColor),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: displayMapelString.split(', ').map((mapel) {
                       if(mapel.trim().isEmpty) return SizedBox();
                       return Chip(
                         label: Text(mapel, style: TextStyle(color: Colors.white)),
                         backgroundColor: mintHighlight,
                         padding: EdgeInsets.zero,
                       );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Informasi Detail", textColor),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.phone_outlined, "No. Telepon", displayTelpon, subTextColor, textColor),
                        const Divider(height: 1),
                        _buildTappableInfoRow(Icons.description_outlined, "Lihat CV / Sertifikat", subTextColor, () => _launchCV(context)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Jadwal Ketersediaan", textColor),
                  const SizedBox(height: 8),
                  _buildJadwalSection(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
      bottomNavigationBar: _buildActionButtons(context),
    );
  }

  // ... Widget Helper di bawahnya tetap sama ...
  Widget _buildJadwalSection(BuildContext context) {
    return Consumer<JadwalProvider>(
      builder: (context, jadwalProvider, child) {
        final jadwal = jadwalProvider.getJadwalForGuru(widget.guru.email);
        if (jadwal.isEmpty) {
          return Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text("Guru ini belum menyediakan jadwal.", style: TextStyle(color: Colors.grey))));
        }
        return Card(
          color: widget.isDarkMode ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 1,
          child: Column(
            children: jadwal.map((slot) {
              return ListTile(
                title: Text("${slot.hari}, ${slot.tanggal}", style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87)),
                subtitle: Text(slot.jam, style: TextStyle(color: Colors.grey)),
                trailing: Chip(
                  label: Text(slot.isBooked ? "Dipesan" : "Tersedia", style: TextStyle(color: Colors.white, fontSize: 12)),
                  backgroundColor: slot.isBooked ? Colors.redAccent : Colors.green,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor));
  }

  Widget _buildStatsCard(Color? cardColor, Color textColor, Color? subTextColor, String peng, String hrg) {
    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildRatingStatItem(widget.guru.rating, textColor, subTextColor),
            _buildStatItem(Icons.work_outline, peng, "Pengalaman", textColor, subTextColor),
            _buildStatItem(Icons.price_change_outlined, hrg, "/ Jam", textColor, subTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStatItem(double rating, Color textColor, Color? subTextColor) {
    return Column(
      children: [
        Icon(Icons.star, color: Colors.amber, size: 28),
        const SizedBox(height: 8),
        Text(rating.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 4),
        Text("Rating", style: TextStyle(fontSize: 12, color: subTextColor)),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color textColor, Color? subTextColor) {
    return Column(
      children: [
        Icon(icon, color: mintHighlight, size: 28),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: subTextColor)),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value, Color? subTextColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: subTextColor, size: 20),
          const SizedBox(width: 16),
          Text(title, style: TextStyle(fontSize: 15, color: subTextColor)),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildTappableInfoRow(IconData icon, String title, Color? subTextColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: subTextColor, size: 20),
            const SizedBox(width: 16),
            Text(title, style: TextStyle(fontSize: 15, color: subTextColor)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: subTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text("Chat Guru"),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(currentUserId: widget.user.username, peerId: widget.guru.email, peerName: widget.guru.name)));
              },
              style: OutlinedButton.styleFrom(foregroundColor: mintHighlight, side: const BorderSide(color: mintHighlight), minimumSize: const Size(0, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                bool isAlreadyFavorite = widget.favoriteTeachers.any((fav) => fav.email == widget.guru.email);
                if (isAlreadyFavorite) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sudah favorit!"))); return; }
                final updatedFavorites = [...widget.favoriteTeachers, widget.guru];
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MyHomePage(user: widget.user, initialIndex: 1, favoriteTeachers: updatedFavorites)), (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(backgroundColor: mintHighlight, foregroundColor: Colors.white, minimumSize: const Size(0, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              icon: const Icon(Icons.favorite_border),
              label: const Text("Favorit", style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}