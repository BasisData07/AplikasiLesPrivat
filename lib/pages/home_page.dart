import 'package:flutter/material.dart';
import 'model/user_model.dart';
import 'model/guru_model.dart';
import 'profil_page.dart';
import 'beranda_page.dart';
import 'favorit.dart';
import 'tambah_guru_page.dart';

class MyHomePage extends StatefulWidget {
  final UserModel user;
  final int initialIndex;
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
  late int _selectedIndex;
  bool _isDarkMode = false;
  late List<Guru> _favoriteTeachers;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _favoriteTeachers = List.from(widget.favoriteTeachers);
  }

  List<Widget> get _pages => [
    BerandaPage(
      user: widget.user,
      isDarkMode: _isDarkMode,
      favoriteTeachers: _favoriteTeachers,
    ),
    FavoritPage(
      user: widget.user,
      isDarkMode: _isDarkMode,
      favoriteTeachers: _favoriteTeachers,
    ),
    TambahGuruPage(isDarkMode: _isDarkMode),
    ProfilPage(user: widget.user, isDarkMode: _isDarkMode),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _toggleDarkMode() {
    setState(() => _isDarkMode = !_isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkMode ? Colors.grey[900] : const Color(0xFFFFF0F5);
    final gradientColors = _isDarkMode
        ? [Colors.grey[800]!, Colors.black]
        : [Colors.pink[200]!, Colors.pink[400]!];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(236, 64, 122, 1),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            Image.asset("assets/panda.png", height: 40, width: 40),
            const SizedBox(width: 8),
            const Text(
              "LES MANIA",
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
              "Welcome, ${widget.user.name}! Selamat datang di aplikasi LES MANIA.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: _isDarkMode ? Colors.black : Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.pink[700],
        unselectedItemColor: _isDarkMode ? Colors.white70 : Colors.grey[600],
        selectedIconTheme: const IconThemeData(size: 30),
        unselectedIconTheme: const IconThemeData(size: 24),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorit"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Tambah Guru"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}
