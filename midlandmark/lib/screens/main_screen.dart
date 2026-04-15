import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/landmark_provider.dart';
import 'map_screen.dart';
import 'landmark_list_screen.dart';
import 'activity_screen.dart';
import 'add_landmark_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    MapScreen(),
    LandmarkListScreen(),
    ActivityScreen(),
    AddLandmarkScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<LandmarkProvider>(context, listen: false).fetchAndSetLandmarks();
      Provider.of<LandmarkProvider>(context, listen: false).fetchAndSetVisits();
      Provider.of<LandmarkProvider>(context, listen: false).syncPendingVisits();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Landmarks'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Activity'),
          BottomNavigationBarItem(icon: Icon(Icons.add_location), label: 'Add'),
        ],
      ),
    );
  }
}
