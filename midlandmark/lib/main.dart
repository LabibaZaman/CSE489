import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:midlandmark/providers/landmark_provider.dart';
import 'package:midlandmark/screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LandmarkProvider()),
      ],
      child: MaterialApp(
        title: 'Smart Geo-Tagged Landmarks',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.blue,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: MainScreen(),
      ),
    );
  }
}
