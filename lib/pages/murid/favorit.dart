import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../model/guru_model.dart';
import '../murid/detail_guru.dart';

class FavoritPage extends StatefulWidget {
  final UserModel user;
  final bool isDarkMode;
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
  // Palet warna tema hijau mint
  static const Color mintHighlight = Color(0xFF3CB371);
  static const Color lightMintBackground = Color(0xFFF5FFFA);

  ImageProvider getImage(String path) {
    try {
      return path.startsWith('http')
          ? NetworkImage(path)
          : AssetImage(path) as ImageProvider;
    } catch (e) {
      return const AssetImage("assets/panda.png");
    }
  }

  @override
  Widget build(BuildContext context) {
    // WARNA DIUBAH DI SINI
    final bgColor = widget.isDarkMode ? Colors.grey[900] : lightMintBackground;
    final cardColor = widget.isDarkMode ? Colors.grey[850] : Colors.white;
    final borderColor = widget.isDarkMode ? mintHighlight : Colors.transparent;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.grey[700];

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
                    style: TextStyle(fontSize: 16, color: subTextColor),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: widget.favoriteTeachers.length,
              itemBuilder: (context, index) {
                final guru = widget.favoriteTeachers[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailGuruPage(
                          guru: guru,
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
                      side: BorderSide(color: borderColor.withAlpha(90), width: 1),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: getImage(guru.photo),
                      ),
                      title: Text(
                        "${guru.name} (${guru.level})",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      subtitle: Text(
                        "Alamat: ${guru.kota}\nTelp: ${guru.noTelepon}",
                        style: TextStyle(color: subTextColor, height: 1.4),
                      ),
                      trailing: Text(
                        "⭐ ${guru.rating}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          // WARNA DIUBAH DI SINI
                          color: widget.isDarkMode
                              ? Colors.amber
                              : mintHighlight,
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