// lib/pages/guru/chat_list_page.dart

import 'package:flutter/material.dart';
import 'package:PRIVATE_AJA/services/chat_service.dart';
import 'package:PRIVATE_AJA/pages/murid/chat_room_page.dart';

class ChatListPage extends StatefulWidget {
  final String currentUserId; // ID Guru (Format String Angka, misal "15")

  const ChatListPage({super.key, required this.currentUserId});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  // Instance service
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesan Masuk"),
        backgroundColor: Colors.orange, // Warna mint
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, 
      ),
      body: StreamBuilder<List<String>>(
        stream: _chatService.getPeers(widget.currentUserId), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    "Belum ada pesan masuk.",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          final List<String> peerIds = snapshot.data!;

          return ListView.builder(
            itemCount: peerIds.length,
            itemBuilder: (context, index) {
              final peerId = peerIds[index];
              
              // Gunakan FutureBuilder untuk mengambil nama Murid
              return FutureBuilder<String>(
                future: _chatService.getUserName(peerId), 
                builder: (context, nameSnapshot) {
                  // Tentukan nama yang akan ditampilkan
                  String displayedName = "Memuat nama...";
                  String finalPeerName = "Murid ID: $peerId"; 

                  if (nameSnapshot.hasData) {
                    displayedName = nameSnapshot.data!;
                    finalPeerName = nameSnapshot.data!;
                  } else if (nameSnapshot.hasError) {
                    displayedName = "Nama Gagal Dimuat ($peerId)";
                  } else if (nameSnapshot.connectionState == ConnectionState.done && !nameSnapshot.hasData) {
                    displayedName = "Murid ID: $peerId (Unknown)";
                  }
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF3CB371),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        displayedName, // Menampilkan nama yang sudah dimuat
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text("Ketuk untuk membalas pesan"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Buka Chat Room, kirim finalPeerName
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatRoomPage(
                              currentUserId: widget.currentUserId,
                              peerId: peerId,
                              peerName: finalPeerName, // Menggunakan nama yang sudah dimuat
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}