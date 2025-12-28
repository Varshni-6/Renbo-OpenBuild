import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/gratitude.dart';

class GratitudeStorage {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<void> init() async {}

  // Helper to get the user's gratitude collection
  static CollectionReference<Map<String, dynamic>> _getCollection() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not authenticated");
    return _db.collection('users').doc(uid).collection('gratitude');
  }

  static Future<void> addGratitude(String content) async {
    await _getCollection().add({
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // UPDATE: This fixes the "Method not found" error in the widget
  static Future<void> updateGratitude(Gratitude gratitude) async {
    await _getCollection().doc(gratitude.id).update({
      'content': gratitude.content,
      'timestamp': gratitude.timestamp.toIso8601String(),
    });
  }

  // DELETE: This fixes the "Method not found" error in the widget
  static Future<void> deleteGratitude(String docId) async {
    await _getCollection().doc(docId).delete();
  }

  static Stream<List<Gratitude>> getGratitudeStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _getCollection()
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Gratitude.fromFirestore(doc.data(), doc.id))
            .toList());
  }
}
