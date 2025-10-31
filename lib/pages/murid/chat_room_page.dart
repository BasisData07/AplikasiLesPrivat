// lib/pages/murid/chat_room_page.dart

import 'package:flutter/material.dart';
import '../chat_page.dart';        // <-- IMPORT halaman percakapan
import '../model/user_model.dart'; // <-- IMPORT model pengguna
import '../model/guru_model.dart'; // <-- IMPORT model guru

class ChatRoomPage extends StatelessWidget {
  // TAMBAHKAN: Parameter untuk menerima data user
  final UserModel user;
  final bool isDarkMode;

  const ChatRoomPage({
    super.key,
    required this.user, // <-- WAJIB ADA agar tidak eror
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    // --- DATA DUMMY GURU (sesuai model Guru Anda) ---
    // Di aplikasi nyata, daftar ini didapat dari Provider atau API
    final List<Guru> availableGurus = [
      GuruSD(
          name: 'Budi Santoso',
          email: 'budi.santoso@guru.com', // Gunakan email sebagai ID unik
          gelar: 'S.Pd.',
          price: 50,
          rating: 4.8,
          photo: 'url_foto_budi',
          kota: 'Jakarta',
          mapel: 'Matematika',
          noTelepon: '0812345678',
          pengalaman: '5 tahun',
          deskripsi: 'Pengajar sabar dan berpengalaman.'),
      GuruSMP(
          name: 'Siti Aminah',
          email: 'siti.aminah@guru.com', // Gunakan email sebagai ID unik
          gelar: 'M.Pd.',
          price: 75,
          rating: 4.9,
          photo: 'url_foto_siti',
          kota: 'Surabaya',
          mapel: 'Fisika',
          noTelepon: '0812345679',
          pengalaman: '8 tahun',
          deskripsi: 'Fokus pada pemahaman konsep.'),
    ];

    final textColor = isDarkMode ? Colors.white70 : Colors.black87;

    // Tampilkan daftar guru menggunakan ListView
    return ListView.builder(
      itemCount: availableGurus.length,
      itemBuilder: (context, index) {
        final guru = availableGurus[index];
        return ListTile(
          leading: CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Text(guru.name, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          subtitle: Text('Guru ${guru.mapel} - ${guru.level}',
              style: TextStyle(color: textColor.withOpacity(0.7))),
          onTap: () {
            // Saat di-klik, navigasi ke halaman percakapan (ChatPage)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  currentUserId: user.username, // ID murid yang login
                  peerId: guru.email, // <-- Menggunakan email guru sebagai ID unik
                  peerName: guru.name,
                ),
              ),
            );
          },
        );
      },
    );
  }
}