import 'package:flutter/material.dart';

void main() {
  runApp(VangtiChaiApp());
}

class VangtiChaiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VangtiChaiScreen(),
    );
  }
}

class VangtiChaiScreen extends StatefulWidget {
  @override
  _VangtiChaiScreenState createState() => _VangtiChaiScreenState();
}

class _VangtiChaiScreenState extends State<VangtiChaiScreen> {
  String amount = ""; // Stores user input amount
  Map<int, int> denominations = {
    500: 0,
    100: 0,
    50: 0,
    20: 0,
    10: 0,
    5: 0,
    2: 0,
    1: 0,
  };

  void _updateDenominations() {
    int value = int.tryParse(amount) ?? 0;
    Map<int, int> newDenominations = {
      500: 0,
      100: 0,
      50: 0,
      20: 0,
      10: 0,
      5: 0,
      2: 0,
      1: 0,
    };

    for (int key in newDenominations.keys) {
      newDenominations[key] = value ~/ key;
      value %= key;
    }

    setState(() {
      denominations = newDenominations;
    });
  }

  void _onNumberPressed(String number) {
    setState(() {
      if (amount.length < 10) {
        // Prevents overflow errors
        amount += number;
        _updateDenominations();
      }
    });
  }

  void _onClear() {
    setState(() {
      amount = "";
      denominations.updateAll((key, value) => 0);
    });
  }

  Widget _buildNumberList() {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Taka: $amount",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            ...denominations.entries.map((entry) {
              return Text(
                "${entry.key}: ${entry.value}",
                style: TextStyle(fontSize: 18),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad(double buttonSize) {
    return Expanded(
      flex: 3,
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var row in [
              ["1", "2", "3"],
              ["4", "5", "6"],
              ["7", "8", "9"],
              ["0", "CLEAR"],
            ])
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                row.map((key) {
                  return SizedBox(
                    width: buttonSize,
                    height: buttonSize * 0.8,
                    child: ElevatedButton(
                      onPressed: () {
                        if (key == "CLEAR") {
                          _onClear();
                        } else {
                          _onNumberPressed(key);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        key,
                        style: TextStyle(fontSize: buttonSize * 0.3),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonSize =
        screenWidth *
            (isLandscape ? 0.10 : 0.15); // Adjust button size based on orientation

    return Scaffold(
      appBar: AppBar(title: Text("VangtiChai")),
      body:
      isLandscape
          ? Row(
        // Landscape Mode: Number List on Left, Buttons on Right
        children: [_buildNumberList(), _buildNumberPad(buttonSize)],
      )
          : Column(
        // Portrait Mode: Default Layout
        children: [_buildNumberList(), _buildNumberPad(buttonSize)],
      ),
    );
  }
}
