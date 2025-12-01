import 'package:PRIVATE_AJA/pages/murid/chat_room_page.dart';
import 'package:PRIVATE_AJA/services/api_service.dart';
import 'package:PRIVATE_AJA/services/guru_service.dart';
import 'package:PRIVATE_AJA/services/ulasan_service.dart';    
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; 

import '../model/guru_model.dart';
import '../model/ulasan_model.dart';
import '../model/user_model.dart';
import '../model/jadwal_provider.dart';
import '../murid/home_page.dart';

class DetailGuruPage extends StatefulWidget {
    final Guru guru;
    final bool isDarkMode;
    final List<Guru> favoriteTeachers;
    final UserModel user;

    const DetailGuruPage({
        super.key,
        required this.guru,
        required this.isDarkMode,
        this.favoriteTeachers = const [],
        required this.user,
    });

    @override
    State<DetailGuruPage> createState() => _DetailGuruPageState();
}

class _DetailGuruPageState extends State<DetailGuruPage> {
    static const Color mintHighlight = Colors.orange;
    static const Color lightMintBackground = Color(0xFFF5FFFA);

    bool _isLoading = true;
    Map<String, dynamic>? _detailGuruData;
    
    // 🔥 STATE UNTUK FITUR ULASAN
    List<UlasanModel> _ulasanList = []; 
    double _currentRating = 3.0; 
    final TextEditingController _ulasanController = TextEditingController();


    @override
    void initState() {
        super.initState();
        _fetchGuruDetail();
        _fetchUlasan(); // Panggil fetch ulasan
    }
    
    @override
    void dispose() {
        _ulasanController.dispose();
        super.dispose();
    }

