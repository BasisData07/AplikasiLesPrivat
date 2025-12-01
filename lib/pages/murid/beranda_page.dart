import 'package:PRIVATE_AJA/pages/model/guru_provider.dart';
import 'package:PRIVATE_AJA/pages/model/jadwal_les_model.dart';
import 'package:PRIVATE_AJA/pages/model/jadwal_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/guru_model.dart';
import '../model/user_model.dart';
import 'detail_guru_page.dart';

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

  static const Color mintHighlight = Colors.orange;
  static const Color lightMintBackground = Color(0xFFF5FFFA);
  static const Color lightMintAccent = Colors.orangeAccent;
  
  bool get _isDarkMode => false;

  @override
  void initState() {
    super.initState();

    // ================================
    // AMBIL DATA GURU & JADWAL DI AWAL
    // ================================
    Future.microtask(() {
      Provider.of<GuruProvider>(context, listen: false).fetchGuruList();
      Provider.of<JadwalProvider>(
        context,
        listen: false,
      ).fetchJadwalUntukBeranda();
    });
  }

  ImageProvider getImage(String path) {
    try {
      return path.startsWith('http')
          ? NetworkImage(path)
          : AssetImage(path) as ImageProvider;
    } catch (e) {
      return const AssetImage("assets/panda.png");
    }
  }

  // GURU FUNCTIONS
  List<Guru> getRecommendedTeachers(List<Guru> guruList, String level) {
    return guruList.where((g) => g.kategori_jenjang == level && g.rating >= 4.0).toList();
  }

  List<Guru> getNewTeachers(List<Guru> guruList) {
    // Guru baru diidentifikasi dengan rating 0.0, tetapi idealnya
    // harus menggunakan field 'tanggal_daftar'
    return guruList.where((g) => g.rating == 0).toList();
  }

  List<Guru> getSearchResults(List<Guru> guruList) {
    final q = _searchQuery.toLowerCase();
    if (q.isEmpty) return [];
    return guruList.where((guru) {
      return guru.kota.toLowerCase().contains(q) ||
          guru.mapel.toLowerCase().contains(q) ||
          guru.nama.toLowerCase().contains(q);
    }).toList();
  }

  // ===========================
  // JADWAL LES SECTION
  // ===========================
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
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: jadwalProvider.jadwalBeranda.length,
              itemBuilder: (context, index) {
                final jadwal = jadwalProvider.jadwalBeranda[index];
                return _buildJadwalCard(jadwal, textColor);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildJadwalCard(JadwalLesModel jadwal, Color textColor) {
    final cardColor = widget.isDarkMode ? Colors.grey[850] : Colors.white;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.grey[600];

    return SizedBox(
      width: 250,
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
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                jadwal.namaMapel,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              _buildInfoRow(
                Icons.person_outline,
                jadwal.namaGuru,
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
                textColor: widget.isDarkMode ? lightMintAccent : mintHighlight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================
  // FILTER CHIP GURU
  // ===========================
  Widget _buildFilterChips() {
    final levels = ["Semua", "SD", "SMP", "SMA", "Mahasiswa"];

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
                  setState(() => _selectedLevel = level);
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
            ),
          );
        }).toList(),
      ),
    );
  }

  // ===========================
  // GURU LIST
  // ===========================
  Widget buildGuruList(List<Guru> teachers) {
    if (teachers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: Text("Tidak ada data guru yang cocok.")),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: teachers.length,
      itemBuilder: (context, index) {
        return _buildGuruCard(teachers[index]);
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
            ? BorderSide(color: mintHighlight.withAlpha(77))
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailGuruPage(
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
                    backgroundImage: getImage(guru.foto),
                    radius: 30,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guru.nama,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Guru ${guru.kategori_jenjang}",
                          style: TextStyle(color: subTextColor),
                        ),
                      ],
                    ),
                  ),
                  if (guru.rating > 0)
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          guru.rating.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const Divider(height: 20),
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
                "Rp ${guru.harga}K / jam",
                subTextColor,
                textColor: widget.isDarkMode ? lightMintAccent : mintHighlight,
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

  // ===========================
  // BUILD UI
  // ===========================
  @override
  Widget build(BuildContext context) {
    final guruProvider = context.watch<GuruProvider>();
    final jadwalProvider = context.watch<JadwalProvider>();

    final allGurus = guruProvider.guruList;

    final filteredGurus = _selectedLevel == "Semua"
        ? allGurus
        : allGurus.where((g) => g.kategori_jenjang == _selectedLevel).toList();

    final searchResults = getSearchResults(filteredGurus);

    final textColor = widget.isDarkMode ? Colors.white : Colors.black;
    const mintGreen = Colors.orangeAccent;
    const darkerMintGreen = Colors.orange;
    final gradientColors = _isDarkMode
        ? [Colors.grey[800]!, Colors.black]
        : [mintGreen, darkerMintGreen];

    return Scaffold(
      backgroundColor: widget.isDarkMode
          ? Colors.grey[900]
          : lightMintBackground,
          
      appBar: AppBar(
          title: const Text("Dashboard Murid"),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // SEARCH BAR
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
              onChanged: (v) => setState(() => _searchQuery = v),
            ),

            const SizedBox(height: 16),

            // JADWAL LES TERBARU
            _buildJadwalSection(jadwalProvider),
            const SizedBox(height: 20),

            // FILTER JENJANG
            _buildSectionTitle("Cari Guru Berdasarkan Jenjang"),
            _buildFilterChips(),
            const SizedBox(height: 20),

            // Tampilkan error jika ada
            if (guruProvider.errorMessage != null && !guruProvider.isLoading)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "Gagal memuat data guru: ${guruProvider.errorMessage}",
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),

            // SEARCH MODE
            if (_searchQuery.isNotEmpty) ...[
              _buildSectionTitle("Hasil Pencarian Guru"),
              buildGuruList(searchResults),
            ]
            // FILTER MODE
            else if (_selectedLevel != "Semua") ...[
              _buildSectionTitle("Menampilkan Guru Jenjang $_selectedLevel"),
              buildGuruList(filteredGurus),
            ]
            // DEFAULT MODE (Tampilkan Rekomendasi/Baru)
            else ...[
              if (guruProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(), // Tampilkan loading
                  ),
                )
              else ...[
               /* _buildSectionTitle("Guru Rekomendasi (SD)"),
                buildGuruList(getRecommendedTeachers(allGurus, "SD")),
                const SizedBox(height: 10),

                _buildSectionTitle("Guru Rekomendasi (SMP)"),
                buildGuruList(getRecommendedTeachers(allGurus, "SMP")),
                const SizedBox(height: 10),

                _buildSectionTitle("Guru Rekomendasi (SMA)"),
                buildGuruList(getRecommendedTeachers(allGurus, "SMA")),
                const SizedBox(height: 10),

                _buildSectionTitle("Guru Baru Bergabung"),*/
                buildGuruList(getNewTeachers(allGurus)),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
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