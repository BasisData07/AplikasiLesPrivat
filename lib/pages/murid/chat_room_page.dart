// lib/pages/murid/chat_room_page.dart

import 'package:PRIVATE_AJA/services/api_service.dart';
import 'package:PRIVATE_AJA/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago; // Pastikan package ini sudah diinstall

import '../model/chat_message_model.dart'; 

class ChatRoomPage extends StatefulWidget {
  final String currentUserId; // ID Murid/Guru (Harus ANGKA dalam format String, cth: "1")
  final String peerId;        // ID Lawan (Harus ANGKA dalam format String, cth: "15")
  final String peerName;      // Nama lawan chat

  const ChatRoomPage({
    super.key,
    required this.currentUserId,
    required this.peerId,
    required this.peerName,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // 1. FIX LOCALE ERROR: Daftarkan bahasa Indonesia
    timeago.setLocaleMessages('id', timeago.IdMessages());

    // 2. DEBUGGING: Cek apakah ID berhasil diterima atau masih null
    print("========================================");
    print("DEBUG CHAT ROOM");
    print("SAYA (Sender ID)  : ${widget.currentUserId}");
    print("LAWAN (Peer ID)   : ${widget.peerId}");
    print("========================================");
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- LOGIKA PENGIRIMAN PESAN (SUDAH DIPERBAIKI) ---
  void _sendMessage() async {
    // 1. Cek jika pesan kosong
    if (_messageController.text.trim().isEmpty) return;

    // 2. 🔥 FIX CRASH: Cek jika ID kosong atau "null"
    if (widget.currentUserId == null || widget.peerId == null || 
        widget.currentUserId == "null" || widget.peerId == "null" || 
        widget.currentUserId.isEmpty || widget.peerId.isEmpty) {
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('GAGAL: ID User tidak valid. Silakan Logout & Login ulang.'),
          ),
        );
        return; // Stop di sini, jangan lanjut
    }

    final content = _messageController.text.trim();
    _messageController.clear();

    final newMessage = ChatMessageModel(
        id: '', 
        senderId: widget.currentUserId,
        receiverId: widget.peerId,
        content: content,
        timestamp: DateTime.now(),
        isRead: false,
    );

    try {
        // 3. Kirim ke Firestore (Real-Time)
        // Backend Node.js Listener akan otomatis menyimpannya ke MySQL
        await _chatService.sendMessage(newMessage);
        
        _scrollToBottom();
    } catch (e) {
      print('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim pesan (Cek Internet).')),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // --- WIDGET CHAT BUBBLE ---
  Widget _buildMessageBubble(ChatMessageModel message) {
    final bool isCurrentUser = message.senderId == widget.currentUserId;
    final alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    
    // Warna tema aplikasi (mintHighlight)
    const sentColor = Colors.orange;
    final receivedColor = Colors.grey.shade300;
    final textColor = isCurrentUser ? Colors.white : Colors.black87;

    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isCurrentUser ? sentColor : receivedColor, 
              borderRadius: BorderRadius.circular(15).copyWith(
                bottomRight: isCurrentUser ? const Radius.circular(0) : const Radius.circular(15),
                bottomLeft: isCurrentUser ? const Radius.circular(15) : const Radius.circular(0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: TextStyle(color: textColor, fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  timeago.format(message.timestamp, locale: 'id'), // Sudah aman sekarang
                  style: TextStyle(
                    color: textColor.withOpacity(0.6), 
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (isCurrentUser && message.isRead) 
            const Padding(
              padding: EdgeInsets.only(top: 2, right: 2),
              child: Icon(Icons.done_all, size: 14, color: Colors.blue),
            ),
        ],
      ),
    );
  }

  // --- WIDGET DAFTAR PESAN ---
  Widget _buildMessageList() {
    return StreamBuilder<List<ChatMessageModel>>(
      stream: _chatService.getMessages(widget.currentUserId, widget.peerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Handle jika data kosong atau error
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 50, color: Colors.grey.shade400),
                const SizedBox(height: 10),
                Text(
                  "Mulai percakapan dengan ${widget.peerName}.", 
                  style: TextStyle(color: Colors.grey.shade600)
                ),
              ],
            ),
          );
        }

        // Tandai pesan sebagai dibaca
        _chatService.markMessagesAsRead(widget.currentUserId, widget.peerId);
        
        // Scroll ke bawah jika ada pesan baru
        _scrollToBottom();
        
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 80, top: 10),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final message = snapshot.data![index];
            return _buildMessageBubble(message);
          },
        );
      },
    );
  }

  // --- WIDGET INPUT PESAN ---
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 1,
            spreadRadius: 1,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: "Ketik pesan...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: const Color(0xFF3CB371), // Warna mint
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peerName),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          _buildMessageList(),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildMessageInput(),
          ),
        ],
      ),
    );
  }
}