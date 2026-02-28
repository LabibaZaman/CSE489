import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labassignment2/main.dart';

void main() {
  testWidgets('Drawer navigation test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the home screen is shown with the default text.
    expect(find.text('Select an option from the drawer'), findsOneWidget);

    // Open the drawer.
    await tester.dragFrom(const Offset(0, 300), const Offset(300, 300));
    await tester.pumpAndSettle();

    // Verify drawer items.
    expect(find.text('Menu Options'), findsOneWidget);
    expect(find.text('Broadcast Receiver'), findsOneWidget);
    expect(find.text('Image Scale'), findsOneWidget);
    expect(find.text('Video'), findsOneWidget);
    expect(find.text('Audio'), findsOneWidget);

    // Tap on 'Broadcast Receiver' and verify navigation.
    await tester.tap(find.text('Broadcast Receiver'));
    await tester.pumpAndSettle();

    expect(find.text('Select a broadcast type'), findsOneWidget);
    expect(find.text('Proceed'), findsOneWidget);
  });
}
