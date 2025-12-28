import 'package:uuid/uuid.dart';

class Gratitude {
  String id;
  String content;
  DateTime timestamp;

  Gratitude({
    String? id,
    required this.content,
    required this.timestamp,
  }) : id = id ?? const Uuid().v4();

  // Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create from Firestore
  factory Gratitude.fromFirestore(Map<String, dynamic> data, String docId) {
    return Gratitude(
      id: docId,
      content: data['content'] ?? '',
      timestamp: data['timestamp'] != null
          ? DateTime.parse(data['timestamp'])
          : DateTime.now(),
    );
  }
}
