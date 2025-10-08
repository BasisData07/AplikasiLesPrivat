import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'model/guru_model.dart';
import 'model/user_model.dart';
import 'home_page.dart';

class DetailGuruPage extends StatelessWidget {
  final Guru guru;
  final bool isDarkMode;
  // --- PERUBAHAN 1: Tipe data diubah menjadi List<Guru> ---
  final List<Guru> favoriteTeachers;
  final UserModel user;

  const DetailGuruPage({
    super.key,
    required this.guru,
    required this.isDarkMode,
    this.favoriteTeachers = const [],
    required this.user,
  });

  ImageProvider getImage(String path) {
    try {
      return path.startsWith('http')
          ? NetworkImage(path)
          : AssetImage(path) as ImageProvider;
    } catch (e) {
      return const AssetImage("assets/panda.png"); // Fallback image
    }
  }

  Future<void> _launchCV(BuildContext context) async {
    if (guru.cvUrl != null && guru.cvUrl!.isNotEmpty) {
      final Uri url = Uri.parse(guru.cvUrl!);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tidak dapat membuka ${guru.cvUrl}')),
          );
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CV untuk guru ini belum tersedia.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? Colors.grey[900] : const Color(0xFFF9F9F9);
    final cardColor = isDarkMode ? Colors.grey[850] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.grey[600];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "Profil Guru",
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      // ... Isi dari body tetap sama, tidak ada perubahan di sini
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 45, backgroundImage: getImage(guru.photo)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guru.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        guru.gelar,
                        style: TextStyle(fontSize: 16, color: subTextColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildStatsCard(cardColor, textColor, subTextColor),
            const SizedBox(height: 24),
            _buildSectionTitle("Tentang Guru", textColor),
            const SizedBox(height: 8),
            Text(
              guru.deskripsi,
              style: TextStyle(fontSize: 15, height: 1.5, color: subTextColor),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle("Informasi Detail", textColor),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.school_outlined,
              "Tingkat",
              guru.level,
              subTextColor,
              textColor,
            ),
            const Divider(height: 16),
            _buildInfoRow(
              Icons.book_outlined,
              "Mata Pelajaran",
              guru.mapel,
              subTextColor,
              textColor,
            ),
            const Divider(height: 16),
            _buildInfoRow(
              Icons.location_city_outlined,
              "Domisili",
              guru.kota,
              subTextColor,
              textColor,
            ),
            const Divider(height: 16),
            _buildInfoRow(
              Icons.phone_outlined,
              "No. Telepon",
              guru.noTelepon,
              subTextColor,
              textColor,
            ),
            const Divider(height: 16),
            _buildTappableInfoRow(
              Icons.description_outlined,
              "Lihat CV Guru",
              subTextColor,
              () => _launchCV(context),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBookingButton(context),
    );
  }

  // ... Widget-widget helper lainnya (_buildSectionTitle, _buildStatsCard, dll) tetap sama
  // ... Tidak perlu disalin ulang karena tidak ada perubahan

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  Widget _buildStatsCard(
    Color? cardColor,
    Color textColor,
    Color? subTextColor,
  ) {
    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildRatingStatItem(guru.rating, textColor, subTextColor),
            _buildStatItem(
              Icons.work_outline,
              guru.pengalaman.split(' ').first,
              "Tahun Pengalaman",
              textColor,
              subTextColor,
            ),
            _buildStatItem(
              Icons.price_change_outlined,
              "Rp ${guru.price}K",
              "/ Jam",
              textColor,
              subTextColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStatItem(
    double rating,
    Color textColor,
    Color? subTextColor,
  ) {
    Color getRatingColor(double rating) {
      if (rating >= 4.5) return Colors.green;
      if (rating >= 3.5) return Colors.lightGreen;
      if (rating >= 2.5) return Colors.amber;
      if (rating > 0) return Colors.orange;
      return Colors.grey;
    }

    return Column(
      children: [
        Icon(
          rating > 0 ? Icons.star : Icons.star_border,
          color: rating > 0 ? getRatingColor(rating) : Colors.grey,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          rating > 0 ? rating.toString() : "Baru",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text("Rating", style: TextStyle(fontSize: 12, color: subTextColor)),
      ],
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color textColor,
    Color? subTextColor,
  ) {
    return Column(
      children: [
        Icon(icon, color: Colors.pinkAccent, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: subTextColor)),
      ],
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String title,
    String value,
    Color? subTextColor,
    Color textColor,
  ) {
    return Row(
      children: [
        Icon(icon, color: subTextColor, size: 20),
        const SizedBox(width: 16),
        Text(title, style: TextStyle(fontSize: 15, color: subTextColor)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTappableInfoRow(
    IconData icon,
    String title,
    Color? subTextColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
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

  // --- PERUBAHAN UTAMA ADA DI FUNGSI INI ---
  Widget _buildBookingButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: () {
          // Cek apakah guru sudah ada di daftar favorit
          // Kita anggap nama guru unik untuk pengecekan ini
          bool isAlreadyFavorite = favoriteTeachers.any(
            (favGuru) => favGuru.name == guru.name,
          );

          if (isAlreadyFavorite) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Guru ini sudah ada di daftar favorit Anda."),
                backgroundColor: Colors.orange,
              ),
            );
            return; // Hentikan eksekusi jika sudah favorit
          }

          // --- PERUBAHAN 2: Tambahkan objek 'guru' langsung, bukan Map ---
          final updatedFavorites = [
            ...favoriteTeachers,
            guru, // Cukup tambahkan objek guru
          ];

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Guru telah ditambahkan ke favorit!"),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => MyHomePage(
                user: user,
                initialIndex: 1, // Langsung ke halaman favorit
                favoriteTeachers:
                    updatedFavorites, // Kirim list yang sudah diupdate
              ),
            ),
            (route) => route.isFirst,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink[700],
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.favorite_border),
        label: const Text(
          "Tambahkan ke Favorit",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
