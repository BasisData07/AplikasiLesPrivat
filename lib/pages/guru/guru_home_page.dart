import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:PRIVATE_AJA/pages/model/guru_mapel_model.dart';
import 'package:PRIVATE_AJA/pages/model/jadwal_provider.dart';
import 'package:PRIVATE_AJA/pages/model/user_model.dart';
import 'package:PRIVATE_AJA/repositories/jadwal-repositoris.dart';

// Halaman lain
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
      ChatRoomGuruPage(user: widget.user),
      GuruProfilPage(user: widget.user),
      const EditProfilGuruPage(),
    ];

    // 🔧 Fetch mapel guru saat pertama kali halaman dibuka
    Future.microtask(() {
      final jadwalProvider = Provider.of<JadwalProvider>(context, listen: false);
      jadwalProvider.fetchMapelGuru(widget.user.id.toString());
      jadwalProvider.fetchJadwalMilikGuru(widget.user.id.toString());
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 🧩 Fungsi untuk menampilkan dialog tambah jadwal
  void _showTambahJadwalDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final jamMulaiController = TextEditingController();
    final jamSelesaiController = TextEditingController();

    String selectedDay = 'Senin';
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    int? selectedIdGuruMapel;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Consumer<JadwalProvider>(
          builder: (context, jadwalProvider, child) {
            final listMapelGuru = jadwalProvider.mapelMilikGuru;
            final isLoading = jadwalProvider.isLoadingMapelGuru;

            return AlertDialog(
              title: const Text("Tambah Jadwal Baru"),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      if (!isLoading && listMapelGuru.isEmpty)
                        const Text(
                          "Anda belum terdaftar mengajar mapel apapun.\n(Cek tabel guru_mapel di database)",
                          style: TextStyle(color: Colors.red, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      if (!isLoading && listMapelGuru.isNotEmpty)
                        DropdownButtonFormField<int>(
                          initialValue: selectedIdGuruMapel,
                          hint: const Text("Pilih Mata Pelajaran"),
                          decoration: const InputDecoration(labelText: 'Mata Pelajaran'),
                          items: listMapelGuru.map((GuruMapelModel mapel) {
                            return DropdownMenuItem<int>(
                              value: mapel.idGuruMapel,
                              child: Text(mapel.namaMapel),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            selectedIdGuruMapel = newValue;
                          },
                          validator: (value) =>
                              value == null ? 'Mapel harus dipilih' : null,
                        ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: selectedDay,
                        decoration: const InputDecoration(labelText: 'Hari'),
                        items: days.map((String day) {
                          return DropdownMenuItem<String>(
                            value: day,
                            child: Text(day),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) selectedDay = newValue;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: jamMulaiController,
                        decoration: const InputDecoration(
                          labelText: 'Jam Mulai',
                          hintText: 'HH:mm (Contoh: 10:00)',
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Jam mulai tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: jamSelesaiController,
                        decoration: const InputDecoration(
                          labelText: 'Jam Selesai',
                          hintText: 'HH:mm (Contoh: 12:00)',
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Jam selesai tidak boleh kosong' : null,
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
                  onPressed: listMapelGuru.isEmpty
                      ? null
                      : () {
                          if (formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Menyimpan jadwal...')),
                            );

                            jadwalProvider
                                .createJadwalBaru(
                              idGuruMapel: selectedIdGuruMapel!,
                              hari: selectedDay,
                              jamMulai: jamMulaiController.text,
                              jamSelesai: jamSelesaiController.text,
                            )
                                .then((sukses) {
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();

                              if (sukses) {
                                jadwalProvider.fetchJadwalMilikGuru(
                                    widget.user.id.toString());
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Jadwal berhasil disimpan!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Gagal menyimpan jadwal.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            });
                          }
                        },
                  child: const Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guru Dashboard'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: _guruPages.elementAt(_selectedIndex),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => _showTambahJadwalDialog(context),
              backgroundColor: Colors.orange,
              tooltip: 'Tambah Jadwal',
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
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
