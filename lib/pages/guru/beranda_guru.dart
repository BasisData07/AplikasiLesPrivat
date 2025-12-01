import 'package:PRIVATE_AJA/pages/model/jadwal_provider.dart';
import 'package:PRIVATE_AJA/pages/model/ulasan_model.dart';
import 'package:PRIVATE_AJA/pages/model/user_model.dart';
import 'package:PRIVATE_AJA/pages/murid/chat_room_page.dart';
import 'package:PRIVATE_AJA/services/chat_service.dart';
import 'package:PRIVATE_AJA/services/ulasan_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Asumsi: Anda menggunakan ChatRoomPage untuk navigasi chat

class GuruBerandaPage extends StatefulWidget {
    final UserModel user;
    final Function(Map<String, dynamic> slot)? onEditJadwal;

    const GuruBerandaPage({
        super.key,
        required this.user,
        this.onEditJadwal, 
    });

    @override
    State<GuruBerandaPage> createState() => _GuruBerandaPageState();
}

class _GuruBerandaPageState extends State<GuruBerandaPage> {
    static const Color mintHighlight = Colors.orange;
    
    // 🔥 STATE BARU UNTUK ULASAN
    List<UlasanModel> _ulasanList = []; 
    bool _isLoadingUlasan = false;

    @override
    void initState() {
        super.initState();
        // Panggil API saat halaman pertama kali dibuka
        Future.microtask(() {
            Provider.of<JadwalProvider>(
                context,
                listen: false,
            ).fetchJadwalMilikGuru(widget.user.id.toString());
            
            _fetchUlasan(); // 🔥 Panggil fetch ulasan
        });
    }

    // 🔥 METODE BARU UNTUK MENGAMBIL ULASAN YANG DITUJUKAN KE GURU INI
    Future<void> _fetchUlasan() async {
        setState(() {
            _isLoadingUlasan = true;
        });

        try {
            // Mengambil ulasan yang ditujukan ke ID guru ini
            final ulasan = await UlasanService.getUlasanByGuruId(widget.user.id.toString());
            if (mounted) {
                setState(() {
                    // Filter ulasan yang belum dibalas
                    _ulasanList = ulasan;
                    //_ulasanList = ulasan.where((u) => u.balasanGuru == null || u.balasanGuru!.isEmpty).toList();
                    _isLoadingUlasan = false;
                });
            }
        } catch (e) {
            print("Failed to fetch reviews for Guru: $e");
            if (mounted) {
                setState(() {
                    _isLoadingUlasan = false;
                });
            }
        }
    }
    
