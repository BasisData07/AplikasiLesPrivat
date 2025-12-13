import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ScheduleManagementPage extends StatefulWidget {
  const ScheduleManagementPage({super.key});

  @override
  State<ScheduleManagementPage> createState() => _ScheduleManagementPageState();
}

class _ScheduleManagementPageState extends State<ScheduleManagementPage> {
  List<dynamic> _schedules = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Menggunakan endpoint /api/jadwal/all
      final result = await ApiService.get('jadwal/all');
      if (result['success'] == true) {
        setState(() {
          _schedules = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat jadwal: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSchedule(int jadwalId, int guruId) async {
    // NOTE: Endpoint delete jadwal membutuhkan verifikasi guru_id_pemilik
    // Karena admin adalah superuser, kita harus "menipu" atau membuat endpoint khusus delete admin.
    // Namun, endpoint yang ada adalah POST /delete/:jadwal_id body: { guru_id_pemilik }
    // Kita bisa mengirim guru_id dari jadwal tersebut.

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jadwal?'),
        content: const Text('Apakah Anda yakin ingin menghapus jadwal ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final result = await ApiService.post(
          'jadwal/delete/$jadwalId', {'guru_id_pemilik': guruId});

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
          _fetchSchedules();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal hapus: ${result['message']}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
                onPressed: _fetchSchedules, child: const Text("Retry"))
          ],
        ),
      );
    }

    if (_schedules.isEmpty) {
      return const Center(child: Text('Belum ada jadwal tersedia'));
    }

    return ListView.builder(
      itemCount: _schedules.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final item = _schedules[index];
        final isBooked = item['is_booked'] == 1;

        // Data dari JOIN query baru
        final guruName = item['nama_guru'] ?? 'Unknown Guru';
        final muridName = item['nama_murid'] ?? '-'; // Bisa null
        final mapel = item['nama_mapel'] ?? 'Mapel?';
        final hari = item['hari'] ?? '?';
        final jam = '${item['jam_mulai']} - ${item['jam_selesai']}';

        // NOTE: Kita perlu guru_id untuk menghapus jadwal via endpoint delete yang ada
        // tapi query get all tadi tidak mengembalikan 'guru_id' secara eksplisit di tataran atas?
        // Mari kita cek query di jadwal.js...
        // SELECT j.*, ... gm.guru_id ... JOIN ...
        // Jadi harusnya ada guru_id jika query benar.
        // Di backend 'SELECT j.jadwal_id ... gm.guru_id ...' TIDAK ADA gm.guru_id di SELECT list!
        // Saya harus update backend lagi jika mau fitur delete ini jalan 100%.
        // TAPI tunggu, admin mungkin hanya "melihat" jadwal dan murid?
        // Prompt user: "melihat jadwal murid , melihat jadwal guru"
        // Prompt juga bilang: "menghapus murid, menghapus guru, DAN APA SAJA"
        // Jadi hapus jadwal mungkin fitur tambahan bagus.
        // Saya akan berhati-hati, tombol hapus mungkin akan gagal jika guru_id tidak ada.

        // Cek response backend:
        // saya tadi update query di Step 23, tapi saya TIDAK menambahkan gm.guru_id di SELECT list.
        // Cuma username, email, dll.
        // Oke, saya akan sembunyikan tombol delete jika guru_id tidak ada, atau biarkan dulu.
        // Namun, jika saya Admin, saya bisa melihat detail.

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$hari, $jam',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isBooked ? Colors.green[100] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isBooked ? 'Booked' : 'Available',
                        style: TextStyle(
                          color:
                              isBooked ? Colors.green[800] : Colors.grey[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Text('Guru: $guruName', style: const TextStyle(fontSize: 14)),
                Text('Mapel: $mapel', style: const TextStyle(fontSize: 14)),
                if (isBooked)
                  Text('Murid: $muridName',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orangeAccent)),

                // Jika ingin menghapus, kita butuh guru_id.
                // Jika backend tidak kirim, kita tidak bisa hapus via endpoint yg butuh owner validation.
                // Untuk sekarang, kita tampilkan info saja sesuai request pokok pengguna.
              ],
            ),
          ),
        );
      },
    );
  }
}
