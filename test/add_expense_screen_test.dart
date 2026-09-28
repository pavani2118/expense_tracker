import 'package:expense_tracker/screens/add_edit_expense_screen.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows validation errors when required fields are empty', (
    tester,
  ) async {
    final firestore = FakeFirebaseFirestore();
    final service = ExpenseService(firestore: firestore);

    await tester.pumpWidget(
      MaterialApp(home: AddEditExpenseScreen(expenseService: service)),
    );

    await tester.tap(find.text('Save Expense'));
    await tester.pump();

    expect(find.text('Title is required'), findsOneWidget);
    expect(find.text('Enter a valid amount'), findsOneWidget);
  });

  testWidgets('saves a valid expense to Firestore', (tester) async {
    final firestore = FakeFirebaseFirestore();
    final service = ExpenseService(firestore: firestore);

    await tester.pumpWidget(
      MaterialApp(home: AddEditExpenseScreen(expenseService: service)),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Lunch',
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Amount'),
      '1250',
    );

    await tester.tap(find.text('Save Expense'));
    await tester.pumpAndSettle();

    final snapshot = await firestore.collection('expenses').get();

    expect(snapshot.docs.length, 1);
    expect(snapshot.docs.first.data()['title'], 'Lunch');
    expect(snapshot.docs.first.data()['amount'], 1250);
  });
}
