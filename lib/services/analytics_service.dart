import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsService {
  static DateTime? _featureStartTime;

  static final List<String> allFeatures = [
    'Meditation',
    'Journaling',
    'Chat',
    'Game',
    'Gratitude',
    'Zen Space',
    'Mood Pulse',
    'Vault'
  ];

  // --- 1. SESSION TRACKING ---

  static void startFeatureSession() {
    _featureStartTime = DateTime.now();
  }

  /// Ends a session and records time locally for graphs and updates Firestore usage count
  static Future<void> endFeatureSession(String featureName) async {
    if (_featureStartTime == null) return;
    
    final now = DateTime.now();
    final int secondsSpent = now.difference(_featureStartTime!).inSeconds;
    final prefs = await SharedPreferences.getInstance();

    // Time-series keys for local fl_chart axes
    String hourKey = "${featureName}_H_${now.year}_${now.month}_${now.day}_${now.hour}";
    String dayKey = "${featureName}_D_${now.year}_${now.month}_${now.day}";
    String monthKey = "${featureName}_M_${now.year}_${now.month}";
    String totalKey = "time_$featureName";

    // Update Local Storage
    await _incrementLocal(prefs, hourKey, secondsSpent);
    await _incrementLocal(prefs, dayKey, secondsSpent);
    await _incrementLocal(prefs, monthKey, secondsSpent);
    await _incrementLocal(prefs, totalKey, secondsSpent);

    // Update Cloud Firestore (Increment usage count)
    await incrementFeatureUsage(featureName);

    _featureStartTime = null;
  }

  static Future<void> _incrementLocal(SharedPreferences prefs, String key, int val) async {
    await prefs.setInt(key, (prefs.getInt(key) ?? 0) + val);
  }

  // --- 2. GLOBAL CLOUD TRACKING ---

  /// Records that a feature was opened in Firestore
  static Future<void> incrementFeatureUsage(String featureName) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('usage_metrics')
        .doc(featureName);

    await docRef.set({
      'count': FieldValue.increment(1),
      'last_used': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // --- 3. DATA RETRIEVAL FOR UI ---

  static Future<Map<String, dynamic>> getFullAnalytics(String period) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    List<double> chartPoints = [];
    Map<String, int> featureBreakdown = {};

    // Logic for X-axis: mapping time periods to graph points (minutes)
    if (period == "Daily") {
      for (int i = 0; i < 24; i++) {
        double total = 0;
        for (var f in allFeatures) {
          total += (prefs.getInt("${f}_H_${now.year}_${now.month}_${now.day}_$i") ?? 0) / 60.0;
        }
        chartPoints.add(total);
      }
    } else if (period == "Weekly") {
      for (int i = 6; i >= 0; i--) {
        DateTime date = now.subtract(Duration(days: i));
        double total = 0;
        for (var f in allFeatures) {
          total += (prefs.getInt("${f}_D_${date.year}_${date.month}_${date.day}") ?? 0) / 60.0;
        }
        chartPoints.add(total);
      }
    } else if (period == "Monthly") {
      for (int i = 3; i >= 0; i--) {
        double weekTotal = 0;
        for (int d = 0; d < 7; d++) {
          DateTime date = now.subtract(Duration(days: (i * 7) + d));
          for (var f in allFeatures) {
            weekTotal += (prefs.getInt("${f}_D_${date.year}_${date.month}_${date.day}") ?? 0) / 60.0;
          }
        }
        chartPoints.add(weekTotal);
      }
    } else {
      // Overall / 6-Month View
      for (int i = 5; i >= 0; i--) {
        DateTime date = DateTime(now.year, now.month - i, 1);
        double total = 0;
        for (var f in allFeatures) {
          total += (prefs.getInt("${f}_M_${date.year}_${date.month}") ?? 0) / 60.0;
        }
        chartPoints.add(total);
      }
    }

    // Populate total time per feature for the breakdown chart
    for (var f in allFeatures) {
      featureBreakdown[f] = prefs.getInt("time_$f") ?? 0;
    }
    
    return {"chart": chartPoints, "breakdown": featureBreakdown};
  }
}