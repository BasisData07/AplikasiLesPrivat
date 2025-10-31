// lib/pages/guru/chat_room_guru.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../chat_page.dart';
import '../model/user_model.dart';

class ChatRoomGuruPage extends StatefulWidget {
  final UserModel user;
  const ChatRoomGuruPage({super.key, required this.user});

  @override
  State<ChatRoomGuruPage> createState() => _ChatRoomGuruPageState();
}

class _ChatRoomGuruPageState extends State<ChatRoomGuruPage> {
  late Future<List<UserModel>> _muridListFuture;
  final String _apiUrl = 'http://10.0.2.2:3000/api'; // Sesuaikan dengan URL Anda

  @override
  void initState() {
    super.initState();
    _muridListFuture = _fetchMuridList();
  }

  Future<List<UserModel>> _fetchMuridList() async {
    try {
      // Panggil API yang baru dibuat di backend
      final response = await http.get(Uri.parse('$_apiUrl/chats/guru/${widget.user.username}'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        
        // Di sini kita hanya mengambil ID, di app nyata Anda akan mengambil nama juga
        // Untuk sekarang kita buat UserModel dummy dari data yang ada
        return data.map((chat) => UserModel(
          name: chat['senderId'], // Ganti ini dengan nama murid asli dari API
          username: chat['senderId'],
          email: '', password: '', role: 'murid'
        )).toList();

      } else {
        throw Exception('Gagal memuat daftar murid');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserModel>>(
      future: _muridListFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Belum ada murid yang menghubungi Anda.'));
        }

        final muridList = snapshot.data!;
        
        return ListView.builder(
          itemCount: muridList.length,
          itemBuilder: (context, index) {
            final murid = muridList[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.face_outlined)),
              title: Text(murid.name),
              subtitle: const Text('Klik untuk membalas pesan'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      currentUserId: widget.user.username,
                      peerId: murid.username,
                      peerName: murid.name,
                    ),
                  ),
                ).then((_) {
                  // Refresh daftar chat setelah kembali dari halaman chat
                  setState(() {
                    _muridListFuture = _fetchMuridList();
                  });
                });
              },
            );
          },
        );
      },
    );
  }
}