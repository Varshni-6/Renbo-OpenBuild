import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Needed for Timestamp
import 'package:firebase_auth/firebase_auth.dart';

part 'journal_entry.g.dart';

@HiveType(typeId: 0)
class JournalEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String content;

  @HiveField(2)
  DateTime timestamp;

  @HiveField(3)
  String? emotion;

  @HiveField(4)
  String? imagePath;

  @HiveField(5)
  String? audioPath;

  JournalEntry({
    String? id,
    required this.content,
    required this.timestamp,
    this.emotion,
    this.imagePath,
    this.audioPath,
  }) : id = id ?? const Uuid().v4();

  String get getId => id;

  // =========================
  // Firestore serialization
  // =========================
  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp), // ✅ Firestore-native
      'emotion': emotion,
      'imagePath': imagePath,
      'audioPath': audioPath,
      'userId': FirebaseAuth.instance.currentUser?.uid,
    };
  }

  // =========================
  // Firestore deserialization
  // =========================
  factory JournalEntry.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return JournalEntry(
      id: documentId,
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      emotion: data['emotion'],
      imagePath: data['imagePath'],
      audioPath: data['audioPath'],
    );
  }
}
