// lib/pages/murid/beranda_page.dart
import 'package:PRIVATE_AJA/pages/model/jadwal_les_model.dart';
import 'package:PRIVATE_AJA/pages/model/jadwal_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import yang SUDAH ADA
import '../model/guru_model.dart';
import '../model/user_model.dart';
import '../model/guru_provider.dart';
import '../murid/detail_guru.dart';

// Import BARU (Ganti path-nya jika perlu)

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
  String _selectedLevel = "Semua";

  // Palet warna tema
  static const Color mintHighlight = Colors.orange;
  static const Color lightMintBackground = Color(0xFFF5FFFA);
  static const Color lightMintAccent = Colors.orangeAccent;

  @override
  void initState() {
    super.initState();
    // PENTING: Ambil data jadwal saat halaman dibuka
    // (Saya asumsikan GuruProvider sudah diambil di level yang lebih tinggi)
    Future.microtask(() =>
        Provider.of<JadwalProvider>(context, listen: false)
            .fetchJadwalUntukBeranda());
  }

  // == Bagian Fungsi Helper (Filter, Search, etc.) ==

  ImageProvider getImage(String path) {
    try {
      return path.startsWith('http')
          ? NetworkImage(path)
          : AssetImage(path) as ImageProvider;
    } catch (e) {
      return const AssetImage("assets/panda.png");
    }
  }

  // --- Fungsi untuk GURU (dari kode lama Anda) ---
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

  // == Bagian Widget Builder ==

  // WIDGET BARU: Untuk menampilkan daftar JADWAL LES
  Widget _buildJadwalSection(JadwalProvider jadwalProvider) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Jadwal Les Terbaru"),
        if (jadwalProvider.isLoadingBeranda)
          const Center(child: CircularProgressIndicator()),
        if (!jadwalProvider.isLoadingBeranda &&
            jadwalProvider.jadwalBeranda.isEmpty)
          const Center(child: Text("Belum ada jadwal les.")),
        if (!jadwalProvider.isLoadingBeranda &&
            jadwalProvider.jadwalBeranda.isNotEmpty)
          SizedBox(
            height: 150, // Tinggi container list horizontal
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: jadwalProvider.jadwalBeranda.length,
              itemBuilder: (context, index) {
                final jadwal = jadwalProvider.jadwalBeranda[index];
                // Buat card kecil untuk jadwal
                return _buildJadwalCard(jadwal, textColor);
              },
            ),
          ),
      ],
    );
  }

  // WIDGET BARU: Card untuk JADWAL LES (versi horizontal/kecil)
  Widget _buildJadwalCard(JadwalLesModel jadwal, Color textColor) {
    final cardColor = widget.isDarkMode ? Colors.grey[850] : Colors.white;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.grey[600];

    return SizedBox(
      width: 250, // Lebar card
      child: Card(
        color: cardColor,
        elevation: 2,
        margin: const EdgeInsets.only(right: 12, bottom: 8, top: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: widget.isDarkMode
              ? BorderSide(color: mintHighlight.withAlpha(77))
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            // TODO: Nanti bisa navigasi ke detail jadwal
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  jadwal.namaMapel, // Judul adalah Mapel
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                _buildInfoRow(
                  Icons.person_outline,
                  jadwal.namaGuru, // Sub-info adalah Guru
                  subTextColor,
                ),
                const SizedBox(height: 6),
                _buildInfoRow(
                  Icons.calendar_today_outlined,
                  jadwal.hari,
                  subTextColor,
                ),
                const SizedBox(height: 6),
                _buildInfoRow(
                  Icons.access_time_outlined,
                  "${jadwal.jamMulai} - ${jadwal.jamSelesai}",
                  subTextColor,
                  textColor:
                      widget.isDarkMode ? lightMintAccent : mintHighlight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET LAMA: Filter chips untuk GURU
  Widget _buildFilterChips() {
    final levels = ["Semua", "SD", "SMP", "SMA/SMK"];
    return SizedBox(
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
              backgroundColor:
                  widget.isDarkMode ? Colors.grey[800] : Colors.white,
              selectedColor: mintHighlight,
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

  // WIDGET LAMA: Membangun list GURU
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
        return _buildGuruCard(guru); // Memanggil card GURU
      },
    );
  }

  // WIDGET LAMA: Card untuk GURU
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
            ? BorderSide(color: mintHighlight.withAlpha(77))
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
                favoriteTeachers: widget.favoriteTeachers,
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
                textColor:
                    widget.isDarkMode ? lightMintAccent : mintHighlight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET LAMA: Info row (dipakai oleh kedua card)
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
    // Ambil KEDUA provider
    final guruProvider = context.watch<GuruProvider>();
    final jadwalProvider = context.watch<JadwalProvider>(); // BARU

    final allGurus = guruProvider.guruList;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;

    final filteredGurus = _selectedLevel == "Semua"
        ? allGurus
        : allGurus.where((g) => g.level == _selectedLevel).toList();

    final searchResults = getSearchResults(filteredGurus);

    return Scaffold(
      backgroundColor: widget.isDarkMode
          ? Colors.grey[900]
          : lightMintBackground,
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
            
            // BAGIAN BARU DITAMBAHKAN DI SINI
            _buildJadwalSection(jadwalProvider),
            
            const SizedBox(height: 20),

            // BAGIAN LAMA (FILTER DAN LIST GURU) DIMULAI DARI SINI
            _buildSectionTitle("Cari Guru Berdasarkan Jenjang"),
            _buildFilterChips(),
            const SizedBox(height: 20),
            
            if (_searchQuery.isNotEmpty) ...[
              _buildSectionTitle("Hasil Pencarian Guru"),
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

  // WIDGET LAMA: Judul Section
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: widget.isDarkMode ? lightMintAccent : mintHighlight,
        ),
      ),
    );
  }
}