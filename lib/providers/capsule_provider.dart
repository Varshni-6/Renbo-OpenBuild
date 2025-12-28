import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/time_capsule.dart';

class CapsuleProvider with ChangeNotifier {
  List<TimeCapsule> _capsules = [];
  bool _isLoading = true;

  List<TimeCapsule> get capsules => [..._capsules];
  bool get isLoading => _isLoading;

  CapsuleProvider() {
    loadCapsules();
  }

  // Save a new capsule
  Future<void> addCapsule(TimeCapsule capsule) async {
    _capsules.add(capsule);
    notifyListeners();
    await _saveToDisk();
  }

  // Load capsules from local storage
  Future<void> loadCapsules() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('user_capsules')) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final extractedData =
          json.decode(prefs.getString('user_capsules')!) as List<dynamic>;
      _capsules =
          extractedData.map((item) => TimeCapsule.fromMap(item)).toList();
    } catch (error) {
      debugPrint("Error loading capsules: $error");
    }

    _isLoading = false;
    notifyListeners();
  }

  // Update a capsule (e.g., mark as opened)
  Future<void> markAsOpened(String id) async {
    final index = _capsules.indexWhere((c) => c.id == id);
    if (index >= 0) {
      _capsules[index].isOpened = true;
      notifyListeners();
      await _saveToDisk();
    }
  }

  // Private helper to persist data
  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _capsules.map((c) => c.toMap()).toList();
    await prefs.setString('user_capsules', json.encode(data));
  }
}
