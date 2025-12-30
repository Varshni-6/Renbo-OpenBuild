import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class SettingsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Rule 1: Always use the specific path for private user data
  String get _appId => "renbo-app-id"; // Replace with your actual __app_id

  /// Saves the user's regional language preference to Firestore.
  Future<void> saveLanguagePreference(String language) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _db
          .collection('artifacts')
          .doc(_appId)
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('preferences')
          .set({
        'language': language,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error saving language: $e");
    }
  }

  /// Retrieves the user's language preference.
  Future<String> getLanguagePreference() async {
    final user = _auth.currentUser;
    if (user == null) return "English";

    try {
      final doc = await _db
          .collection('artifacts')
          .doc(_appId)
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('preferences')
          .get();

      if (doc.exists && doc.data() != null) {
        return doc.data()!['language'] ?? "English";
      }
    } catch (e) {
      debugPrint("Error fetching language: $e");
    }
    return "English";
  }
}