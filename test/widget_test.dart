import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/main.dart';

void main() {
  testWidgets('Expense Tracker screen displays correctly', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Expense Tracker'), findsOneWidget);
    expect(find.text('Firebase Connected!'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}
