import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/screens/dashboard_screen.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows monthly total and recent expenses', (tester) async {
    final firestore = FakeFirebaseFirestore();
    final service = ExpenseService(firestore: firestore);

    final now = DateTime.now();

    await service.addExpense(
      Expense(title: 'Lunch', amount: 1250, category: 'Food', date: now),
    );

    await tester.pumpWidget(
      MaterialApp(home: DashboardScreen(expenseService: service)),
    );

    await tester.pumpAndSettle();

    expect(find.text('Expense Tracker'), findsOneWidget);
    expect(find.text('This Month'), findsOneWidget);
    expect(find.text('Rs. 1250.00'), findsWidgets);
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Recent Expenses'), findsOneWidget);
  });

  testWidgets('changes monthly total when previous month is selected', (
    tester,
  ) async {
    final firestore = FakeFirebaseFirestore();
    final service = ExpenseService(firestore: firestore);

    final now = DateTime.now();
    final previousMonth = DateTime(now.year, now.month - 1, 10);

    await service.addExpense(
      Expense(
        title: 'Current Expense',
        amount: 1000,
        category: 'Food',
        date: DateTime(now.year, now.month, 10),
      ),
    );

    await service.addExpense(
      Expense(
        title: 'Previous Expense',
        amount: 2500,
        category: 'Shopping',
        date: previousMonth,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: DashboardScreen(expenseService: service)),
    );

    await tester.pumpAndSettle();

    expect(find.text('Rs. 1000.00'), findsWidgets);

    await tester.tap(find.byKey(const Key('previous_month')));

    await tester.pumpAndSettle();

    expect(find.text('Rs. 2500.00'), findsWidgets);
  });

  testWidgets('shows polished dashboard sections', (tester) async {
    final firestore = FakeFirebaseFirestore();
    final service = ExpenseService(firestore: firestore);

    await tester.pumpWidget(
      MaterialApp(home: DashboardScreen(expenseService: service)),
    );

    await tester.pumpAndSettle();

    expect(find.text('Overview'), findsOneWidget);

    expect(find.byKey(const Key('monthly_summary_card')), findsOneWidget);

    expect(find.text('Recent Expenses'), findsOneWidget);

    expect(find.text('Add Expense'), findsOneWidget);
  });
}
