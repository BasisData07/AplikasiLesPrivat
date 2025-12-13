import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'edit_guru_page.dart';
import '../model/guru_model.dart';
import '../../services/api_service.dart'; // For fetching detail if needed
import '../model/guru_provider.dart'; // Helper conversion
import 'package:provider/provider.dart'; // If using provider

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<dynamic> _users = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthService.getAllUsers();
      if (result['success'] == true) {
        setState(() {
          _users = result['data'];
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
        _errorMessage = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteUser(int id, String role) async {
    // Tampilkan dialog konfirmasi
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengguna'),
        content: Text('Apakah Anda yakin ingin menghapus $role ini?'),
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

    // Lakukan penghapusan
    setState(() => _isLoading = true);

    final result = await AuthService.deleteUserByAdmin(id, role);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Proses selesai'),
          backgroundColor:
              result['success'] == true ? Colors.green : Colors.red,
        ),
      );

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        _fetchUsers(); // Refresh list
      }
    }
  }

  Future<void> _editGuru(Map<String, dynamic> user) async {
    try {
      // 1. Fetch FULL detail guru
      final detail = await ApiService.get('profile/detail/${user['id']}');

      if (detail['success'] == true && detail['data'] != null) {
        // 2. Convert to Guru Model
        // We need GuruProvider instance to use convertGuruFromJson helper
        // or just instantiate it manually if we don't want to use provider link here.
        // But convertGuruFromJson is instance method of GuruProvider.
        // Let's create a temporary provider instance or make it static?
        // convertGuruFromJson reads from JSON.

        final provider = GuruProvider();
        // We need to merge user['id'] + detail['data'] because detail might not have ID
        // (backend detail response structure: { data: { nama_lengkap... } })
        final fullJson = detail['data'];
        fullJson['id'] = user['id'];
        fullJson['email'] = user['email'];
        // map fields

        final guruObj = provider.convertGuruFromJson(fullJson);

        if (mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    EditGuruPage(guru: guruObj, isDarkMode: false)),
          );
          _fetchUsers(); // Refresh after edit
        }
      } else {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Gagal ambil detail: ${detail['message']}')));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
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
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchUsers,
              child: const Text('Coba Lagi'),
            )
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return const Center(child: Text('Belum ada pengguna terdaftar'));
    }

    return ListView.builder(
      itemCount: _users.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final user = _users[index];
        final isGuru = user['role'] == 'guru';
        final roleColor = isGuru ? Colors.orangeAccent : Colors.green;
        final roleLabel = isGuru ? 'Guru' : 'Murid';

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: roleColor.withOpacity(0.2),
              child: Icon(
                isGuru ? Icons.school : Icons.person,
                color: roleColor,
              ),
            ),
            title: Text(
              user['username'] ?? 'No Name',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['email'] ?? '-'),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: roleColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    roleLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isGuru)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                    onPressed: () => _editGuru(user),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteUser(user['id'], user['role']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
