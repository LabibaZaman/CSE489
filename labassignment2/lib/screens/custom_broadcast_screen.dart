import 'package:flutter/material.dart';

class CustomBroadcastInputScreen extends StatefulWidget {
  const CustomBroadcastInputScreen({super.key});

  @override
  State<CustomBroadcastInputScreen> createState() => _CustomBroadcastInputScreenState();
}

class _CustomBroadcastInputScreenState extends State<CustomBroadcastInputScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Broadcast Input')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Enter text to broadcast'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomBroadcastReceiverScreen(message: _controller.text),
                  ),
                );
              },
              child: const Text('Send Broadcast'),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomBroadcastReceiverScreen extends StatelessWidget {
  final String message;
  const CustomBroadcastReceiverScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Broadcast Receiver')),
      body: Center(
        child: Text(
          'Received Message:\n$message',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