    Future<void> _fetchGuruDetail() async {
        final guruId = widget.guru.id;
        if (guruId.isEmpty) {
            if (mounted) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ID Guru tidak valid.')),
                );
            }
            return;
        }
        
        final data = await GuruService.getDetailGuru(guruId);
        
        if (mounted) {
            setState(() {
                _detailGuruData = data?['data']; 
                _isLoading = false;
            });
        }
    }

    Future<void> _fetchUlasan() async {
        final guruId = widget.guru.id;
        if (guruId.isEmpty) return;

        try {
            final ulasan = await UlasanService.getUlasanByGuruId(guruId);
            if (mounted) {
                setState(() {
                    _ulasanList = ulasan;
                });
            }
        } catch (e) {
            print("Failed to fetch reviews: $e");
            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal memuat ulasan.')),
                );
            }
        }
    }
    
    // --- DIALOG MURID MEMBERI ULASAN ---
    void _showGuruRatingDialog() {
        showDialog(
            context: context,
            builder: (context) {
                return AlertDialog(
                    title: Text("Nilai Guru ${widget.guru.nama}"),
                    content: SingleChildScrollView(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                const Text("Beri rating dan ulasan Anda untuk guru ini:"),
                                const SizedBox(height: 16),
                                RatingBar.builder(
                                    initialRating: _currentRating,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                                    onRatingUpdate: (rating) {
                                        _currentRating = rating; // Update variabel state lokal
                                    },
                                ),
                                const SizedBox(height: 20),
                                TextField(
                                    controller: _ulasanController,
                                    maxLines: 3,
                                    decoration: const InputDecoration(
                                        hintText: "Tulis komentar Anda...",
                                        border: OutlineInputBorder(),
                                    ),
                                ),
                            ],
                        ),
                    ),
                    actions: [
                        TextButton(child: const Text("Batal"), onPressed: () => Navigator.of(context).pop()),
                        ElevatedButton(
                            child: const Text("Kirim Ulasan"),
                            onPressed: () async {
                                final ratingValue = _currentRating;
                                final komentar = _ulasanController.text.trim();
                                
                                if (komentar.isEmpty || ratingValue < 1) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Rating dan komentar wajib diisi.")),
                                    );
                                    return;
                                }
                                
                                // PANGGIL SERVICE UNTUK MENGIRIM ULASAN
                                final response = await UlasanService.submitUlasan(
                                    guruId: widget.guru.id,
                                    penggunaId: widget.user.id.toString(), // ID Murid yang sedang login
                                    rating: ratingValue,
                                    komentar: komentar,
                                );

                                if (mounted) {
                                    Navigator.of(context).pop();
                                    if (response['success'] == true) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(response['message'] ?? "Ulasan berhasil dikirim!"))
                                        );
                                        _ulasanController.clear();
                                        _fetchUlasan(); // Refresh list ulasan di halaman
                                    } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(response['message'] ?? "Gagal mengirim ulasan.")),
                                        );
                                    }
                                }
                            },
                        ),
                    ],
                );
            },
        ).then((_) {
            // Reset rating setelah dialog ditutup
            setState(() => _currentRating = 3.0);
        });
    }

    // --- UTILITY METHODS ---
    
    ImageProvider getImage(String? path) {
        if (path == null || path.isEmpty) {
            return const AssetImage("assets/panda.png");
        }
        try {
            if (path.startsWith('http')) {
                return NetworkImage(path);
            } else {
                if (path.contains("assets/")) {
                    return AssetImage(path);
                }
                return NetworkImage("${ApiService.baseImgUrl}$path");
            }
        } catch (e) {
            return const AssetImage("assets/panda.png");
        }
    }

    Future<void> _launchCV(BuildContext context) async {
        String? cvFile = _detailGuruData?['file_sertifikat'] ?? widget.guru.cvUrl;

        if (cvFile != null && cvFile.isNotEmpty) {
            final String fullUrl = cvFile.startsWith('http')
                ? cvFile
                : "${ApiService.baseImgUrl}$cvFile";
            final Uri url = Uri.parse(fullUrl);
            if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tidak dapat membuka dokumen')),
                    );
                }
            }
        } else {
            if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('CV/Sertifikat guru belum tersedia.')),
                );
            }
        }
    }

    @override
    Widget build(BuildContext context) {
        final bgColor = widget.isDarkMode ? Colors.grey[900] : lightMintBackground;
        final cardColor = widget.isDarkMode ? Colors.grey[850] : Colors.white;
        final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
        final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.grey[600];

        // --- MAPPING KEY DARI API & FALLBACK MODEL ---
        final String displayName = _detailGuruData?['nama_lengkap'] ?? widget.guru.nama;
        final String displayBio = _detailGuruData?['bio_deskripsi'] ?? widget.guru.deskripsi;
        final String displayLevel = _detailGuruData?['list_jenjang'] ?? widget.guru.kategori_jenjang; 
        final String displayLokasi = _detailGuruData?['domisili'] ?? widget.guru.kota;
        final String displayTelpon = _detailGuruData?['no_telpon'] ?? widget.guru.noTelepon;
            
        final String displayPengalamanRaw = 
          _detailGuruData?['pengalaman_tahun']?.toString() ?? widget.guru.pengalaman.replaceAll(' Thn', '');
        final String displayPengalaman = displayPengalamanRaw.split(' ').first;

        final String displayHarga = "Rp ${(_detailGuruData?['harga'] ?? widget.guru.harga)}K";
        
        final String displayMapelString = _detailGuruData?['list_mapel'] ?? widget.guru.mapel;
        
        final double displayRating = (_detailGuruData?['rating'] is num) 
          ? (_detailGuruData!['rating'] as num).toDouble() 
          : widget.guru.rating;
        
        final String? displayFoto = _detailGuruData?['foto_profil_guru'] ?? widget.guru.foto;
        // -----------------------------------------------------------------

        return Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(
                title: Text(
                    "Profil Guru",
                    style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87),
                ),
                backgroundColor: bgColor,
                elevation: 0,
                iconTheme: IconThemeData(color: widget.isDarkMode ? Colors.white : Colors.black87),
            ),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              // Bagian Foto dan Nama
                              Row(
                                  children: [
                                      CircleAvatar(radius: 45, backgroundColor: Colors.grey[200], backgroundImage: getImage(displayFoto)),
                                      const SizedBox(width: 16),
                                      Expanded(
                                          child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                  Text(displayName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                      children: [
                                                          Icon(Icons.location_on, size: 14, color: subTextColor),
                                                          Text(" $displayLokasi", style: TextStyle(fontSize: 14, color: subTextColor)),
                                                      ],
                                                  ),
                                              ],
                                          ),
                                      ),
                                  ],
                              ),
                              const SizedBox(height: 24),
                              // Bagian Statistik
                              _buildStatsCard(cardColor, textColor, subTextColor, displayPengalaman, displayHarga, displayRating),
                              const SizedBox(height: 24),
                              
                              // 🔥 TOMBOL ULASAN MURID (HANYA MUNCUL JIKA MURID)
                              if (widget.user.role == 'murid') 
                                Center(
                                    child: ElevatedButton.icon(
                                        onPressed: _showGuruRatingDialog,
                                        icon: const Icon(Icons.star_half),
                                        label: const Text("Beri Ulasan & Rating"),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: mintHighlight,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                    ),
                                ),
                              const SizedBox(height: 24),
                              
                              // Bagian Deskripsi
                              _buildSectionTitle("Tentang Guru", textColor),
                              const SizedBox(height: 8),
                              Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                                  child: Text(displayBio.isEmpty ? "Guru belum mengisi deskripsi diri." : displayBio, style: TextStyle(fontSize: 15, height: 1.5, color: textColor)),
                              ),
                              const SizedBox(height: 24),
                              // Bagian Detail (Tingkat, Telepon, CV)
                              _buildSectionTitle("Informasi Detail", textColor),
                              const SizedBox(height: 8),
                              Container(
                                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                                  child: Column(
                                      children: [
                                          _buildInfoRow(Icons.school_outlined, "Tingkat", displayLevel.split(', ').first, subTextColor, textColor),
                                          const Divider(height: 1),
                                          _buildInfoRow(Icons.location_city_outlined, "Domisili", displayLokasi, subTextColor, textColor),
                                          const Divider(height: 1),
                                          _buildInfoRow(Icons.phone_outlined, "No. Telepon", displayTelpon, subTextColor, textColor),
                                          const Divider(height: 1),
                                          _buildTappableInfoRow(Icons.description_outlined, "Lihat CV / Sertifikat", subTextColor, () => _launchCV(context)),
                                      ],
                                  ),
                              ),
                              const SizedBox(height: 24),
                              // Bagian Mata Pelajaran
                              _buildSectionTitle("Daftar Mata Pelajaran", textColor),
                              const SizedBox(height: 8),
                              Wrap(spacing: 8, runSpacing: 8, children: displayMapelString.split(', ').where((mapel) => mapel.trim().isNotEmpty).map((mapel) { return Chip(label: Text(mapel, style: const TextStyle(color: Colors.white)), backgroundColor: mintHighlight); }).toList()),
                              const SizedBox(height: 24),

                              // 🔥 Bagian Ulasan (Rating & Komentar)
                              _buildUlasanSection(textColor, subTextColor),
                              const SizedBox(height: 24),
                              // Bagian Jadwal
                              _buildSectionTitle("Jadwal Ketersediaan", textColor),
                              const SizedBox(height: 8),
                              _buildJadwalSection(context),
                              const SizedBox(height: 40),
                          ],
                      ),
                  ),
            bottomNavigationBar: _buildActionButtons(context),
        );
    }
    
    // --- WIDGET HELPER ---
    
    // 🔥 METHOD Ulasan Section
    Widget _buildUlasanSection(Color textColor, Color? subTextColor) {
        if (_ulasanList.isEmpty) {
            return const Center(child: Text("Belum ada ulasan untuk guru ini."));
        }

        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                _buildSectionTitle("Ulasan Murid (${_ulasanList.length})", textColor),
                const SizedBox(height: 10),
                ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _ulasanList.length,
                    itemBuilder: (context, index) {
                        final ulasan = _ulasanList[index];
                        return Card(
                            color: widget.isDarkMode ? Colors.grey[850] : Colors.white,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        Row(
                                            children: [
                                                const Icon(Icons.star, color: Colors.amber, size: 18),
                                                Text(" ${ulasan.rating.toString()}", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                                                const Spacer(),
                                                Text(ulasan.namaMurid, style: TextStyle(color: subTextColor)),
                                            ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(ulasan.komentarMurid, style: TextStyle(color: textColor)),

                                        if (ulasan.balasanGuru != null && ulasan.balasanGuru!.isNotEmpty)
                                            Padding(
                                                padding: const EdgeInsets.only(top: 10, left: 16),
                                                child: Text("Balasan Guru: ${ulasan.balasanGuru}", style: const TextStyle(fontStyle: FontStyle.italic, color: mintHighlight)),
                                            ),
                                    ],
                                ),
                            ),
                        );
                    },
                ),
            ],
        );
    }
    
    // 🔥 METHOD Jadwal Section
    Widget _buildJadwalSection(BuildContext context) {
        return Consumer<JadwalProvider>(
            builder: (context, jadwalProvider, child) {
                final jadwal = jadwalProvider.getJadwalForGuru(widget.guru.email);
                if (jadwal.isEmpty) {
                    return Center(
                        child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                                "Guru ini belum menyediakan jadwal.",
                                style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.grey),
                            ),
                        ),
                    );
                }
                return Card(
                    color: widget.isDarkMode ? Colors.grey[850] : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                    child: Column(
                        children: jadwal.map((slot) {
                            return ListTile(
                                title: Text("${slot.hari} ", style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87)),
                                subtitle: Text(slot.jam, style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.grey[600])),
                                trailing: Chip(
                                    label: Text(slot.isBooked ? "Dipesan" : "Tersedia", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                    backgroundColor: slot.isBooked ? Colors.redAccent : Colors.green,
                                ),
                            );
                        }).toList(),
                    ),
                );
            },
        );
    }

    Widget _buildSectionTitle(String title, Color textColor) { 
        return Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)); 
    }
    
    Widget _buildStatsCard(Color? cardColor, Color textColor, Color? subTextColor, String peng, String hrg, double rating) {
        return Card(
            color: cardColor,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                        _buildRatingStatItem(rating, textColor, subTextColor),
                        _buildStatItem(Icons.work_outline, peng, "Tahun", textColor, subTextColor),
                        _buildStatItem(Icons.price_change_outlined, hrg.replaceAll('Rp ', ''), "/ Jam", textColor, subTextColor),
                    ],
                ),
            ),
        );
    }

    Widget _buildRatingStatItem(double rating, Color textColor, Color? subTextColor) {
        Color getRatingColor(double rating) {
            if (rating >= 4.5) return Colors.green;
            if (rating >= 3.5) return Colors.lightGreen;
            if (rating >= 2.5) return Colors.amber;
            if (rating > 0) return Colors.orange;
            return Colors.grey;
        }

        final String displayRating = rating > 0 ? rating.toString() : "Baru";

        return Column(
            children: [
                Icon(rating > 0 ? Icons.star : Icons.star_border, color: rating > 0 ? getRatingColor(rating) : Colors.grey, size: 28),
                const SizedBox(height: 8),
                Text(displayRating, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 4),
                Text("Rating", style: TextStyle(fontSize: 12, color: subTextColor)),
            ],
        );
    }

    Widget _buildStatItem(IconData icon, String value, String label, Color textColor, Color? subTextColor) {
        return Column(
            children: [
                Icon(icon, color: mintHighlight, size: 28),
                const SizedBox(height: 8),
                Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 4),
                Text(label, style: TextStyle(fontSize: 12, color: subTextColor)),
            ],
        );
    }

    Widget _buildInfoRow(IconData icon, String title, String value, Color? subTextColor, Color textColor, {double verticalPadding = 12.0}) {
        return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: verticalPadding),
            child: Row(
                children: [
                    Icon(icon, color: subTextColor, size: 20),
                    const SizedBox(width: 16),
                    Text(title, style: TextStyle(fontSize: 15, color: subTextColor)),
                    const Spacer(),
                    Expanded(
                        child: Text(
                            value,
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                        ),
                    ),
                ],
            ),
        );
    }

    Widget _buildTappableInfoRow(IconData icon, String title, Color? subTextColor, VoidCallback onTap, {double verticalPadding = 12.0}) {
        return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: verticalPadding),
                child: Row(
                    children: [
                        Icon(icon, color: subTextColor, size: 20),
                        const SizedBox(width: 16),
                        Text(title, style: TextStyle(fontSize: 15, color: subTextColor)),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios, size: 16, color: subTextColor),
                    ],
                ),
            ),
        );
    }

    Widget _buildActionButtons(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Row(
                children: [
                    Expanded(
                        child: OutlinedButton.icon(
                                icon: const Icon(Icons.chat_bubble_outline),
                                label: const Text("Chat Guru"),
                                
                                // 🔥 GANTI BAGIAN ONPRESSED INI:
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatRoomPage(
                                        // ✅ PERBAIKAN UTAMA: Gunakan ID (Angka), bukan Username/Email
                                        // Pastikan widget.user.id itu int, jadi kita .toString()
                                        currentUserId: widget.user.id.toString(), 
                                        
                                        // ID Guru biasanya sudah String angka ("15"), tapi untuk aman kita toString() juga
                                        peerId: widget.guru.id.toString(),
                                        
                                        // Nama untuk judul chat
                                        peerName: widget.guru.nama,
                                      ),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(), // Style biarkan saja
                              ),
                    ),
                    const SizedBox(width: 16),
                    // Tombol Favorit
                    ElevatedButton(
                        onPressed: () {
                            bool isAlreadyFavorite = widget.favoriteTeachers.any((favGuru) => favGuru.email == widget.guru.email);

                            if (isAlreadyFavorite) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Guru ini sudah ada di daftar favorit Anda."), backgroundColor: Colors.orange));
                                return;
                            }

                            final updatedFavorites = [...widget.favoriteTeachers, widget.guru];

                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Guru telah ditambahkan ke favorit!"), backgroundColor: Colors.green));

                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => MyHomePage(user: widget.user, initialIndex: 1, favoriteTeachers: updatedFavorites)),
                                (route) => route.isFirst,
                            );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: mintHighlight, minimumSize: const Size(50, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: mintHighlight))),
                        child: const Icon(Icons.favorite_border),
                    ),
                ],
            ),
        );
    }
}