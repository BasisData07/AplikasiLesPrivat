import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutMePage extends StatelessWidget {
  const AboutMePage({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.grey[900]! : const Color(0xFFF692B3);
    final cardColor = isDarkMode ? Colors.grey[850]! : const Color(0xFFFFD2E1);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final highlightColor = Colors.pink[700]!;
    final secondaryTextColor = textColor.withAlpha(178);

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text("Tentang Pencipta"),
            pinned: true,
            backgroundColor: highlightColor,
            foregroundColor: Colors.white,
            elevation: 2,
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: highlightColor, width: 5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(102),
                            blurRadius: 15,
                            spreadRadius: 5,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 75,
                        backgroundImage: AssetImage('assets/rahma.jpg'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "PRIMA MIFTAKHUL RAHMA",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Mahasiswi S1 Informatika, Universitas Negeri Surabaya",
                      style: TextStyle(
                        fontSize: 18,
                        color: secondaryTextColor,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    _buildInfoCard(
                      context,
                      cardColor,
                      textColor,
                      highlightColor,
                      title: "Latar Belakang & Aspirasi",
                      content:
                          "Saya adalah mahasiswi S1 Informatika yang bersemangat dalam dunia teknologi dan pengembangan aplikasi. Menempuh pendidikan di Universitas Negeri Surabaya telah membekali saya dengan fundamental yang kuat dalam ilmu komputer. Saya percaya bahwa teknologi memiliki potensi besar untuk membawa perubahan positif, dan saya berdedikasi untuk menciptakan solusi yang inovatif dan relevan.",
                    ),
                    const SizedBox(height: 24),
                    _buildInfoCard(
                      context,
                      cardColor,
                      textColor,
                      highlightColor,
                      title: "Tentang Aplikasi LES MANIA",
                      content:
                          "Aplikasi LES MANIA lahir dari sebuah visi untuk mempermudah akses pendidikan berkualitas di Indonesia. Tujuan utamanya adalah menjembatani orang tua yang mencari guru privat terbaik untuk anak-anak mereka, dengan guru-guru kompeten yang siap berbagi ilmu. LES MANIA menyediakan platform yang intuitif dan terpercaya, memungkinkan orang tua menemukan guru dengan spesialisasi yang sesuai, melihat profil lengkap, dan mengelola jadwal les dengan mudah. Harapan kami, aplikasi ini dapat berkontribusi dalam meningkatkan kualitas pendidikan dan memberikan pengalaman belajar yang lebih personal serta efektif bagi setiap siswa.",
                    ),
                    const SizedBox(height: 24),
                    _buildInfoCard(
                      context,
                      cardColor,
                      textColor,
                      highlightColor,
                      title: "Keahlian & Minat",
                      content: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildSkillChip("Flutter & Dart", highlightColor),
                          _buildSkillChip(
                            "Mobile UI/UX Design",
                            highlightColor,
                          ),
                          _buildSkillChip("Problem Solving", highlightColor),
                          _buildSkillChip(
                            "Software Development",
                            highlightColor,
                          ),
                          _buildSkillChip(
                            "Database Management",
                            highlightColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildInfoCard(
                      context,
                      cardColor,
                      textColor,
                      highlightColor,
                      title: "Hubungi Saya",
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSocialButton(
                            icon: Icons.email,
                            label: "Email",
                            onTap: () => _launchUrl(
                              'mailto:primamifta75@gmail.com',
                            ), // <-- PASTIKAN ADA 'mailto:'
                            color: highlightColor,
                            textColor: textColor,
                          ),
                          _buildSocialButton(
                            icon: FontAwesomeIcons.instagram,
                            label: "Instagram",
                            onTap: () => _launchUrl(
                              'https://www.instagram.com/rhma.taa?igsh=MWU2eTkzb2VqdnRxZw==',
                            ),
                            color: highlightColor,
                            textColor: textColor,
                          ),
                          _buildSocialButton(
                            icon: FontAwesomeIcons.linkedinIn,
                            label: "LinkedIn",
                            onTap: () => _launchUrl(
                              'https://www.linkedin.com/in/prima-rahma-745507381',
                            ),
                            color: highlightColor,
                            textColor: textColor,
                          ),
                          _buildSocialButton(
                            icon: FontAwesomeIcons.github,
                            label: "GitHub",
                            onTap: () =>
                                _launchUrl('https://github.com/PrimaRahma'),
                            color: highlightColor,
                            textColor: textColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    Color cardColor,
    Color textColor,
    Color highlightColor, {
    required String title,
    required dynamic content,
  }) {
    return Card(
      color: cardColor,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: highlightColor.withAlpha(102), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: highlightColor,
              ),
            ),
            const SizedBox(height: 12),
            if (content is String)
              Text(
                content,
                style: TextStyle(fontSize: 16, height: 1.6, color: textColor),
                textAlign: TextAlign.justify,
              )
            else if (content is Widget)
              content,
          ],
        ),
      ),
    );
  }

  Widget _buildSkillChip(String label, Color highlightColor) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: highlightColor.withAlpha(216),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      shadowColor: Colors.black.withAlpha(51),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    required Color textColor,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(35),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(76),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
