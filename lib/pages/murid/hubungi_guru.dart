
import 'package:PRIVATE_AJA/pages/model/guru_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';


import '../model/guru_model.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Guru? selectedGuru;

  @override
  void initState() {
    super.initState();
    final guruProvider = Provider.of<GuruProvider>(context, listen: false);
    guruProvider.fetchGuruList(); // ambil dari API
  }

  Future<void> openWhatsApp(String number) async {
    final String text = Uri.encodeComponent("Halo kak, saya ingin bertanya tentang les privat.");
    final String url = "https://wa.me/$number?text=$text";

    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw Exception("Tidak bisa membuka WhatsApp");
    }
  }

  @override
  Widget build(BuildContext context) {
    final guruProvider = Provider.of<GuruProvider>(context);
    final guruList = guruProvider.guruList;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hubungi Guru"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: guruProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // DROPDOWN GURU
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange, width: 1.5),
                    ),
                    child: DropdownButton<Guru>(
                      value: selectedGuru,
                      hint: const Text("Pilih Guru"),
                      isExpanded: true,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.orange),
                      items: guruList.map((guru) {
                        return DropdownMenuItem(
                          value: guru,
                          child: Text("${guru.nama} - ${guru.mapel}"),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedGuru = value;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // TOMBOL HUBUNGI WA
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: selectedGuru == null
                          ? null
                          : () => openWhatsApp(selectedGuru!.noTelepon),
                      icon: const Icon(FontAwesomeIcons.whatsapp),
                      label: const Text("Hubungi via WhatsApp"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
