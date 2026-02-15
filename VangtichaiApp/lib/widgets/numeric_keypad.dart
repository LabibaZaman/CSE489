import 'package:flutter/material.dart';

// Suggested file: lib/widgets/numeric_keypad.dart
class NumericKeypad extends StatelessWidget {
  const NumericKeypad({super.key, required this.onKeyPressed});

  final ValueChanged<String> onKeyPressed;

  @override
  Widget build(BuildContext context) {
    // A 3x4 grid for the keypad layout.
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildKeypadRow(context, ['1', '2', '3']),
        _buildKeypadRow(context, ['4', '5', '6']),
        _buildKeypadRow(context, ['7', '8', '9']),
        _buildKeypadRow(context, ['C', '0', '']), // Placeholder for layout
      ],
    );
  }

  Widget _buildKeypadRow(BuildContext context, List<String> keys) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: keys.map((key) {
          if (key.isEmpty) {
            // Render an invisible placeholder to maintain the grid structure.
            return const Expanded(child: SizedBox());
          }
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0 / 2),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () => onKeyPressed(key),
                child: Text(
                  key,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
