import 'package:flutter/material.dart';

class InvoiceListScreen extends StatelessWidget {
  const InvoiceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt, size: 80, color: Colors.blue),
          const SizedBox(height: 20),
          const Text(
            'Billing & Invoicing',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text('Coming Soon...'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Billing module under development')),
              );
            },
            child: const Text('Generate Bill'),
          ),
        ],
      ),
    );
  }
}