// lib/services/chat_service.dart

import 'package:PRIVATE_AJA/pages/model/chat_message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Mendapatkan ID Room yang konsisten (Urutan String: "1_15" atau "10_2")
  String getChatRoomId(String userId1, String userId2) {
    return userId1.compareTo(userId2) < 0 
        ? '${userId1}_$userId2' 
        : '${userId2}_$userId1';
  }

  // 1. Mengirim Pesan Baru (FIXED)
  Future<void> sendMessage(ChatMessageModel message) async {
    final roomId = getChatRoomId(message.senderId, message.receiverId);
    
    // 🔥 PERBAIKAN 1: Simpan Info Room agar bisa dicari di Inbox
    // Kita simpan daftar 'users' (penghuni) di dokumen room utama
    final roomRef = _db.collection('chat_rooms').doc(roomId);
    
    await roomRef.set({
      'users': [message.senderId, message.receiverId], // Array ini kuncinya!
      'last_message': message.content,
      'last_timestamp': message.timestamp,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // Merge biar data gak hilang

    // Simpan Pesan ke Sub-Collection
    await roomRef.collection('messages').add(message.toMap());
  }

  // 2. Mendapatkan Stream Pesan (Chat Room)
  Stream<List<ChatMessageModel>> getMessages(String userId1, String userId2) {
    final roomId = getChatRoomId(userId1, userId2);
    
    return _db
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // 3. Menandai Pesan Sudah Dibaca
  Future<void> markMessagesAsRead(String currentUserId, String peerId) async {
    final roomId = getChatRoomId(currentUserId, peerId);
    final batch = _db.batch();
    
    final messagesToUpdate = await _db
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .where('receiver_id', isEqualTo: currentUserId)
        .where('is_read', isEqualTo: false)
        .get();

    for (var doc in messagesToUpdate.docs) {
      batch.update(doc.reference, {'is_read': true});
    }

    await batch.commit();
  }

  // 4. Mendapatkan Daftar Inbox / Peers (FIXED)
  // Fungsi ini sekarang mencari berdasarkan array 'users', bukan nama dokumen
  Stream<List<String>> getPeers(String currentUserId) {
    return _db.collection('chat_rooms')
        // Cari room dimana 'users' mengandung ID saya
        .where('users', arrayContains: currentUserId) 
        .orderBy('last_timestamp', descending: true) // Urutkan dari pesan terbaru
        .snapshots()
        .map((snapshot) {
           return snapshot.docs.map((doc) {
              // Ambil array users dari database
              final List<dynamic> users = doc['users'];
              // Kembalikan ID yang BUKAN ID saya (itu berarti ID lawan)
              return users.firstWhere((id) => id != currentUserId).toString();
           }).toList();
        });
  }
}