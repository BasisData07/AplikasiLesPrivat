import 'package:PRIVATE_AJA/pages/guru/pengaturan_guru.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:PRIVATE_AJA/pages/model/guru_mapel_model.dart';
import 'package:PRIVATE_AJA/pages/model/jadwal_provider.dart';
import 'package:PRIVATE_AJA/pages/model/user_model.dart';
import 'package:PRIVATE_AJA/pages/guru/chat_list_page.dart'; // Sesuaikan pathnya

// Halaman lain
import 'beranda_guru.dart';
import 'profil_guru.dart';

class GuruHomePage extends StatefulWidget {
  final UserModel user;
  const GuruHomePage({super.key, required this.user});

  @override
  State<GuruHomePage> createState() => _GuruHomePageState();
}

class _GuruHomePageState extends State<GuruHomePage> {
  int _selectedIndex = 0;
  static const Color mintHighlight = Colors.orange;

  late final List<Widget> _guruPages;

  @override
  void initState() {
    super.initState();

    _guruPages = <Widget>[
      // Tab 0: Beranda
      GuruBerandaPage(
        user: widget.user,
        onEditJadwal: (slot) => _showEditJadwalDialog(context, slot),
      ),

      // 🔥 BAGIAN YANG DIGANTI 🔥
      // Jangan pakai ChatRoomPage, pakai ChatListPage (Inbox)
      // Dan pastikan kirim ID sebagai String (bukan username)
      ChatListPage(
        currentUserId: widget.user.id.toString(),
      ),

      // Tab 2: Profil
      GuruProfilPage(user: widget.user),

      // Tab 3: Pengaturan
      GuruPengaturanPage(user: widget.user),
    ];

    // 🔧 Fetch mapel guru & jadwal saat pertama kali halaman dibuka
    Future.microtask(() {
      final jadwalProvider = Provider.of<JadwalProvider>(
        context,
        listen: false,
      );
      final guruId = widget.user.id.toString();
      jadwalProvider.fetchMapelGuru(guruId);
      jadwalProvider.fetchJadwalMilikGuru(guruId);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // ----------------------------------------------------
  // 🆕 FUNGSI HELPER: Membuka Time Picker
  // ----------------------------------------------------
  Future<void> _selectTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    TimeOfDay initialTime = TimeOfDay.now();

    // Coba parsing waktu saat ini dari controller
    if (controller.text.isNotEmpty) {
      try {
        final parts = controller.text.split(':');
        if (parts.length >= 2) {
          initialTime = TimeOfDay(
            // Pastikan parsing berhasil (menghindari error jika format salah)
            hour: int.tryParse(parts[0]) ?? initialTime.hour,
            minute: int.tryParse(parts[1]) ?? initialTime.minute,
          );
        }
      } catch (e) {
        // Biarkan default time jika parsing gagal
      }
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        // Menggunakan format 24 jam untuk konsistensi dengan format database TIME
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Format ke HH:MM
      final String formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

      controller.text = formattedTime;
    }
  }
  // ----------------------------------------------------

  // 🧩 Fungsi untuk menampilkan dialog TAMBAH jadwal
  void _showTambahJadwalDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final jamMulaiController = TextEditingController();
    final jamSelesaiController = TextEditingController();

    String selectedDay = 'Senin';
    final days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    int? selectedIdGuruMapel;

    // 🔥 FETCH TERBARU: Pastikan daftar mapel selalu fresh sebelum menampilkan dialog
    // Ini mencegah error foreign key jika mapel baru saja dihapus/diubah
    Future.microtask(() {
      Provider.of<JadwalProvider>(context, listen: false)
          .fetchMapelGuru(widget.user.id.toString());
    });

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Consumer<JadwalProvider>(
          builder: (context, jadwalProvider, child) {
            final listMapelGuru = jadwalProvider.mapelMilikGuru;
            final isLoading = jadwalProvider.isLoadingMapelGuru;

            if (!isLoading &&
                listMapelGuru.isNotEmpty &&
                selectedIdGuruMapel == null) {
              selectedIdGuruMapel = listMapelGuru.first.idGuruMapel;
            }

            return AlertDialog(
              title: const Text("Tambah Jadwal Baru"),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ... Bagian Mapel dan Hari (Tidak Berubah) ...
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
                        StatefulBuilder(
                          builder: (context, setStateSB) {
                            return DropdownButtonFormField<int>(
                              initialValue: selectedIdGuruMapel,
                              hint: const Text("Pilih Mata Pelajaran"),
                              decoration: const InputDecoration(
                                labelText: 'Mata Pelajaran',
                              ),
                              items: listMapelGuru.map((GuruMapelModel mapel) {
                                return DropdownMenuItem<int>(
                                  value: mapel.idGuruMapel,
                                  child: Text(mapel.namaMapel),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setStateSB(() {
                                  selectedIdGuruMapel = newValue;
                                });
                              },
                              validator: (value) =>
                                  value == null ? 'Mapel harus dipilih' : null,
                            );
                          },
                        ),
                      const SizedBox(height: 8),
                      StatefulBuilder(
                        builder: (context, setStateSB) {
                          return DropdownButtonFormField<String>(
                            initialValue: selectedDay,
                            decoration: const InputDecoration(
                              labelText: 'Hari',
                            ),
                            items: days.map((String day) {
                              return DropdownMenuItem<String>(
                                value: day,
                                child: Text(day),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setStateSB(() {
                                if (newValue != null) selectedDay = newValue;
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 8),

                      // ⬇️ PERUBAHAN UTAMA: Jam Mulai (dengan TimePicker)
                      TextFormField(
                        controller: jamMulaiController,
                        readOnly: true, // Tidak bisa input manual
                        onTap: () => _selectTime(
                          context,
                          jamMulaiController,
                        ), // Panggil Time Picker
                        decoration: const InputDecoration(
                          labelText: 'Jam Mulai',
                          hintText: 'HH:mm',
                          suffixIcon: Icon(Icons.access_time), // Ikon jam
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Jam mulai tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 8),

                      // ⬇️ PERUBAHAN UTAMA: Jam Selesai (dengan TimePicker)
                      TextFormField(
                        controller: jamSelesaiController,
                        readOnly: true, // Tidak bisa input manual
                        onTap: () => _selectTime(
                          context,
                          jamSelesaiController,
                        ), // Panggil Time Picker
                        decoration: const InputDecoration(
                          labelText: 'Jam Selesai',
                          hintText: 'HH:mm',
                          suffixIcon: Icon(Icons.access_time), // Ikon jam
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Jam selesai tidak boleh kosong'
                            : null,
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
                  onPressed: listMapelGuru.isEmpty ||
                          selectedIdGuruMapel == null
                      ? null
                      : () {
                          if (formKey.currentState!.validate()) {
                            FocusScope.of(context).unfocus();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Menyimpan jadwal...'),
                              ),
                            );

                            jadwalProvider
                                .createJadwalBaru(
                              idGuruMapel: selectedIdGuruMapel!,
                              hari: selectedDay,
                              jamMulai: jamMulaiController.text, // Format HH:MM
                              jamSelesai:
                                  jamSelesaiController.text, // Format HH:MM
                            )
                                .then((sukses) {
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();

                              if (sukses) {
                                jadwalProvider.fetchJadwalMilikGuru(
                                  widget.user.id.toString(),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Jadwal berhasil disimpan!',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Gagal menyimpan jadwal.',
                                    ),
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

  // 📝 Fungsi untuk menampilkan dialog EDIT jadwal
  void _showEditJadwalDialog(BuildContext context, Map<String, dynamic> slot) {
    final formKey = GlobalKey<FormState>();
    final int jadwalId = slot['jadwal_id'];
    // Di GuruHomePage.dart, di awal _showEditJadwalDialog

    // Ganti baris inisialisasi controller di awal fungsi:
    // String jamMulaiLama = (slot['jam_mulai'] as String?)?.substring(0, 5) ?? '00:00';
    // String jamSelesaiLama = (slot['jam_selesai'] as String?)?.substring(0, 5) ?? '00:00';

    // Dengan kode yang lebih aman:
    String getFormattedTime(dynamic timeValue) {
      final timeString = timeValue?.toString() ?? '00:00';
      return timeString.length >= 5 ? timeString.substring(0, 5) : '00:00';
    }

    String jamMulaiLama = getFormattedTime(slot['jam_mulai']);
    String jamSelesaiLama = getFormattedTime(slot['jam_selesai']);

    String selectedDay = slot['hari'] ?? 'Senin';

    final jamMulaiController = TextEditingController(text: jamMulaiLama);
    final jamSelesaiController = TextEditingController(text: jamSelesaiLama);

    final days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    final String namaMapelAwal = slot['nama_mapel'] ?? 'Pilih Mapel';

    final dynamic mapelIdDynamic =
        slot['id_guru_mapel'] ?? slot['id_gurumapel'] ?? slot['gurumapel_id'];
    int? idGuruMapelLama;
    if (mapelIdDynamic != null) {
      idGuruMapelLama = int.tryParse(mapelIdDynamic.toString());
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Consumer<JadwalProvider>(
          builder: (context, jadwalProvider, child) {
            return AlertDialog(
              title: Text("Edit Jadwal: $namaMapelAwal"),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- MAPEL (READ-ONLY) ---
                      TextFormField(
                        initialValue: namaMapelAwal,
                        readOnly: true,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Mata Pelajaran',
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // --- HARI (DROPDOWN) ---
                      StatefulBuilder(
                        builder: (context, setStateSB) {
                          return DropdownButtonFormField<String>(
                            initialValue: selectedDay,
                            decoration: const InputDecoration(
                              labelText: 'Hari',
                            ),
                            items: days.map((String day) {
                              return DropdownMenuItem<String>(
                                value: day,
                                child: Text(day),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setStateSB(() {
                                if (newValue != null) selectedDay = newValue;
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      // ⬇️ PERUBAHAN UTAMA: Jam Mulai (dengan TimePicker)
                      TextFormField(
                        controller: jamMulaiController,
                        readOnly: true, // Tidak bisa input manual
                        onTap: () => _selectTime(
                          context,
                          jamMulaiController,
                        ), // Panggil Time Picker
                        decoration: const InputDecoration(
                          labelText: 'Jam Mulai',
                          hintText: 'HH:mm',
                          suffixIcon: Icon(Icons.access_time), // Ikon jam
                        ),
                        // Hapus validator jika tidak wajib diisi. Saya biarkan wajib agar konsisten dengan CREATE
                        validator: (value) => value!.isEmpty
                            ? 'Jam mulai tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      // ⬇️ PERUBAHAN UTAMA: Jam Selesai (dengan TimePicker)
                      TextFormField(
                        controller: jamSelesaiController,
                        readOnly: true, // Tidak bisa input manual
                        onTap: () => _selectTime(
                          context,
                          jamSelesaiController,
                        ), // Panggil Time Picker
                        decoration: const InputDecoration(
                          labelText: 'Jam Selesai',
                          hintText: 'HH:mm',
                          suffixIcon: Icon(Icons.access_time), // Ikon jam
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Jam selesai tidak boleh kosong'
                            : null,
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
                // TOMBOL UPDATE
                ElevatedButton(
                  onPressed: idGuruMapelLama == null
                      ? null
                      : () {
                          if (formKey.currentState!.validate()) {
                            FocusScope.of(context).unfocus();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Mengupdate jadwal...'),
                              ),
                            );

                            jadwalProvider
                                .updateJadwal(
                              jadwalId: jadwalId,
                              idGuruMapel: idGuruMapelLama!,
                              hari: selectedDay,
                              jamMulai: jamMulaiController.text, // Format HH:MM
                              jamSelesai:
                                  jamSelesaiController.text, // Format HH:MM
                            )
                                .then((sukses) {
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();

                              if (sukses) {
                                jadwalProvider.fetchJadwalMilikGuru(
                                  widget.user.id.toString(),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Jadwal berhasil diupdate!',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Gagal mengupdate jadwal.',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            });
                          }
                        },
                  child: const Text("Update"),
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
    final List<Widget> pagesWithEdit = <Widget>[
      GuruBerandaPage(
        user: widget.user,
        onEditJadwal: (slot) => _showEditJadwalDialog(context, slot),
      ),

      // ✅ PERBAIKAN: Gunakan ChatListPage, bukan ChatRoomPage
      // Pastikan kirim user.id (Angka) yang diubah ke String
      ChatListPage(currentUserId: widget.user.id.toString()),

      GuruProfilPage(user: widget.user),
      GuruPengaturanPage(user: widget.user),
    ];

    return Scaffold(
      body: pagesWithEdit.elementAt(_selectedIndex),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Jadwal Les'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat Room',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Pengaturan',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
