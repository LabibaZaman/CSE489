import 'package:flutter/material.dart';

// Suggested file: lib/widgets/change_table.dart
class ChangeTable extends StatelessWidget {
  const ChangeTable({
    super.key,
    required this.notes,
    required this.change,
  });

  final List<int> notes;
  final Map<int, int> change;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListView.separated(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final int note = notes[index];
          final int count = change[note] ?? 0;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('৳ $note', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('$count', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => const Divider(height: 1),
      ),
    );
  }
}
