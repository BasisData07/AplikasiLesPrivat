// lib/message_model.dart

class Message {
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
  });

  // Factory constructor untuk membuat Message dari JSON
  // Ini akan digunakan saat menerima data dari API atau WebSocket
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      text: json['text'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  // Method untuk mengubah Message menjadi JSON
  // Ini akan digunakan saat mengirim data ke WebSocket
  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}