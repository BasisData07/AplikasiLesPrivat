import 'package:flutter/material.dart';
import 'model/user_model.dart';
import 'model/guru_model.dart'; // <-- TAMBAHKAN IMPORT INI
import 'detail_guru.dart'; // <-- TAMBAHKAN IMPORT INI

class FavoritPage extends StatefulWidget {
  final UserModel user;
  final bool isDarkMode;
  // --- UBAH TIPE DATA DI SINI ---
  final List<Guru> favoriteTeachers;

  const FavoritPage({
    super.key,
    required this.user,
    required this.isDarkMode,
    this.favoriteTeachers = const [],
  });

  @override
  State<FavoritPage> createState() => _FavoritPageState();
}

class _FavoritPageState extends State<FavoritPage> {
  // Letakkan di dalam class _FavoritPageState di file favorit.dart

  ImageProvider getImage(String path) {
    try {
      // Cek jika path adalah URL atau path aset lokal
      return path.startsWith('http')
          ? NetworkImage(path)
          : AssetImage(path) as ImageProvider;
    } catch (e) {
      // Gambar default jika terjadi error atau path tidak valid
      return const AssetImage("assets/panda.png");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDarkMode
        ? Colors.grey[900]
        : const Color.fromARGB(255, 246, 146, 179);
    final cardColor = widget.isDarkMode ? Colors.grey[850] : Colors.white;
    final borderColor = widget.isDarkMode
        ? Colors.pinkAccent
        : Colors.transparent;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Guru Favorit", style: TextStyle(color: textColor)),
        backgroundColor: bgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: widget.favoriteTeachers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: subTextColor),
                  const SizedBox(height: 16),
                  Text(
                    "Belum ada guru favorit.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: textColor),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: widget.favoriteTeachers.length,
              itemBuilder: (context, index) {
                // 'guru' sekarang adalah objek Guru, bukan Map
                final guru = widget.favoriteTeachers[index];

                // --- DIBUNGKUS DENGAN INKWELL AGAR BISA DI-KLIK ---
                return InkWell(
                  onTap: () {
                    // Navigasi ke halaman detail saat item di-klik
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailGuruPage(
                          guru: guru, // Kirim objek guru lengkap
                          isDarkMode: widget.isDarkMode,
                          user: widget.user,
                          favoriteTeachers: widget.favoriteTeachers,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Card(
                    color: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: borderColor, width: 1.2),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      // KODE BARU YANG SUDAH DIPERBAIKI ✅
                      leading: CircleAvatar(
                        radius: 28, // Anda bisa sesuaikan ukurannya
                        backgroundColor: Colors.grey[300],
                        // Gunakan backgroundImage untuk memuat foto dari data guru
                        backgroundImage: getImage(guru.photo),
                      ),
                      title: Text(
                        // Akses properti langsung dari objek guru
                        "${guru.name} (${guru.level})",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      subtitle: Text(
                        // Akses properti langsung dari objek guru
                        "Alamat: ${guru.kota}\nTelp: ${guru.noTelepon}",
                        style: TextStyle(color: subTextColor),
                      ),
                      trailing: Text(
                        // Akses properti langsung dari objek guru
                        "⭐ ${guru.rating}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: widget.isDarkMode
                              ? Colors.amber
                              : Colors.pink[900],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
