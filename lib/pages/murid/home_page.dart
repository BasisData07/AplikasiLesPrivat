import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../model/guru_model.dart';
// Pastikan semua file ini ada di folder yang benar
import '../murid/profil_page.dart'; 
import '../murid/beranda_page.dart';
import '../murid/favorit.dart';
import '../murid/chat_room_page.dart';

class MyHomePage extends StatefulWidget {
  // Data pengguna yang login
  final UserModel user;
  
  // Parameter opsional untuk mengatur tab awal yang aktif
  final int initialIndex;
  
  // Parameter opsional untuk membawa daftar guru favorit
  final List<Guru> favoriteTeachers;

  const MyHomePage({
    super.key,
    required this.user,
    this.initialIndex = 0,
    this.favoriteTeachers = const [],
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Variabel untuk melacak tab yang sedang aktif
  late int _selectedIndex;
  
  // Variabel untuk status mode gelap/terang
  bool _isDarkMode = false;
  
  // Variabel untuk menyimpan daftar guru favorit
  late List<Guru> _favoriteTeachers;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _favoriteTeachers = List.from(widget.favoriteTeachers);
  }

  // Getter untuk daftar halaman yang akan ditampilkan di body
  // Setiap halaman menerima data yang relevan
  List<Widget> get _pages => [
        // Tab 0: Beranda
        BerandaPage(
          user: widget.user,
          isDarkMode: _isDarkMode,
          favoriteTeachers: _favoriteTeachers,
        ),
        // Tab 1: Favorit
        FavoritPage(
          user: widget.user,
          isDarkMode: _isDarkMode,
          favoriteTeachers: _favoriteTeachers,
        ),
        // Tab 2: Chat Room
        ChatRoomPage(
          user: widget.user, // Memberikan info user ke halaman chat
          isDarkMode: _isDarkMode,
        ),
        // Tab 3: Profil
        ProfilPage(
          user: widget.user, 
          isDarkMode: _isDarkMode
        ),
      ];

  // Fungsi yang dipanggil saat item di BottomNavigationBar ditekan
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Fungsi untuk mengubah status mode gelap/terang
  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definisi warna berdasarkan _isDarkMode
    final bgColor = _isDarkMode ? Colors.grey[900] : Colors.white;
    final mintGreen = Colors.orangeAccent;
    final darkerMintGreen = Colors.orange;
    final gradientColors = _isDarkMode
        ? [Colors.grey[800]!, Colors.black]
        : [mintGreen, darkerMintGreen];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: darkerMintGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            // Pastikan Anda punya gambar panda di folder assets
            Image.asset("assets/panda.png", height: 40, width: 40),
            const SizedBox(width: 8),
            const Text(
              "PRIVATE AJA",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: _toggleDarkMode,
            tooltip: _isDarkMode ? "Mode Terang" : "Mode Gelap",
          ),
        ],
      ),
      body: Column(
        children: [
          // Header sambutan di bawah AppBar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Text(
              "Welcome, ${widget.user.name}! Selamat datang di aplikasi PRIVATE AJA.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          // Body utama yang akan berganti sesuai tab yang dipilih
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
      // Navigasi bawah
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: _isDarkMode ? Colors.black : Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: darkerMintGreen,
        unselectedItemColor:
            _isDarkMode ? Colors.white70 : Colors.grey[600],
        selectedIconTheme: const IconThemeData(size: 30),
        unselectedIconTheme: const IconThemeData(size: 24),
        type: BottomNavigationBarType.fixed, // Agar semua label terlihat
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home), 
            label: "Beranda"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite), 
            label: "Favorit"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline), 
            label: "Chat Room"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), 
            label: "Profil"
          ),
        ],
      ),
    );
  }
}