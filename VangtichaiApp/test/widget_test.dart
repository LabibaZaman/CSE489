import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('VangtiChaiApp UI Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(VangtiChaiApp());

    // Verify initial state
    expect(find.text('Taka: '), findsOneWidget);

    // Tap number '1'
    await tester.tap(find.text('1'));
    await tester.pump();

    // Verify state after tapping '1'
    expect(find.text('Taka: 1'), findsOneWidget);

    // Tap number '5'
    await tester.tap(find.text('5'));
    await tester.pump();

    // Verify state after tapping '5'
    expect(find.text('Taka: 15'), findsOneWidget);
    expect(find.text('10: 1'), findsOneWidget);
    expect(find.text('5: 1'), findsOneWidget);


    // Tap CLEAR button
    await tester.tap(find.text('CLEAR'));
    await tester.pump();

    // Verify state after tapping 'CLEAR'
    expect(find.text('Taka: '), findsOneWidget);
  });
}
