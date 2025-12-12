import 'package:PRIVATE_AJA/pages/model/jadwal_provider.dart';
import 'package:PRIVATE_AJA/pages/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class JadwalSayaPage extends StatefulWidget {
  final UserModel user;
  const JadwalSayaPage({super.key, required this.user});

  @override
  State<JadwalSayaPage> createState() => _JadwalSayaPageState();
}

class _JadwalSayaPageState extends State<JadwalSayaPage> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<JadwalProvider>(context, listen: false)
          .fetchJadwalSaya(widget.user.id.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jadwal Les Saya"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Consumer<JadwalProvider>(
        builder: (context, jadwalProvider, child) {
          if (jadwalProvider.isLoadingJadwalSaya) {
            return const Center(child: CircularProgressIndicator());
          }

          final jadwalList = jadwalProvider.jadwalSaya;

          if (jadwalList.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Anda belum memiliki jadwal les yang dijadwalkan.\nHubungi guru untuk menjadwalkan les.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: jadwalList.length,
            separatorBuilder: (ctx, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final jadwal = jadwalList[index];
              return _buildJadwalItem(jadwal);
            },
          );
        },
      ),
    );
  }

  Widget _buildJadwalItem(Map<String, dynamic> jadwal) {
    final String namaMapel = jadwal['nama_mapel'] ?? 'Mapel';
    final String namaGuru = jadwal['nama_guru'] ?? 'Guru';
    final String hari = jadwal['hari'] ?? '-';
    final String jamMulai =
        (jadwal['jam_mulai'] ?? '00:00').toString().substring(0, 5);
    final String jamSelesai =
        (jadwal['jam_selesai'] ?? '00:00').toString().substring(0, 5);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  namaMapel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Terjadwal",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  "Guru: $namaGuru",
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  "$hari, $jamMulai - $jamSelesai",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
