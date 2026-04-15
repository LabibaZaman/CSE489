import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/landmark.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class LandmarkProvider with ChangeNotifier {
  List<Landmark> _landmarks = [];
  List<Visit> _visits = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService();
  StreamSubscription? _connectivitySubscription;

  LandmarkProvider() {
    // Requirement 8: Auto-sync when internet is available
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
       _handleConnectivityChange(results);
    });
  }

  List<Landmark> get landmarks => _landmarks;
  List<Visit> get visits => _visits;
  bool get isLoading => _isLoading;

  List<Landmark> get activeLandmarks {
    // Requirement 7: Deleted landmarks should not appear
    return _landmarks.where((l) => !l.isDeleted).toList();
  }

  Future<void> _handleConnectivityChange(dynamic results) async {
    bool online = false;
    if (results is List) {
      // Check if any network in the list is NOT 'none'
      for (var r in results) {
        if (r != ConnectivityResult.none) {
          online = true;
          break;
        }
      }
    } else if (results is ConnectivityResult) {
      online = results != ConnectivityResult.none;
    }
    
    if (online) {
      debugPrint('Device online: Syncing pending visits...');
      await syncPendingVisits();
      await fetchAndSetLandmarks();
    }
  }

  Future<bool> _hasInternet() async {
    try {
      // Use dynamic to handle both List<ConnectivityResult> and ConnectivityResult
      final dynamic results = await Connectivity().checkConnectivity();
      if (results is List) {
        for (var r in results) {
          if (r != ConnectivityResult.none) return true;
        }
        return false;
      }
      return results != ConnectivityResult.none;
    } catch (e) {
      debugPrint('Connectivity check failed: $e');
      return false;
    }
  }

  Future<void> fetchAndSetLandmarks() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (await _hasInternet()) {
        final fetched = await _apiService.fetchLandmarks();
        if (fetched.isNotEmpty) {
          _landmarks = fetched;
          // Requirement 8: Cache fetched data locally
          await _dbService.insertLandmarks(_landmarks);
        } else {
          _landmarks = await _dbService.getLandmarks();
        }
      } else {
        // Requirement 8: Display data when offline
        _landmarks = await _dbService.getLandmarks();
      }
    } catch (error) {
      _landmarks = await _dbService.getLandmarks();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addLandmark(String title, double lat, double lon, File image) async {
    try {
      bool success = await _apiService.createLandmark(title, lat, lon, image);
      if (success) {
        await fetchAndSetLandmarks();
      } else {
        throw Exception('Failed to add landmark to server');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> visitLandmark(String landmarkId, double lat, double lon, String name) async {
    if (await _hasInternet()) {
      try {
        final result = await _apiService.visitLandmark(landmarkId, lat, lon);
        await fetchAndSetLandmarks();
        
        Visit visit = Visit(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          landmarkId: landmarkId,
          landmarkName: name,
          visitTime: DateTime.now(),
          distance: double.tryParse(result['distance'].toString()) ?? 0.0,
        );
        await _dbService.insertVisit(visit);
        await fetchAndSetVisits();
        return result;
      } catch (e) {
         return {'status': 'error', 'message': e.toString()};
      }
    } else {
      // Requirement 8: Queue visit requests when offline
      await _dbService.addPendingVisit(landmarkId, lat, lon);
      return {'status': 'queued', 'message': 'Offline. Visit queued for sync.'};
    }
  }

  Future<void> fetchAndSetVisits() async {
    _visits = await _dbService.getVisits();
    notifyListeners();
  }

  Future<void> syncPendingVisits() async {
    final pending = await _dbService.getPendingVisits();
    if (pending.isEmpty) return;

    if (await _hasInternet()) {
      for (var p in pending) {
        try {
          // Ensure landmark_id is treated as a string as expected by visitLandmark
          await _apiService.visitLandmark(
            p['landmark_id'].toString(), 
            p['user_lat'], 
            p['user_lon']
          );
          await _dbService.deletePendingVisit(p['id']);
        } catch (e) {
          debugPrint('Sync failed for item ${p['id']}: $e');
        }
      }
      await fetchAndSetLandmarks();
      await fetchAndSetVisits();
    }
  }

  Future<void> deleteLandmark(String id) async {
    try {
      bool success = await _apiService.deleteLandmark(id);
      if (success) {
        await fetchAndSetLandmarks();
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
