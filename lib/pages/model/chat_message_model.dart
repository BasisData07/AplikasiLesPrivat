// lib/models/chat_message_model.dart

class ChatMessageModel {
  final String id; // ID unik pesan di Firestore
  final String senderId; // ID Pengirim (Guru ID atau Murid ID)
  final String receiverId; // ID Penerima
  final String content; // Isi pesan
  final DateTime timestamp;
  final bool isRead;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isRead,
  });

  // Factory constructor untuk membaca data dari Firestore Document
  factory ChatMessageModel.fromMap(String id, Map<String, dynamic> data) {
    return ChatMessageModel(
      id: id,
      senderId: data['sender_id'] ?? '',
      receiverId: data['receiver_id'] ?? '',
      content: data['content'] ?? '',
      // Firestore menyimpan timestamp sebagai Timestamp, kita konversi ke DateTime
      timestamp: (data['timestamp'] as dynamic)?.toDate() ?? DateTime.now(),
      isRead: data['is_read'] ?? false,
    );
  }

  // Konversi Model ke Map (untuk dikirim ke Firestore)
  Map<String, dynamic> toMap() {
    return {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'timestamp': timestamp,
      'is_read': isRead,
    };
  }
}