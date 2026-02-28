import 'package:flutter/material.dart';
import 'broadcast_screen.dart';
import 'image_scale_screen.dart';
import 'video_screen.dart';
import 'audio_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Widget _currentScreen = const Center(child: Text('Select an option from the drawer'));
  String _title = 'App';

  void _updateScreen(Widget screen, String title) {
    setState(() {
      _currentScreen = screen;
      _title = title;
    });
    Navigator.pop(context); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.lightGreen),
              child: Text('Menu Options', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              title: const Text('Broadcast Receiver'),
              onTap: () => _updateScreen(const BroadcastScreen(), 'Broadcast Receiver'),
            ),
            ListTile(
              title: const Text('Image Scale'),
              onTap: () => _updateScreen(const ImageScaleScreen(), 'Image Scale'),
            ),
            ListTile(
              title: const Text('Video'),
              onTap: () => _updateScreen(const VideoScreen(), 'Video'),
            ),
            ListTile(
              title: const Text('Audio'),
              onTap: () => _updateScreen(const AudioScreen(), 'Audio'),
            ),
          ],
        ),
      ),
      body: _currentScreen,
    );
  }
}
