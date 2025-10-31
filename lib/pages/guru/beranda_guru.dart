// lib/pages/beranda_guru.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/user_model.dart';
import '../model/jadwal_provider.dart';

class GuruBerandaPage extends StatelessWidget {
  final UserModel user;
  const GuruBerandaPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // 1. Menggunakan 'Consumer' untuk terhubung dengan JadwalProvider
    return Consumer<JadwalProvider>(
      builder: (context, jadwalProvider, child) {
        
        // 2. Mengambil jadwal HANYA untuk guru yang sedang login (berdasarkan email)
        final jadwal = jadwalProvider.getJadwalForGuru(user.email);

        // Tampilkan pesan jika guru ini belum punya jadwal di provider
        if (jadwal.isEmpty) {
          return const Center(child: Text("Anda belum mengatur jadwal."));
        }

        // 3. Tampilkan jadwal dalam bentuk daftar yang bisa di-tap
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: jadwal.length,
          itemBuilder: (context, index) {
            final slot = jadwal[index];
            
            return Card(
              // Ubah warna card jika sudah di-booking
              color: slot.isBooked ? Colors.grey[300] : Colors.white,
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                leading: Icon(
                  slot.isBooked ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: slot.isBooked ? const Color(0xFF3CB371) : Colors.grey,
                  size: 28,
                ),
                title: Text(
                  "${slot.hari}, ${slot.tanggal}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: slot.isBooked ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(slot.jam),
                // 4. Checkbox untuk mengubah status jadwal
                trailing: Checkbox(
                  value: slot.isBooked,
                  activeColor: const Color(0xFF3CB371),
                  onChanged: (bool? value) {
                    // 5. Panggil fungsi di provider untuk mengubah status & update UI
                    jadwalProvider.toggleJadwalStatus(user.email, index);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}