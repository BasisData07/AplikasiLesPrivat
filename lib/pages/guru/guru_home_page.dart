// lib/pages/guru/guru_home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/user_model.dart';
import '../model/jadwal_model.dart';
import '../model/jadwal_provider.dart';
import 'beranda_guru.dart';
import 'profil_guru.dart';
import 'chat_room_guru.dart';
import 'edit_profil_guru.dart';

class GuruHomePage extends StatefulWidget {
  final UserModel user;
  const GuruHomePage({super.key, required this.user});

  @override
  State<GuruHomePage> createState() => _GuruHomePageState();
}

class _GuruHomePageState extends State<GuruHomePage> {
  int _selectedIndex = 0;
  static const Color mintHighlight = Color(0xFF3CB371);

  late final List<Widget> _guruPages;

  @override
  void initState() {
    super.initState();
    _guruPages = <Widget>[
      GuruBerandaPage(user: widget.user),
      // --- PERBAIKAN ADA DI BARIS INI ---
      ChatRoomGuruPage(user: widget.user), // Memberikan data user yang login
      GuruProfilPage(user: widget.user),
      const EditProfilGuruPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showTambahJadwalDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final tanggalController = TextEditingController();
    final jamController = TextEditingController();
    
    String selectedDay = 'Senin';
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Tambah Jadwal Baru"),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedDay,
                    decoration: const InputDecoration(labelText: 'Hari'),
                    items: days.map((String day) {
                      return DropdownMenuItem<String>(value: day, child: Text(day));
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) selectedDay = newValue;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: tanggalController,
                    decoration: const InputDecoration(labelText: 'Tanggal', hintText: 'Contoh: 30 Okt 2025'),
                    validator: (value) => value!.isEmpty ? 'Tanggal tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: jamController,
                    decoration: const InputDecoration(labelText: 'Jam', hintText: 'Contoh: 14:00 - 15:00'),
                    validator: (value) => value!.isEmpty ? 'Jam tidak boleh kosong' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final jadwalBaru = JadwalSlot(
                    hari: selectedDay,
                    tanggal: tanggalController.text,
                    jam: jamController.text,
                  );
                  context.read<JadwalProvider>().tambahJadwal(widget.user.email, jadwalBaru);
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guru Dashboard'),
        backgroundColor: mintHighlight,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: _guruPages.elementAt(_selectedIndex),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => _showTambahJadwalDialog(context),
              backgroundColor: mintHighlight,
              tooltip: 'Tambah Jadwal',
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat Room'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_outlined), label: 'Edit'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: mintHighlight,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}