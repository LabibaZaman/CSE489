import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/landmark_provider.dart';
import '../models/landmark.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(23.6850, 90.3563),
    zoom: 7,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LandmarkProvider>(context, listen: false).fetchAndSetLandmarks();
    });
  }

  Future<Position> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("GPS is OFF");
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception("Permission denied");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 10),
    );
  }

  Future<void> _visit(Landmark l) async {
    try {
      Position pos = await _getLocation();

      final provider =
      Provider.of<LandmarkProvider>(context, listen: false);

      final res = await provider.visitLandmark(
          l.id, pos.latitude, pos.longitude, l.title);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Distance: ${res['distance'] ?? '0'} km")),
      );
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Error"),
        content: Text(msg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LandmarkProvider>(context);
    final landmarks = provider.activeLandmarks;

    Set<Marker> markers = landmarks.map((l) {
      double hue = BitmapDescriptor.hueRed;

      if (l.score >= 40 && l.score < 70)
        hue = BitmapDescriptor.hueOrange;
      if (l.score >= 70)
        hue = BitmapDescriptor.hueGreen;

      return Marker(
        markerId: MarkerId(l.id),
        position: LatLng(l.lat, l.lon),
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        infoWindow: InfoWindow(
          title: l.title,
          onTap: () => _visit(l),
        ),
      );
    }).toSet();

    return Scaffold(
      appBar: AppBar(title: Text("Map")),
      body: GoogleMap(
        initialCameraPosition: _initialPosition,
        markers: markers,
        myLocationEnabled: true,
      ),
    );
  }
}