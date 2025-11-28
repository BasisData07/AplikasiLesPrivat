// lib/pages/murid/beranda_page.dart
import 'package:PRIVATE_AJA/pages/model/jadwal_les_model.dart';
import 'package:PRIVATE_AJA/pages/model/jadwal_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import yang SUDAH ADA
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

  // Filter Jenjang (Sesuaikan dengan Database)
  final List<String> _levels = ["Semua", "SD", "SMP", "SMA", "Mahasiswa"];

  // Palet warna
  static const Color mintHighlight = Colors.orange;
  static const Color lightMintBackground = Color(0xFFF5FFFA);
  static const Color lightMintAccent = Colors.orangeAccent;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<JadwalProvider>(context, listen: false)
            .fetchJadwalUntukBeranda());
  }

  // ==========================================
  // LOGIKA FILTERING
  // ==========================================
  
  // 1. Filter Jadwal
  List<JadwalLesModel> getFilteredJadwal(List<JadwalLesModel> allJadwal) {
    return allJadwal.where((jadwal) {
      bool matchLevel = _selectedLevel == "Semua" || 
                        jadwal.level.toUpperCase().contains(_selectedLevel.toUpperCase()); 

      final query = _searchQuery.toLowerCase();
      bool matchSearch = query.isEmpty ||
          jadwal.namaGuru.toLowerCase().contains(query) ||
          jadwal.namaMapel.toLowerCase().contains(query) ||
          jadwal.kota.toLowerCase().contains(query);

      return matchLevel && matchSearch;
    }).toList();
  }

  // 2. Filter Guru
  List<Guru> getFilteredGuru(List<Guru> allGuru) {
    return allGuru.where((guru) {
      bool matchLevel = _selectedLevel == "Semua" || guru.level == _selectedLevel;
      
      final query = _searchQuery.toLowerCase();
      
      // Pastikan properti guru tidak null sebelum di-check
      final nama = guru.name.toLowerCase();
      final mapel = guru.mapel.toLowerCase();
      final kota = guru.kota.toLowerCase(); // PASTIKAN GURU MODEL ADA KOTA

      bool matchSearch = query.isEmpty ||
          nama.contains(query) ||
          mapel.contains(query) ||
          kota.contains(query);

      return matchLevel && matchSearch;
    }).toList();
  }

  ImageProvider getImage(String path) {
      try {
        return path.startsWith('http')
            ? NetworkImage(path)
            : AssetImage(path) as ImageProvider;
      } catch (e) {
        return const AssetImage("assets/panda.png"); // Ganti dengan aset default Anda
      }
  }

  // ==========================================
  // WIDGET BUILDERS
  // ==========================================

  Widget _buildJadwalSection(List<JadwalLesModel> filteredJadwal, bool isLoading) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;

    if (isLoading) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
    
    // Tampilan jika Jadwal Kosong
    if (filteredJadwal.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(Icons.event_busy, color: Colors.grey, size: 40),
            const SizedBox(height: 8),
            Text(
              "Tidak ada jadwal untuk filter ini.",
              style: TextStyle(color: textColor),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Jadwal Tersedia (${filteredJadwal.length})"),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filteredJadwal.length,
            itemBuilder: (context, index) {
              return _buildJadwalCard(filteredJadwal[index], textColor);
            },
          ),
        ),
      ],
    );
  }

  // --- WIDGET BARU: Grid Guru Responsif & Handle Kosong ---
  Widget buildGuruGridResponsive(List<Guru> teachers) {
    // 1. CEK DATA KOSONG
    if (teachers.isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.withOpacity(0.3))
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search_outlined, size: 50, color: Colors.orange.withOpacity(0.5)),
            const SizedBox(height: 10),
            Text(
              "Yah, Guru tidak ditemukan.",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.isDarkMode ? Colors.white70 : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 5),
             Text(
              "Coba cari kata kunci lain.",
              style: TextStyle(
                fontSize: 14,
                color: widget.isDarkMode ? Colors.white54 : Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    // 2. RENDER GRID JIKA ADA DATA
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsif: Tablet 2 kolom, HP 1 kolom
        int crossAxisCount = constraints.maxWidth > 700 ? 2 : 1; 
        
        return GridView.builder(
          shrinkWrap: true, // PENTING agar bisa scroll bersama parent
          physics: const NeverScrollableScrollPhysics(), // Scroll ikut parent
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 2.8, // Mengatur agar kartu melebar (horizontal)
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: teachers.length,
          itemBuilder: (context, index) => _buildGuruCard(teachers[index]),
        );
      },
    );
  }

  Widget _buildJadwalCard(JadwalLesModel jadwal, Color textColor) {
    final cardColor = widget.isDarkMode ? Colors.grey[850] : Colors.white;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.grey[600];

    return SizedBox(
      width: 260,
      child: Card(
        color: cardColor,
        elevation: 2,
        margin: const EdgeInsets.only(right: 12, bottom: 8, top: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: widget.isDarkMode ? BorderSide(color: mintHighlight.withOpacity(0.3)) : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () { /* TODO: Navigasi */ },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: mintHighlight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(jadwal.level, style: const TextStyle(fontSize: 10, color: mintHighlight, fontWeight: FontWeight.bold)),
                    ),
                    const Spacer(),
                    Icon(Icons.location_on, size: 12, color: subTextColor),
                    const SizedBox(width: 2),
                    Expanded(child: Text(jadwal.kota, style: TextStyle(fontSize: 11, color: subTextColor), overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  jadwal.namaMapel,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.person, jadwal.namaGuru, subTextColor),
                _buildInfoRow(Icons.calendar_today, jadwal.hari, subTextColor),
                _buildInfoRow(
                  Icons.access_time, 
                  "${jadwal.jamMulai} - ${jadwal.jamSelesai}", 
                  subTextColor, 
                  textColor: widget.isDarkMode ? lightMintAccent : mintHighlight
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuruCard(Guru guru) {
    final cardColor = widget.isDarkMode ? Colors.grey[850] : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.grey[600];

    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: widget.isDarkMode ? BorderSide(color: mintHighlight.withAlpha(77)) : BorderSide.none,
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
          child: Row( // Ubah jadi Row agar layout Horizontal (cocok untuk Grid)
            children: [
              CircleAvatar(
                backgroundImage: getImage(guru.photo),
                radius: 35,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      guru.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    Text("Guru ${guru.level}", style: TextStyle(color: subTextColor, fontSize: 12)),
                    const SizedBox(height: 4),
                    _buildInfoRow(Icons.book, guru.mapel, subTextColor),
                    _buildInfoRow(Icons.location_on, guru.kota, subTextColor), // Pastikan ini muncul
                    Text(
                      "Rp ${guru.price}K / jam",
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: widget.isDarkMode ? lightMintAccent : mintHighlight
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color? color, {Color? textColor}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: textColor ?? color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
          color: widget.isDarkMode ? lightMintAccent : mintHighlight,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _levels.map((level) {
          final isSelected = _selectedLevel == level;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(level),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedLevel = level);
              },
              backgroundColor: widget.isDarkMode ? Colors.grey[800] : Colors.white,
              selectedColor: mintHighlight,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : (widget.isDarkMode ? Colors.white70 : Colors.black),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- BUILD UTAMA ---
  @override
  Widget build(BuildContext context) {
    //final guruProvider = context.watch<GuruProvider>();
    final jadwalProvider = context.watch<JadwalProvider>();

    //final allGurus = guruProvider.guruList;
    final allJadwal = jadwalProvider.jadwalBeranda;

    final filteredJadwal = getFilteredJadwal(allJadwal);
    //final filteredGurus = getFilteredGuru(allGurus);

    final textColor = widget.isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: widget.isDarkMode ? Colors.grey[900] : lightMintBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Cari mapel, guru, atau lokasi...",
                hintStyle: TextStyle(color: widget.isDarkMode ? Colors.white54 : Colors.grey[600]),
                prefixIcon: Icon(Icons.search, color: widget.isDarkMode ? Colors.white70 : Colors.grey[700]),
                filled: true,
                fillColor: widget.isDarkMode ? Colors.grey[800] : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 16),

            // Filter
            _buildSectionTitle("Filter Jenjang"),
            _buildFilterChips(),
            const SizedBox(height: 20),

            // Bagian Jadwal
            _buildJadwalSection(filteredJadwal, jadwalProvider.isLoadingBeranda),
            
            const SizedBox(height: 24),
            const Divider(),

            // Bagian Guru (Judul Dinamis)
            if (_searchQuery.isNotEmpty)
              _buildSectionTitle("Hasil Pencarian: '$_searchQuery'")
            else
              _buildSectionTitle("Guru Jenjang $_selectedLevel"),
            
            // PENTING: Gunakan Widget Grid Baru, BUKAN LIST LAMA
            //buildGuruGridResponsive(filteredGurus),
          ],
        ),
      ),
    );
  }
}