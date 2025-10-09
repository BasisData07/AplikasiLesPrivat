import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'model/guru_model.dart';
import 'model/guru_provider.dart';
import 'login_page.dart';
import 'edit_guru_page.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  // FUNGSI BARU UNTUK MENGAMBIL GAMBAR DARI URL ATAU ASSET
  ImageProvider getImage(String path) {
    if (path.isEmpty) {
      return const AssetImage("assets/panda.png");
    }
    try {
      // Cek jika path adalah URL, gunakan NetworkImage. Jika tidak, gunakan AssetImage.
      return path.startsWith('http')
          ? NetworkImage(path)
          : AssetImage(path) as ImageProvider;
    } catch (e) {
      // Jika terjadi error (misal URL tidak valid), tampilkan gambar default
      return const AssetImage("assets/panda.png");
    }
  }

  @override
  Widget build(BuildContext context) {
    final guruProvider = context.watch<GuruProvider>();
    final List<Guru> guruList = guruProvider.guruList;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel - Manajemen Guru"),
        backgroundColor: const Color.fromARGB(255, 24, 24, 194),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () {
              // Kembali ke halaman login
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        itemCount: guruList.length,
        itemBuilder: (context, index) {
          final guru = guruList[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                radius: 25,
                // --- BAGIAN INI DIUBAH ---
                // Memanggil fungsi getImage untuk menampilkan foto
                backgroundImage: getImage(guru.photo),
              ),
              title: Text(
                guru.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Status: ${guru.isApproved ? 'Disetujui' : 'Menunggu Persetujuan'}",
                style: TextStyle(
                  color: guru.isApproved
                      ? Colors.green[600]
                      : Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: guru.isApproved
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            color: const Color.fromARGB(255, 24, 24, 194),
                          ),
                          tooltip: "Edit",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditGuruPage(guru: guru, isDarkMode: false),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.pink[700],
                          ),
                          tooltip: "Hapus",
                          onPressed: () => _showDeleteDialog(context, guru),
                        ),
                      ],
                    )
                  : TextButton(
                      child: const Text("Setujui"),
                      onPressed: () {
                        context.read<GuruProvider>().approveGuru(guru);
                      },
                    ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Guru guru) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Anda yakin ingin menghapus guru bernama ${guru.name}?'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
            onPressed: () {
              context.read<GuruProvider>().hapusGuru(guru);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
