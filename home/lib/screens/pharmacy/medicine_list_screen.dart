import 'package:flutter/material.dart';

class MedicineListScreen extends StatelessWidget {
  const MedicineListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.medication, size: 80, color: Colors.blue),
          const SizedBox(height: 20),
          const Text(
            'Pharmacy Management',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text('Coming Soon...'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pharmacy module under development')),
              );
            },
            child: const Text('Add Medicine'),
          ),
        ],
      ),
    );
  }
}