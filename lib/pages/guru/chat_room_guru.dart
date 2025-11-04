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
  final String _apiUrl = 'http://10.0.2.2:5000/api'; // Sesuaikan port dengan backend Anda

  @override
  void initState() {
    super.initState();
    _muridListFuture = _fetchMuridList();
  }

  Future<List<UserModel>> _fetchMuridList() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/chats/guru/${widget.user.username}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          List<dynamic> data = responseData['data'];
          
          return data.map((murid) => UserModel(
            id: murid['id'] ?? 0,
            name: murid['name'] ?? 'Murid',
            username: murid['username'] ?? '',
            email: murid['email'] ?? '',
            role: murid['role'] ?? 'murid',
            subject: null,
          )).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Gagal memuat data');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  void _refreshChatList() {
    setState(() {
      _muridListFuture = _fetchMuridList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat dengan Murid'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshChatList,
          ),
        ],
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _muridListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Terjadi kesalahan',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshChatList,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada murid yang menghubungi Anda',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          final muridList = snapshot.data!;
          
          return ListView.builder(
            itemCount: muridList.length,
            itemBuilder: (context, index) {
              final murid = muridList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange[100],
                    child: Icon(Icons.person, color: Colors.orange[800]),
                  ),
                  title: Text(
                    murid.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Username: ${murid.username}'),
                  trailing: const Icon(Icons.chat_bubble_outline),
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
                      _refreshChatList();
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}