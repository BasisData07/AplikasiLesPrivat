// lib/pages/chat_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'model/message_model.dart'; // PERBAIKAN: Path import disederhanakan

class ChatPage extends StatefulWidget {
  final String currentUserId;
  final String peerId;
  final String peerName;

  const ChatPage({
    super.key,
    required this.currentUserId,
    required this.peerId,
    required this.peerName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

// PERBAIKAN: Menghapus duplikasi kata 'extends'
class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  late final WebSocketChannel _channel;
  final List<Message> _messages = [];
  bool _isLoadingHistory = true;

  // GANTI URL INI DENGAN URL BACKEND ANDA
  final String _apiUrl = 'http://10.0.2.2:3000/api';
  final String _wsUrl = 'ws://10.0.2.2:3000';

  @override
  void initState() {
    super.initState();
    _fetchMessageHistory();
    _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));

    _channel.stream.listen((data) {
      final decodedData = json.decode(data);
      if ((decodedData['senderId'] == widget.peerId && decodedData['receiverId'] == widget.currentUserId) ||
          (decodedData['senderId'] == widget.currentUserId && decodedData['receiverId'] == widget.peerId)) {
        
        // PERBAIKAN: Cek apakah widget masih ada sebelum update UI
        if (mounted) {
          setState(() {
            _messages.insert(0, Message.fromJson(decodedData));
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchMessageHistory() async {
    try {
      List<String> ids = [widget.currentUserId, widget.peerId];
      ids.sort();
      String chatRoomId = ids.join('_');
      final response = await http.get(Uri.parse('$_apiUrl/messages/$chatRoomId'));

      // PERBAIKAN: Cek apakah widget masih ada sebelum update UI
      if (mounted) {
        if (response.statusCode == 200) {
          final List<dynamic> history = json.decode(response.body);
          setState(() {
            _messages.addAll(history.map((msg) => Message.fromJson(msg)).toList().reversed);
            _isLoadingHistory = false;
          });
        } else {
          setState(() => _isLoadingHistory = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingHistory = false);
      }
    }
  }

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      final message = Message(
        senderId: widget.currentUserId,
        receiverId: widget.peerId,
        text: _controller.text,
        timestamp: DateTime.now(),
      );
      _channel.sink.add(json.encode(message.toJson()));
      setState(() {
        _messages.insert(0, message);
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peerName),
        // PERBAIKAN: Menyelaraskan warna dengan tema aplikasi
        backgroundColor: const Color(0xFF3CB371),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoadingHistory
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(child: Text("Mulai percakapan!"))
                    : ListView.builder(
                        reverse: true,
                        itemCount: _messages.length,
                        padding: const EdgeInsets.all(8.0),
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isCurrentUser = message.senderId == widget.currentUserId;
                          return _buildMessageBubble(isCurrentUser, message.text);
                        },
                      ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(bool isCurrentUser, String text) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          // PERBAIKAN: Menyelaraskan warna bubble chat
          color: isCurrentUser ? const Color(0xFF3CB371) : Colors.grey[600],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Ketik pesan...',
                filled: true,
                fillColor: Colors.grey.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
            style: IconButton.styleFrom(
              // PERBAIKAN: Menyelaraskan warna tombol kirim
              backgroundColor: const Color(0xFF3CB371),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}