import 'package:flutter/material.dart';
import 'custom_broadcast_screen.dart';
import 'battery_broadcast_screen.dart';

class BroadcastScreen extends StatefulWidget {
  const BroadcastScreen({super.key});

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  String _selectedOption = 'Custom broadcast receiver';
  final List<String> _options = [
    'Custom broadcast receiver',
    'System battery notification receiver'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Select a broadcast type', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedOption,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedOption = newValue!;
                });
              },
              items: _options.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_selectedOption == 'Custom broadcast receiver') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CustomBroadcastInputScreen()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BatteryBroadcastScreen()),
                  );
                }
              },
              child: const Text('Proceed'),
            ),
          ],
        ),
      ),
    );
  }
}
