import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutMePage extends StatelessWidget {
  const AboutMePage({super.key});

  final List<Map<String, String>> _members = const [
    {
      'name': 'Qolbun Halim H',
      'nim': '24111814065',
      'photo': 'assets/qolbun.jpg', 
      'github': 'https://github.com/byeone001',
    },
    {
      'name': 'Prima MIftakhul R',
      'nim': '24111814005',
      'photo': 'assets/rahma.jpg',
      'github': 'https://github.com/PrimaRahma',
    },
    {
      'name': 'Pratama Dicky N',
      'nim': '24111814143',
      'photo': 'assets/dicky.jpg',
      'github': 'https://github.com/pratamadky',
    },
    {
      'name': 'Wafiq Ulil Abshor A',
      'nim': '24111814064',
      'photo': 'assets/wafiq.jpg',
      'github': 'https://github.com/wafiqulil2603',
    },
    {
      'name': 'Rayhan Wahyu Satrio W',
      'nim': '24111814046',
      'photo': 'assets/bowo.png',
      'github': 'https://github.com/RayhanWahyu9',
    },
  ];

  final String _groupGithub = 'https://github.com/BasisData07/AplikasiLesPrivat';
  final String _groupLogo = 'assets/panda.png';

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuka tautan')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat membuka tautan')),
      );
    }
  }

  Widget _initialsFallback(String name) {
    final List<String> parts = name.split(' ');
    String initials = '';
    if (parts.isNotEmpty) {
      initials = parts[0][0].toUpperCase();
    }
    if (parts.length > 1) {
      initials += parts[1][0].toUpperCase();
    }
    return Container(
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.orange,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark ? Colors.grey[900]! : const Color(0xFFF5FFFA);
    final Color card = isDark ? Colors.grey[800]! : Colors.white;
    const Color accent = Colors.orange;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Tentang Pencipta'),
        backgroundColor: accent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      _groupLogo,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.pets, size: 56, color: Colors.orange));
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Kelompok 8',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.link, size: 16, color: Colors.blueGrey),
                    const SizedBox(width: 6),
                    TextButton(
                      onPressed: () => _openUrl(context, _groupGithub),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        _groupGithub,
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                 const SizedBox(height: 6),
                 const Text(
                   'Tim pembuat aplikasi LES PRIVATE — 5 anggota',
                   textAlign: TextAlign.center,
                   style: TextStyle(color: Colors.black54),
                 ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          ..._members.map((m) {
            return Card(
              color: card,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey.shade200,
                  child: ClipOval(
                    child: (m['photo'] ?? '').toLowerCase().startsWith('http')
                        ? Image.network(
                            m['photo']!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => _initialsFallback(m['name']!),
                          )
                        : Image.asset(
                            m['photo']!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => _initialsFallback(m['name']!),
                          ),
                  ),
                ),
                title: Text(
                  m['name'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('NIM: ${m['nim']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.code),
                  tooltip: 'Buka GitHub',
                  onPressed: () => _openUrl(context, m['github']!),
                ),
              ),
            );
          }),

          const SizedBox(height: 14),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}