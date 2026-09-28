import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/screens/history_screen.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> scrollToWidget(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    250,
    scrollable: find.byType(Scrollable).first,
    maxScrolls: 12,
  );

  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows empty state when there are no expenses', (tester) async {
    final firestore = FakeFirebaseFirestore();

    final service = ExpenseService(firestore: firestore);

    await tester.pumpWidget(
      MaterialApp(home: HistoryScreen(expenseService: service)),
    );

    await tester.pumpAndSettle();

    expect(find.text('No expenses yet'), findsOneWidget);
  });

  testWidgets('shows expenses from Firestore', (tester) async {
    final firestore = FakeFirebaseFirestore();

    final service = ExpenseService(firestore: firestore);

    await service.addExpense(
      Expense(
        title: 'Lunch',
        amount: 1250,
        category: 'Food',
        date: DateTime(2026, 9, 28),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: HistoryScreen(expenseService: service)),
    );

    await tester.pumpAndSettle();

    await scrollToWidget(tester, find.text('Lunch'));

    expect(find.text('Lunch'), findsOneWidget);

    expect(find.textContaining('Food'), findsOneWidget);

    expect(find.text('Rs. 1250.00'), findsOneWidget);
  });

  testWidgets('opens edit screen when an expense is tapped', (tester) async {
    final firestore = FakeFirebaseFirestore();

    final service = ExpenseService(firestore: firestore);

    await service.addExpense(
      Expense(
        title: 'Lunch',
        amount: 1250,
        category: 'Food',
        date: DateTime(2026, 9, 28),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: HistoryScreen(expenseService: service)),
    );

    await tester.pumpAndSettle();

    await scrollToWidget(tester, find.text('Lunch'));

    await tester.tap(find.text('Lunch'));

    await tester.pumpAndSettle();

    expect(find.text('Edit Expense'), findsOneWidget);
  });

  testWidgets('deletes an expense after confirmation', (tester) async {
    final firestore = FakeFirebaseFirestore();

    final service = ExpenseService(firestore: firestore);

    await service.addExpense(
      Expense(
        title: 'Bus',
        amount: 250,
        category: 'Transport',
        date: DateTime(2026, 9, 28),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: HistoryScreen(expenseService: service)),
    );

    await tester.pumpAndSettle();

    await scrollToWidget(tester, find.text('Bus'));

    expect(find.text('Bus'), findsOneWidget);

    final deleteButton = find.byIcon(Icons.delete_outline);

    await tester.ensureVisible(deleteButton);

    await tester.pumpAndSettle();

    await tester.tap(deleteButton);

    await tester.pumpAndSettle();

    expect(find.text('Delete Expense?'), findsOneWidget);

    await tester.tap(find.text('Delete'));

    await tester.pumpAndSettle();

    final snapshot = await firestore.collection('expenses').get();

    expect(snapshot.docs.length, 0);

    expect(find.text('Bus'), findsNothing);
  });

  testWidgets('filters expenses by category', (tester) async {
    final firestore = FakeFirebaseFirestore();

    final service = ExpenseService(firestore: firestore);

    await service.addExpense(
      Expense(
        title: 'Lunch',
        amount: 1200,
        category: 'Food',
        date: DateTime(2026, 9, 28),
      ),
    );

    await service.addExpense(
      Expense(
        title: 'Bus',
        amount: 250,
        category: 'Transport',
        date: DateTime(2026, 9, 28),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: HistoryScreen(expenseService: service)),
    );

    await tester.pumpAndSettle();

    await scrollToWidget(tester, find.text('Bus'));

    expect(find.text('Lunch'), findsOneWidget);

    expect(find.text('Bus'), findsOneWidget);

    await scrollToWidget(tester, find.byKey(const Key('category_filter')));

    await tester.tap(find.byKey(const Key('category_filter')));

    await tester.pumpAndSettle();

    await tester.tap(find.text('Food').last);

    await tester.pumpAndSettle();

    await scrollToWidget(tester, find.text('Lunch'));

    expect(find.text('Lunch'), findsOneWidget);

    expect(find.text('Bus'), findsNothing);
  });

  testWidgets('filters expenses by current month', (tester) async {
    final firestore = FakeFirebaseFirestore();

    final service = ExpenseService(firestore: firestore);

    final now = DateTime.now();

    final previousMonth = DateTime(now.year, now.month - 1, 10);

    await service.addExpense(
      Expense(
        title: 'This Month Expense',
        amount: 1000,
        category: 'Food',
        date: DateTime(now.year, now.month, 10),
      ),
    );

    await service.addExpense(
      Expense(
        title: 'Previous Month Expense',
        amount: 2000,
        category: 'Shopping',
        date: previousMonth,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: HistoryScreen(expenseService: service)),
    );

    await tester.pumpAndSettle();

    await scrollToWidget(tester, find.text('Previous Month Expense'));

    expect(find.text('This Month Expense'), findsOneWidget);

    expect(find.text('Previous Month Expense'), findsOneWidget);

    await scrollToWidget(tester, find.byKey(const Key('date_filter')));

    await tester.tap(find.byKey(const Key('date_filter')));

    await tester.pumpAndSettle();

    await tester.tap(find.text('This Month').last);

    await tester.pumpAndSettle();

    await scrollToWidget(tester, find.text('This Month Expense'));

    expect(find.text('This Month Expense'), findsOneWidget);

    expect(find.text('Previous Month Expense'), findsNothing);
  });

  testWidgets('filters expenses by today', (tester) async {
    final firestore = FakeFirebaseFirestore();

    final service = ExpenseService(firestore: firestore);

    final now = DateTime.now();

    final yesterday = now.subtract(const Duration(days: 1));

    await service.addExpense(
      Expense(
        title: 'Today Expense',
        amount: 500,
        category: 'Food',
        date: DateTime(now.year, now.month, now.day),
      ),
    );

    await service.addExpense(
      Expense(
        title: 'Yesterday Expense',
        amount: 700,
        category: 'Transport',
        date: DateTime(yesterday.year, yesterday.month, yesterday.day),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: HistoryScreen(expenseService: service)),
    );

    await tester.pumpAndSettle();

    await scrollToWidget(tester, find.byKey(const Key('date_filter')));

    await tester.tap(find.byKey(const Key('date_filter')));

    await tester.pumpAndSettle();

    await tester.tap(find.text('Today').last);

    await tester.pumpAndSettle();

    await scrollToWidget(tester, find.text('Today Expense'));

    expect(find.text('Today Expense'), findsOneWidget);

    expect(find.text('Yesterday Expense'), findsNothing);
  });

  testWidgets('filters expenses by selected date', (tester) async {
    final firestore = FakeFirebaseFirestore();

    final service = ExpenseService(firestore: firestore);

    final now = DateTime.now();

    await service.addExpense(
      Expense(
        title: 'Selected Date Expense',
        amount: 1000,
        category: 'Shopping',
        date: DateTime(now.year, now.month, 15),
      ),
    );

    await service.addExpense(
      Expense(
        title: 'Other Date Expense',
        amount: 2000,
        category: 'Bills',
        date: DateTime(now.year, now.month, 14),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: HistoryScreen(expenseService: service)),
    );

    await tester.pumpAndSettle();

    await scrollToWidget(tester, find.byKey(const Key('date_filter')));

    await tester.tap(find.byKey(const Key('date_filter')));

    await tester.pumpAndSettle();

    await tester.tap(find.text('Select Date').last);

    await tester.pumpAndSettle();

    await tester.tap(find.text('15').last);

    await tester.pumpAndSettle();

    await tester.tap(find.text('OK'));

    await tester.pumpAndSettle();

    await scrollToWidget(tester, find.text('Selected Date Expense'));

    expect(find.text('Selected Date Expense'), findsOneWidget);

    expect(find.text('Other Date Expense'), findsNothing);
  });

  testWidgets('shows professional history sections', (tester) async {
    final firestore = FakeFirebaseFirestore();

    final service = ExpenseService(firestore: firestore);

    await service.addExpense(
      Expense(
        title: 'Lunch',
        amount: 1200,
        category: 'Food',
        date: DateTime.now(),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: HistoryScreen(expenseService: service)),
    );

    await tester.pumpAndSettle();

    expect(find.text('All Expenses'), findsOneWidget);

    expect(find.text('Filter & Search'), findsOneWidget);

    expect(find.byKey(const Key('history_filter_card')), findsOneWidget);

    await scrollToWidget(tester, find.text('Lunch'));

    expect(find.text('Lunch'), findsOneWidget);
  });
}
