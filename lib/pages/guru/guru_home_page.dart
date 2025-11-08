import 'package:PRIVATE_AJA/pages/model/guru_mapel_model.dart';
import 'package:PRIVATE_AJA/pages/model/jadwal_provider.dart';
import 'package:PRIVATE_AJA/pages/model/user_model.dart';
import 'package:PRIVATE_AJA/repositories/jadwal-repositoris.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Sesuaikan path ini jika perlu
 // [DIUBAH] Kita butuh model ini

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
  static const Color mintHighlight = Color(0xFF3CB371); // Anda bisa ganti ke Colors.orange

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

    // [DIUBAH] Ambil daftar mapel yang diajar guru ini saat halaman dibuka
    // Kita perlukan ini untuk mengisi dropdown "Pilih Mapel"
    Future.microtask(() =>
        Provider.of<JadwalProvider>(context, listen: false)
            .fetchMapelGuru(widget.user.id as String));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  // Di dalam file: lib/pages/guru/guru_home_page.dart


/*void _showTambahJadwalDialog(BuildContext context) {
  final formKey = GlobalKey<FormState>();
  
  final jamMulaiController = TextEditingController();
  final jamSelesaiController = TextEditingController();
  
  String selectedDay = 'Senin';
  final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  
  int? selectedIdGuruMapel;

  // [DIBENAHI] Hapus 'context.read' dari sini.

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      
      // [DIBENAHI] Bungkus konten AlertDialog dengan 'Consumer'
      // Ini akan membuat dialog "mendengarkan" perubahan data mapel
      return Consumer<JadwalProvider>(
        builder: (context, jadwalProvider, child) {
          
          // Ambil data mapel DARI DALAM Consumer
          final listMapelGuru = jadwalProvider.mapelMilikGuru;
          final isLoadingMapel = jadwalProvider.isLoadingMapelGuru;

          return AlertDialog(
            title: const Text("Tambah Jadwal Baru"),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    
                    // --- Dropdown Pilih Mapel (Sekarang Dinamis) ---
                    
                    if (isLoadingMapel)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    
                    // Pesan error ini (image_b3503e.png) sekarang akan hilang
                    // jika data berhasil di-load
                    if (!isLoadingMapel && listMapelGuru.isEmpty)
                      const Text(
                        "Anda belum terdaftar mengajar mapel apapun. (Cek DB guru_mapel)",
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    
                    if (!isLoadingMapel && listMapelGuru.isNotEmpty)
                      DropdownButtonFormField<int>(
                        value: selectedIdGuruMapel,
                        hint: const Text("Pilih Mata Pelajaran"),
                        decoration: const InputDecoration(labelText: 'Mata Pelajaran'),
                        items: listMapelGuru.map((GuruMapelModel mapel) {
                          return DropdownMenuItem<int>(
                            value: mapel.idGuruMapel,
                            child: Text(mapel.namaMapel),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) selectedIdGuruMapel = newValue;
                        },
                        validator: (value) => value == null ? 'Mapel harus dipilih' : null,
                      ),
                      
                    const SizedBox(height: 8),

                    // --- Sisa Form (Sudah Benar) ---
                    DropdownButtonFormField<String>(
                      value: selectedDay,
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
                      controller: jamMulaiController,
                      decoration: const InputDecoration(labelText: 'Jam Mulai', hintText: 'HH:mm (Contoh: 10:00)'),
                      validator: (value) => value!.isEmpty ? 'Jam mulai tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: jamSelesaiController,
                      decoration: const InputDecoration(labelText: 'Jam Selesai', hintText: 'HH:mm (Contoh: 12:00)'),
                      validator: (value) => value!.isEmpty ? 'Jam selesai tidak boleh kosong' : null,
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
                // [DIBENAHI] Nonaktifkan tombol simpan jika mapel kosong
                onPressed: listMapelGuru.isEmpty ? null : () { 
                  if (formKey.currentState!.validate()) {
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Menyimpan jadwal...')),
                    );

                    jadwalProvider.createJadwalBaru(
                      idGuruMapel: selectedIdGuruMapel!,
                      hari: selectedDay,
                      jamMulai: jamMulaiController.text,
                      jamSelesai: jamSelesaiController.text,
                    ).then((sukses) {
                      
                      Navigator.of(dialogContext).pop(); 
                      ScaffoldMessenger.of(context).hideCurrentSnackBar(); 

                      if (sukses) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Jadwal baru berhasil disimpan!'), backgroundColor: Colors.green),
                        );
                        // [DIBENAHI] Refresh daftar jadwal setelah sukses
                        jadwalProvider.fetchJadwalMilikGuru(widget.user.id.toString());
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal menyimpan jadwal.'), backgroundColor: Colors.red),
                        );
                      }
                    });
                  }
                },
                child: const Text("Simpan"),
              ),
            ],
          );
        }, // <-- Akhir dari Consumer
      );
    },
  );*/

  // [DIUBAH] Seluruh fungsi dialog dirombak
  void _showTambahJadwalDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    
    // Controller baru
    final jamMulaiController = TextEditingController();
    final jamSelesaiController = TextEditingController();
    
    // Variabel untuk dropdown
    String selectedDay = 'Senin'; // Nilai default hari
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    
    // Variabel untuk dropdown mapel (yang diambil dari API)
    int? selectedIdGuruMapel; // Wajib diisi

    // Ambil daftar mapel dari provider
    final listMapelGuru = context.read<JadwalProvider>().mapelMilikGuru;

   showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Gunakan StatefulWidgetBuilder agar Dropdown bisa di-update
        return AlertDialog(
          title: const Text("Tambah Jadwal Baru"),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Dropdown Pilih Mapel (BARU) ---
                  if (listMapelGuru.isEmpty)
                    const Text("Anda belum terdaftar mengajar mapel apapun. (Cek DB guru_mapel)", style: TextStyle(color: Colors.red)),
                  
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
                      if (newValue != null) selectedIdGuruMapel = newValue;
                    },
                    validator: (value) => value == null ? 'Mapel harus dipilih' : null,
                  ),
                  const SizedBox(height: 8),

                  // --- Dropdown Pilih Hari (Lama) ---
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

                  // --- Text Field Jam Mulai (BARU) ---
                  TextFormField(
                    controller: jamMulaiController,
                    decoration: const InputDecoration(labelText: 'Jam Mulai', hintText: 'HH:mm (Contoh: 10:00)'),
                    validator: (value) => value!.isEmpty ? 'Jam mulai tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 8),

                  // --- Text Field Jam Selesai (BARU) ---
                  TextFormField(
                    controller: jamSelesaiController,
                    decoration: const InputDecoration(labelText: 'Jam Selesai', hintText: 'HH:mm (Contoh: 12:00)'),
                    validator: (value) => value!.isEmpty ? 'Jam selesai tidak boleh kosong' : null,
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
                // [DIUBAH] Logika simpan
                if (formKey.currentState!.validate()) {
                  // Ambil provider (listen: false karena di dalam fungsi)
                  final jadwalProvider = context.read<JadwalProvider>();

                  // Tampilkan loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Menyimpan jadwal...')),
                  );

                  // Panggil API
                  jadwalProvider.createJadwalBaru(
                    idGuruMapel: selectedIdGuruMapel!,
                    hari: selectedDay,
                    jamMulai: jamMulaiController.text,
                    jamSelesai: jamSelesaiController.text,
                  ).then((sukses) {
                    
                    Navigator.of(dialogContext).pop(); // Tutup dialog
                    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Tutup loading

                    if (sukses) {
                      // Jika sukses, refresh daftar jadwal di beranda guru
                      jadwalProvider.fetchJadwalMilikGuru(widget.user.id as String);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Jadwal baru berhasil disimpan!'), backgroundColor: Colors.green),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal menyimpan jadwal.'), backgroundColor: Colors.red),
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
      floatingActionButton: _selectedIndex == 0 // Tampilkan hanya di tab Beranda
          ? FloatingActionButton(
              onPressed: () => _showTambahJadwalDialog(context),
              backgroundColor: Colors.orange,
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