    // 🔥 DIALOG BARU: Guru Membalas Ulasan
    void _showReplyDialog(int ulasanId, String namaMurid, String komentarMurid) {
        final TextEditingController replyController = TextEditingController();

        showDialog(
            context: context,
            builder: (context) {
                return AlertDialog(
                    title: Text("Balas Ulasan dari $namaMurid"),
                    content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text("Komentar: '$komentarMurid'", style: const TextStyle(fontStyle: FontStyle.italic)),
                            const SizedBox(height: 10),
                            TextField(
                                controller: replyController,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                    hintText: "Tulis balasan Anda...",
                                    border: OutlineInputBorder(),
                                ),
                            ),
                        ],
                    ),
                    actions: [
                        TextButton(child: const Text("Batal"), onPressed: () => Navigator.of(context).pop()),
                        ElevatedButton(
                            child: const Text("Kirim Balasan"),
                            onPressed: () async {
                                final balasan = replyController.text.trim();
                                if (balasan.isEmpty) return;

                                Navigator.of(context).pop(); // Tutup dialog input

                                final response = await UlasanService.submitBalasan(
                                    ulasanId: ulasanId,
                                    guruId: widget.user.id.toString(), // ID Guru yang sedang login
                                    balasan: balasan,
                                );
                                
                                if (mounted) {
                                    if (response['success'] == true) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(response['message'] ?? "Balasan berhasil dikirim!"), backgroundColor: Colors.green)
                                        );
                                        _fetchUlasan(); // 🔥 Refresh list ulasan
                                    } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(response['message'] ?? "Gagal mengirim balasan."), backgroundColor: Colors.red),
                                        );
                                    }
                                }
                            },
                        ),
                    ],
                );
            },
        ).then((_) {
            replyController.dispose();
        });
    }


    // --- FUNGSI 1: HAPUS JADWAL ---
    Future<void> _hapusJadwal(int jadwalId) async {
        bool? yakinHapus = await showDialog<bool>(
            context: context,
            builder: (BuildContext ctx) {
                return AlertDialog(
                    title: const Text('Konfirmasi Hapus'),
                    content: const Text('Apakah Anda yakin ingin menghapus jadwal ini?'),
                    actions: [
                        TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Batal'),
                        ),
                        TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                        ),
                    ],
                );
            },
        );

        if (yakinHapus == true) {
            final jadwalProvider = Provider.of<JadwalProvider>(
                context,
                listen: false,
            );

            ScaffoldMessenger.of(
                context,
            ).showSnackBar(const SnackBar(content: Text('Menghapus jadwal...')));

            final sukses = await jadwalProvider.deleteJadwal(
                jadwalId,
                widget.user.id.toString(),
            );

            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            if (sukses) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Jadwal berhasil dihapus'),
                        backgroundColor: Colors.green,
                    ),
                );
            } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Gagal menghapus jadwal'),
                        backgroundColor: Colors.red,
                    ),
                );
            }
        }
    }

    // --- FUNGSI 2: UBAH STATUS (CHECKLIST) ---
    Future<void> _toggleStatus(int jadwalId, bool currentIsBooked) async {
        final jadwalProvider = Provider.of<JadwalProvider>(context, listen: false);
        final String action = currentIsBooked
            ? "Batalkan Pesanan"
            : "Tandai Dipesan";

        bool? yakinUbah = await showDialog<bool>(
            context: context,
            builder: (BuildContext ctx) {
                return AlertDialog(
                    title: Text(action),
                    content: Text(
                        'Apakah Anda yakin ingin ${action.toLowerCase()} untuk jadwal ini?',
                    ),
                    actions: [
                        TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Batal'),
                        ),
                        TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: Text(action.split(' ').first),
                        ),
                    ],
                );
            },
        );

        if (yakinUbah == true) {
            ScaffoldMessenger.of(
                context,
            ).showSnackBar(SnackBar(content: Text('$action jadwal...')));

            final sukses = await jadwalProvider.updateJadwalStatus(
                jadwalId,
                !currentIsBooked, // Ubah kebalikan status (true -> false, false -> true)
                widget.user.id.toString(),
            );

            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            if (sukses) {
                await jadwalProvider.fetchJadwalMilikGuru(widget.user.id.toString());

                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Status berhasil diubah!'),
                        backgroundColor: Colors.green,
                    ),
                );
            } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Gagal mengubah status jadwal'),
                        backgroundColor: Colors.red,
                    ),
                );
            }
        }
    }

    // 🔥 WIDGET BARU: Daftar Ulasan yang Belum Dibalas
    Widget _buildUlasanMenungguBalasan() {
        if (_isLoadingUlasan) {
            return const Center(child: CircularProgressIndicator());
        }

        if (_ulasanList.isEmpty) {
            return Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: Center(
                    child: Text(
                        "Tidak ada ulasan baru yang menunggu balasan.",
                        style: TextStyle(color: Colors.grey[600]),
                    ),
                ),
            );
        }

        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                        "(${_ulasanList.length}) Ulasan Menunggu Balasan:",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                        ),
                    ),
                ),
                ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _ulasanList.length,
                    itemBuilder: (context, index) {
                        final ulasan = _ulasanList[index];
                        return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            elevation: 1,
                            child: ListTile(
                                leading: const Icon(Icons.comment, color: Colors.orange),
                                title: Text(ulasan.komentarMurid, maxLines: 1, overflow: TextOverflow.ellipsis),
                                subtitle: Text("Dari ${ulasan.namaMurid} (${ulasan.rating}⭐)"),
                                trailing: ElevatedButton(
                                    onPressed: () => _showReplyDialog(ulasan.ulasanId, ulasan.namaMurid, ulasan.komentarMurid),
                                    child: const Text("Balas", style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                            ),
                        );
                    },
                ),
                const SizedBox(height: 20),
            ],
        );
    }


    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text("Jadwal Mengajar Anda"),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
            ),
            body: SingleChildScrollView(
                child: Column(
                    children: [
                        // 🔥 BAGIAN BARU: ULASAN MENUNGGU BALASAN
                        _buildUlasanMenungguBalasan(),
                        
                        // PEMISAH
                        Divider(height: 1, color: Colors.grey[300]),
                        // 🔥 INTEGRASI INBOX CHAT GURU DI SINI
                        _buildChatInbox(context, widget),
                       
                        // BAGIAN JADWAL UTAMA
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                                "Daftar Jadwal Anda",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                ),
                            ),
                        ),
                        
                        Consumer<JadwalProvider>(
                            builder: (context, jadwalProvider, child) {
                                if (jadwalProvider.isLoadingJadwalGuru) {
                                    return const Center(
                                        child: CircularProgressIndicator(color: mintHighlight),
                                    );
                                }

                                final jadwalMilikGuru = jadwalProvider.jadwalMilikGuru;

                                if (jadwalMilikGuru.isEmpty) {
                                    return Center(
                                        child: Padding(
                                            padding: const EdgeInsets.all(30.0),
                                            child: Text(
                                                "Anda belum mengatur jadwal mengajar.\nTekan tombol '+' untuk menambah jadwal.",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(color: Colors.grey[600]),
                                            ),
                                        ),
                                    );
                                }

                                return ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(16.0),
                                    itemCount: jadwalMilikGuru.length,
                                    itemBuilder: (context, index) {
                                        final slot = jadwalMilikGuru[index];

                                        final String namaMapel = slot['nama_mapel'] ?? 'Tanpa Mapel';
                                        final String hari = slot['hari'] ?? 'Tanpa Hari';
                                        final String jamMulaiFull = slot['jam_mulai'] ?? '00:00';
                                        final String jamSelesaiFull = slot['jam_selesai'] ?? '00:00';
                                        final String jamMulai = jamMulaiFull.length >= 5 ? jamMulaiFull.substring(0, 5) : jamMulaiFull;
                                        final String jamSelesai = jamSelesaiFull.length >= 5 ? jamSelesaiFull.substring(0, 5) : jamSelesaiFull;
                                        final int jadwalId = slot['jadwal_id'];

                                        final bool isBooked = (slot['is_booked'] == 1 || slot['is_booked'] == true);
                                        final String statusText = isBooked ? 'Dipesan Murid' : 'Tersedia';
                                        final Color statusColor = isBooked ? Colors.red : Colors.green;

                                        return Card(
                                            elevation: 2,
                                            margin: const EdgeInsets.only(bottom: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            child: ListTile(
                                                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                                title: Text(namaMapel, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                subtitle: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                        Text("$hari, $jamMulai - $jamSelesai"),
                                                        const SizedBox(height: 4),
                                                        Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                                                    ],
                                                ),
                                                trailing: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                        // Tombol EDIT (Opsional)
                                                        if (widget.onEditJadwal != null)
                                                            IconButton(
                                                                icon: const Icon(Icons.edit, color: Colors.blueGrey),
                                                                onPressed: () {
                                                                    widget.onEditJadwal!(slot);
                                                                },
                                                                tooltip: 'Edit Jadwal',
                                                            ),

                                                        // Tombol CHECKLIST/STATUS BARU
                                                        IconButton(
                                                            icon: Icon(
                                                                isBooked ? Icons.check_box : Icons.check_box_outline_blank,
                                                                color: isBooked ? Colors.orange : Colors.grey[600],
                                                            ),
                                                            onPressed: () => _toggleStatus(jadwalId, isBooked),
                                                            tooltip: isBooked ? 'Batalkan Pesanan' : 'Tandai Dipesan',
                                                        ),

                                                        // Tombol HAPUS
                                                        IconButton(
                                                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                                                            onPressed: () {
                                                                _hapusJadwal(jadwalId);
                                                            },
                                                            tooltip: 'Hapus Jadwal',
                                                        ),
                                                    ],
                                                ),
                                            ),
                                        );
                                    },
                                );
                            },
                        ),
                    ],
                ),
            ),
        );
    }
}

