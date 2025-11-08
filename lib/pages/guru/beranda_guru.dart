import 'package:PRIVATE_AJA/pages/model/jadwal_provider.dart';
import 'package:PRIVATE_AJA/pages/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Sesuaikan path ini

// 1. Ubah menjadi StatefulWidget
//    Kita butuh initState() untuk memanggil API saat halaman dibuka
class GuruBerandaPage extends StatefulWidget {
  final UserModel user;
  const GuruBerandaPage({super.key, required this.user});

  @override
  State<GuruBerandaPage> createState() => _GuruBerandaPageState();
}

class _GuruBerandaPageState extends State<GuruBerandaPage> {

  @override
  void initState() {
    super.initState();
    // 2. Panggil API saat halaman pertama kali dibuka
    //    'listen: false' wajib di dalam initState
    Future.microtask(() => 
      Provider.of<JadwalProvider>(context, listen: false).fetchJadwalMilikGuru(
          widget.user.id.toString()) // Gunakan ID, bukan email
    );
  }

  // 3. Buat fungsi untuk menghapus (dengan dialog konfirmasi)
  Future<void> _hapusJadwal(int jadwalId) async {
    // Tampilkan dialog konfirmasi
    bool? yakinHapus = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus jadwal ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false), // Batal
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true), // Ya, Hapus
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (yakinHapus == true) {
      // Panggil provider untuk menghapus
      final jadwalProvider = Provider.of<JadwalProvider>(context, listen: false);
      
      // Tampilkan loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Menghapus jadwal...')),
      );

      final sukses = await jadwalProvider.deleteJadwal(
        jadwalId,
        widget.user.id.toString(), // Verifikasi guru_id_pemilik
      );

      // Tutup snackbar loading
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (sukses) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Jadwal berhasil dihapus'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus jadwal'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 4. Hubungkan dengan JadwalProvider
    return Consumer<JadwalProvider>(
      builder: (context, jadwalProvider, child) {
        
        // Tampilkan loading
        if (jadwalProvider.isLoadingJadwalGuru) {
          return const Center(child: CircularProgressIndicator());
        }

        // Ambil daftar jadwal milik guru ini
        final jadwalMilikGuru = jadwalProvider.jadwalMilikGuru;

        // Tampilkan pesan jika guru ini belum punya jadwal
        if (jadwalMilikGuru.isEmpty) {
          return const Center(child: Text("Anda belum mengatur jadwal."));
        }

        // 5. Tampilkan jadwal sesuai data dari API
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: jadwalMilikGuru.length,
          itemBuilder: (context, index) {
            // Data ini adalah Map<String, dynamic>
            final slot = jadwalMilikGuru[index];
            
            // Konversi data dari API
            final String namaMapel = slot['nama_mapel'] ?? 'Tanpa Mapel';
            final String hari = slot['hari'] ?? 'Tanpa Hari';
            final String jamMulai = slot['jam_mulai'] ?? '00:00';
            final String jamSelesai = slot['jam_selesai'] ?? '00:00';
            final int jadwalId = slot['jadwal_id']; // ID dari tabel jadwal_les

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                // Tampilkan data yang benar
                title: Text(
                  namaMapel,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("$hari, $jamMulai - $jamSelesai"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    // 6. Panggil fungsi hapus
                    _hapusJadwal(jadwalId);
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