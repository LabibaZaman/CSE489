import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/landmark_provider.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LandmarkProvider>(context);
    final visits = provider.visits;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity History'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: visits.isEmpty
          ? const Center(child: Text('No visits yet.'))
          : ListView.builder(
              itemCount: visits.length,
              itemBuilder: (ctx, i) {
                final v = visits[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(v.landmarkName),
                    subtitle: Text('Distance: ${v.distance.toStringAsFixed(2)} km'),
                    trailing: Text(
                      DateFormat.yMMMd().add_jm().format(v.visitTime),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