// lib/pages/guru/guru_beranda_page.dart (Tambahkan widget ini)

// 🔥 WIDGET BARU: Daftar Inbox Chat
// 🔥 WIDGET BARU: Daftar Inbox Chat (SUDAH DIPERBAIKI)
Widget _buildChatInbox(BuildContext context, GuruBerandaPage widget) { // Ubah 'dynamic' jadi Tipe Asli biar aman
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Text(
                    "Pesan Masuk (Inbox)",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                    ),
                ),
            ),
            
            StreamBuilder<List<String>>(
                // ✅ PERBAIKAN 1: Gunakan ID (Angka), bukan Username
                stream: ChatService().getPeers(widget.user.id.toString()), 
                builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text("Belum ada pesan masuk."),
                            ),
                        );
                    }
                    
                    final peerIds = snapshot.data!;
                    
                    return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: peerIds.length,
                        itemBuilder: (context, index) {
                            final peerId = peerIds[index];
                            
                            // Tampilan Item Chat
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xFF3CB371), // Mint
                                    child: Icon(Icons.person, color: Colors.white)
                                  ),
                                  title: Text("Murid ID: $peerId"), // Nanti bisa diganti Nama
                                  subtitle: const Text("Ketuk untuk membalas..."), 
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                                  onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoomPage(
                                          // ✅ PERBAIKAN 2: Akses user lewat 'widget.user'
                                          currentUserId: widget.user.id.toString(),
                                          peerId: peerId,
                                          peerName: "Murid $peerId", 
                                      )));
                                  },
                              ),
                            );
                        },
                    );
                },
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.grey.shade400),
        ],
    );
}

