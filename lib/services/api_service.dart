import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  final String baseUrl = "https://renbo-web-hosting-backend.onrender.com";

  // --- 1. Sentiment Analysis for Live Chat ---
  Future<Map<String, dynamic>> analyzeText(String text) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/analyze'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'text': text}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "status": "error",
          "sentiment_score": 0.0,
          "persona_advice":
              "The user seems stable. Engage in a friendly, helpful conversation.",
          "risk_level": "Low - Stable"
        };
      }
    } catch (e) {
      print("Flask Connection Error: $e");
      return {
        "status": "error",
        "sentiment_score": 0.0,
        "persona_advice":
            "The user seems stable. Engage in a friendly, helpful conversation.",
        "risk_level": "Low - Stable"
      };
    }
  }

  // --- 2. Talk to the Holistic Flask Route ---
  Future<Map<String, dynamic>> analyzeHolisticWellness(
      double avgSentiment, Map<String, int> stats) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/holistic_analysis'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'avg_sentiment': avgSentiment,
          'usage_stats': stats,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      print("Holistic API Error: $e");
      return {
        "status": "error",
        "feedback": "Could not connect to Renbo Brain.",
        "wellness_score": 50.0
      };
    }
  }

  // --- 3. Gather Data & Generate Report ---
  Future<Map<String, dynamic>> generateUserReport() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null)
      return {"status": "error", "message": "User not logged in"};
    final uid = user.uid;

    // 1. Get Chat Sentiment (Fetch last 5 messages from the most recent thread)
    double totalSentiment = 0;
    int messageCount = 0;

    final threads = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('saved_threads')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (threads.docs.isNotEmpty) {
      final messages = await threads.docs.first.reference
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();

      for (var doc in messages.docs) {
        // analyze user messages specifically to gauge internal state
        if (doc['sender'] == 'user') {
          final analysis = await analyzeText(doc['text'] ?? "");
          // Fallback to 0.0 if sentiment_score is missing
          totalSentiment += (analysis['sentiment_score'] ?? 0.0);
          messageCount++;
        }
      }
    }

    double avgSentiment =
        messageCount > 0 ? totalSentiment / messageCount : 0.0;

    // 2. Fetch Usage Metrics from Firestore
    final usageDocs = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('usage_metrics')
        .get();

    Map<String, int> stats = {};
    for (var doc in usageDocs.docs) {
      stats[doc.id] = doc['count'] ?? 0;
    }

    // 3. Send combined data to Flask for Holistic Insight
    return await analyzeHolisticWellness(avgSentiment, stats);
  }
}
