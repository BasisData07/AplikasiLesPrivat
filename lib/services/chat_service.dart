// lib/services/chat_service.dart

import 'dart:convert'; // DIBUTUHKAN untuk JSON decoding
import 'package:PRIVATE_AJA/services/api_service.dart';
import 'package:http/http.dart' as http; // DIBUTUHKAN untuk panggilan API
import 'package:PRIVATE_AJA/pages/model/chat_message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart'; // <--- BARU: Untuk firstWhereOrNull

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
      
      // Simpan Info Room agar bisa dicari di Inbox
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

   // 4. Mendapatkan Daftar Inbox / Peers (FINAL FIX)
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
               
               // MENCARI ID LAWAN SECARA AMAN (firstWhereOrNull)
               final peerId = users.firstWhereOrNull((id) => id != currentUserId); 
               
               // Kembalikan ID lawan atau string kosong jika tidak ditemukan
               return peerId?.toString() ?? '';
            })
            .where((id) => id.isNotEmpty) // Filter ID yang kosong (data rusak)
            .toList();
         });
   }

   // 5. 🔥 FUNGSI BARU: Mengambil Nama Pengguna dari MySQL (via API Backend) 🔥
   Future<String> getUserName(String userId) async {
      if (userId.isEmpty) return 'ID Kosong'; // Menangani ID yang difilter sebagai kosong

      try {
         // Memanggil endpoint API Node.js yang sudah Anda buat: /api/users/{userId}
         final fullUrl = '${ApiService.getBaseUrl}/users/$userId'; // <--- PERBAIKAN DI SINI
         print('API USER NAME: $fullUrl'); // Debugging

         final response = await http.get(
            Uri.parse(fullUrl),
         ); 

         if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            // Asumsi backend merespon dengan { "name": "Nama Pengguna" }
            return data['name'] ?? 'Nama Tidak Diketahui'; 
         } else if (response.statusCode == 404) {
            return 'ID $userId (Tidak Ditemukan)';
         } else {
            return 'Error API ${response.statusCode}';
         }
      } catch (e) {
         print("Error fetching user name for ID $userId: $e");
         return 'Gagal Koneksi Jaringan';
      }
   }
}