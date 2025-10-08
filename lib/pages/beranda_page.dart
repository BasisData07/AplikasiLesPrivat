import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'model/guru_model.dart';
import 'model/user_model.dart';
import 'model/guru_provider.dart';
import 'detail_guru.dart';

class BerandaPage extends StatefulWidget {
  final UserModel user;
  final bool isDarkMode;
  final List<Guru> favoriteTeachers;

  const BerandaPage({
    super.key,
    required this.user,
    required this.isDarkMode,
    this.favoriteTeachers = const [],
  });

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  String _searchQuery = "";
  String _selectedLevel = "Semua"; // State untuk filter

  ImageProvider getImage(String path) {
    try {
      return path.startsWith('http')
          ? NetworkImage(path)
          : AssetImage(path) as ImageProvider;
    } catch (e) {
      return const AssetImage("assets/panda.png"); // Fallback image
    }
  }

  List<Guru> getRecommendedTeachers(List<Guru> guruList, String level) {
    return guruList.where((g) => g.level == level && g.rating >= 4.5).toList();
  }

  List<Guru> getNewTeachers(List<Guru> guruList) {
    return guruList.where((g) => g.rating == 0).toList();
  }

  List<Guru> getSearchResults(List<Guru> guruList) {
    final query = _searchQuery.toLowerCase();
    if (query.isEmpty) return [];
    return guruList.where((guru) {
      return guru.kota.toLowerCase().contains(query) ||
          guru.mapel.toLowerCase().contains(query) ||
          guru.name.toLowerCase().contains(query);
    }).toList();
  }

  // === UI WIDGETS ===

  Widget _buildFilterChips() {
    final levels = ["Semua", "SD", "SMP", "SMA/SMK"];
    return Container(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: levels.map((level) {
          final isSelected = _selectedLevel == level;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(level),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedLevel = level;
                  });
                }
              },
              backgroundColor: widget.isDarkMode
                  ? Colors.grey[800]
                  : Colors.white,
              selectedColor: Colors.pink[700],
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (widget.isDarkMode ? Colors.white70 : Colors.black),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : (widget.isDarkMode
                            ? Colors.grey[700]!
                            : Colors.grey[300]!),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildGuruList(List<Guru> teachers) {
    if (teachers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: Text(
            "Tidak ada guru yang cocok.",
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: teachers.length,
      itemBuilder: (context, index) {
        final guru = teachers[index];
        return _buildGuruCard(guru);
      },
    );
  }

  Widget _buildGuruCard(Guru guru) {
    final cardColor = widget.isDarkMode ? Colors.grey[850] : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.grey[600];

    return Card(
      color: cardColor,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: widget.isDarkMode
            ? BorderSide(color: Colors.pinkAccent.withAlpha(77))
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailGuruPage(
                guru: guru,
                isDarkMode: widget.isDarkMode,
                favoriteTeachers: widget
                    .favoriteTeachers, // Anda mungkin perlu meneruskan data favorit yang benar
                user: widget.user,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: getImage(guru.photo),
                    radius: 30,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guru.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Guru ${guru.level}",
                          style: TextStyle(color: subTextColor, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  if (guru.rating > 0)
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          guru.rating.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const Divider(height: 20, thickness: 1),
              _buildInfoRow(Icons.book_outlined, guru.mapel, subTextColor),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.location_on_outlined,
                guru.kota,
                subTextColor,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.phone_outlined, guru.noTelepon, subTextColor),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.price_change_outlined,
                "Rp ${guru.price}K / jam",
                subTextColor,
                textColor: widget.isDarkMode
                    ? Colors.cyanAccent
                    : Colors.green[700], // <-- FIX HERE
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String text,
    Color? color, {
    Color? textColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: textColor ?? color),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final guruProvider = context.watch<GuruProvider>();
    final allGurus = guruProvider.guruList;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;

    // Terapkan filter jenjang
    final filteredGurus = _selectedLevel == "Semua"
        ? allGurus
        : allGurus.where((g) => g.level == _selectedLevel).toList();

    final searchResults = getSearchResults(filteredGurus);

    return Scaffold(
      backgroundColor: widget.isDarkMode
          ? Colors.black
          : const Color(0xFFF692B3),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Cari nama, kota, atau mapel...",
                hintStyle: TextStyle(
                  color: widget.isDarkMode ? Colors.white54 : Colors.grey[600],
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: widget.isDarkMode ? Colors.white70 : Colors.grey[700],
                ),
                filled: true,
                fillColor: widget.isDarkMode ? Colors.grey[800] : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildFilterChips(), // Tambahkan filter chips di sini
            const SizedBox(height: 20),

            if (_searchQuery.isNotEmpty) ...[
              _buildSectionTitle("Hasil Pencarian"),
              buildGuruList(searchResults),
            ] else if (_selectedLevel != "Semua") ...[
              _buildSectionTitle("Menampilkan Guru Jenjang $_selectedLevel"),
              buildGuruList(filteredGurus),
            ] else ...[
              _buildSectionTitle("Guru Rekomendasi (SD)"),
              buildGuruList(getRecommendedTeachers(allGurus, "SD")),
              const SizedBox(height: 10),

              _buildSectionTitle("Guru Rekomendasi (SMP)"),
              buildGuruList(getRecommendedTeachers(allGurus, "SMP")),
              const SizedBox(height: 10),

              _buildSectionTitle("Guru Rekomendasi (SMA/SMK)"),
              buildGuruList(getRecommendedTeachers(allGurus, "SMA/SMK")),
              const SizedBox(height: 10),

              _buildSectionTitle("Guru Baru Bergabung"),
              buildGuruList(getNewTeachers(allGurus)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: widget.isDarkMode ? Colors.pinkAccent : Colors.pink[900],
        ),
      ),
    );
  }
}
