import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'dart:async';

class BatteryBroadcastScreen extends StatefulWidget {
  const BatteryBroadcastScreen({super.key});

  @override
  State<BatteryBroadcastScreen> createState() => _BatteryBroadcastScreenState();
}

class _BatteryBroadcastScreenState extends State<BatteryBroadcastScreen> {
  final Battery _battery = Battery();
  int _batteryLevel = 0;
  late StreamSubscription<BatteryState> _batteryStateSubscription;

  @override
  void initState() {
    super.initState();
    _getBatteryLevel();
    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((BatteryState state) {
      _getBatteryLevel();
    });
  }

  void _getBatteryLevel() async {
    final level = await _battery.batteryLevel;
    setState(() {
      _batteryLevel = level;
    });
  }

  @override
  void dispose() {
    _batteryStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Battery Broadcast')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.battery_full, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            Text(
              'Battery Level: $_batteryLevel%',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
