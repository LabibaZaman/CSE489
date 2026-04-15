import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
// Keeping http import so your other files don't break if they reference it
import 'package:http/http.dart' as http;
import '../models/landmark.dart';

class ApiService {
  static const String baseUrl = 'http://51.79.145.118/cse489/exm3/api.php';
  static const String apiKey = '22201881';

  // 🚨 EMERGENCY MOCK DATABASE
  // Emulator network is actively blocking the university server (errno 111).
  // Using this static list to demonstrate all UI, Map, and SQLite features.
  static final List<Map<String, dynamic>> _mockDb = [
    {
      "id": 1,
      "title": "Cox's Bazar Sea Beach",
      "lat": 21.4272,
      "lon": 92.0058,
      "image": "https://labs.anontech.info/cse489/exm3/uploads/1775991089_5924.jpg",
      "is_active": 1,
      "visit_count": 17,
      "avg_distance": 4611626.49,
      "score": 85.0 // Green marker
    },
    {
      "id": 2,
      "title": "Sundarbans Mangrove Forest",
      "lat": 21.9497,
      "lon": 89.1833,
      "image": "https://labs.anontech.info/cse489/exm3/uploads/1775991089_9429.jpg",
      "is_active": 1,
      "visit_count": 10,
      "avg_distance": 6391829.96,
      "score": 50.0 // Orange marker
    },
    {
      "id": 4,
      "title": "Jaflong",
      "lat": 25.1644,
      "lon": 92.0175,
      "image": "https://labs.anontech.info/cse489/exm3/uploads/1775991089_3450.jpg",
      "is_active": 1,
      "visit_count": 5,
      "avg_distance": 6965275.77,
      "score": 20.0 // Red marker
    }
  ];

  Future<List<Landmark>> fetchLandmarks() async {
    // Return fake data instantly
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    return _mockDb.map((e) => Landmark.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> visitLandmark(String id, double lat, double lon) async {
    // Fake a successful visit
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      "status": "success",
      "distance": 12.5 // Dummy distance for the snackbar
    };
  }

  Future<bool> createLandmark(String title, double lat, double lon, File imageFile) async {
    // Add to fake database so it appears on your map
    _mockDb.add({
      "id": DateTime.now().millisecondsSinceEpoch,
      "title": title,
      "lat": lat,
      "lon": lon,
      "image": "https://via.placeholder.com/150", // Safe fallback image
      "is_active": 1,
      "visit_count": 0,
      "avg_distance": 0,
      "score": 75.0
    });
    return true;
  }

  Future<bool> deleteLandmark(String id) async {
    // Remove from fake database
    _mockDb.removeWhere((element) => element['id'].toString() == id);
    return true;
  }
}