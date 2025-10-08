import 'package:flutter/material.dart';

// Kelas data sederhana untuk menyimpan konten setiap bagian agar kode lebih rapi
class _TermsSection {
  final IconData icon;
  final String title;
  final String content;

  const _TermsSection({
    required this.icon,
    required this.title,
    required this.content,
  });
}

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  // Memisahkan data dari UI. Lebih mudah dikelola.
  final List<_TermsSection> _sections = const [
    _TermsSection(
      icon: Icons.gavel_rounded,
      title: "1. Penerimaan Persyaratan",
      content:
          "Dengan mengunduh, mengakses, atau menggunakan aplikasi LES MANIA (\"Aplikasi\"), Anda setuju untuk terikat oleh Syarat dan Ketentuan ini (\"Syarat\"). Jika Anda tidak menyetujui Syarat ini, Anda tidak diizinkan untuk menggunakan Aplikasi.",
    ),
    _TermsSection(
      icon: Icons.miscellaneous_services_rounded,
      title: "2. Deskripsi Layanan",
      content:
          "LES MANIA adalah platform yang menghubungkan calon siswa atau orang tua murid (\"Pengguna\") dengan penyedia jasa les privat (\"Guru\"). Peran kami adalah sebagai perantara untuk memfasilitasi pertemuan antara Pengguna dan Guru. Kami tidak mempekerjakan Guru secara langsung dan tidak bertanggung jawab atas metode pengajaran atau interaksi yang terjadi di luar platform.",
    ),
    _TermsSection(
      icon: Icons.rule_rounded,
      title: "3. Kewajiban Pengguna",
      content:
          "Anda setuju untuk:\n"
          "a. Memberikan informasi yang akurat, terkini, dan lengkap saat melakukan pendaftaran atau pencarian.\n"
          "b. Menjaga kerahasiaan informasi akun Anda.\n"
          "c. Berkomunikasi dengan Guru secara sopan dan profesional.\n"
          "d. Tidak menggunakan aplikasi untuk tujuan yang melanggar hukum, menipu, atau merugikan pihak lain.",
    ),
    _TermsSection(
      icon: Icons.payment_rounded,
      title: "4. Pembayaran Jasa Guru",
      content:
          "Semua transaksi pembayaran untuk jasa les privat dilakukan secara langsung antara Pengguna dan Guru berdasarkan kesepakatan kedua belah pihak. LES MANIA tidak terlibat dalam proses transaksi dan tidak bertanggung jawab atas perselisihan pembayaran apa pun.",
    ),
    _TermsSection(
      icon: Icons.security_rounded,
      title: "5. Pembatasan Tanggung Jawab",
      content:
          "LES MANIA menyediakan platform \"sebagaimana adanya\". Meskipun kami berupaya melakukan verifikasi dasar terhadap profil Guru, kami tidak menjamin kualitas, keamanan, atau legalitas jasa yang ditawarkan. Interaksi dan kesepakatan apa pun yang Anda buat dengan Guru adalah sepenuhnya menjadi risiko dan tanggung jawab Anda sendiri.",
    ),
    _TermsSection(
      icon: Icons.change_circle_rounded,
      title: "6. Perubahan Syarat",
      content:
          "Kami dapat mengubah Syarat ini dari waktu ke waktu. Jika ada perubahan, kami akan memberitahukannya melalui notifikasi di aplikasi atau cara lain yang wajar. Dengan terus menggunakan Aplikasi setelah perubahan, Anda dianggap menyetujui Syarat yang baru.",
    ),
    _TermsSection(
      icon: Icons.contact_mail_rounded,
      title: "7. Kontak Kami",
      content:
          "Jika Anda memiliki pertanyaan mengenai Syarat dan Ketentuan ini, silakan hubungi kami melalui email di: kontak@lesmania.com",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey[850] : Colors.white;
    final brandColor = Colors.pink[700];

    return Scaffold(
      // AppBar yang sudah disesuaikan dengan permintaan Anda
      appBar: AppBar(
        title: const Text("Syarat dan Ketentuan"),
        backgroundColor: brandColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // Menggunakan ListView.builder agar lebih efisien
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        itemCount: _sections.length + 1, // +1 untuk Header di bagian atas
        itemBuilder: (context, index) {
          // Item pertama (index 0) adalah Header
          if (index == 0) {
            return _buildHeader(context, isDarkMode, brandColor);
          }

          final section = _sections[index - 1];
          // Item selanjutnya adalah Card untuk setiap bagian S&K
          return _buildSectionCard(context, section, cardColor, brandColor);
        },
      ),
    );
  }

  // Widget khusus untuk membuat Header
  Widget _buildHeader(
    BuildContext context,
    bool isDarkMode,
    Color? brandColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.pink.withAlpha(26) : Colors.pink[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? Colors.pink.withAlpha(51)
              : Colors.pink.withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Syarat & Ketentuan Penggunaan Aplikasi LES MANIA",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: brandColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Terakhir diperbarui: 6 Oktober 2025",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Widget khusus untuk membuat Card di setiap bagian
  Widget _buildSectionCard(
    BuildContext context,
    _TermsSection section,
    Color? cardColor,
    Color? brandColor,
  ) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withAlpha(26),
      margin: const EdgeInsets.only(bottom: 16),
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(section.icon, color: brandColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    section.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 0.5),
            Text(
              section.content,
              textAlign: TextAlign.justify,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
