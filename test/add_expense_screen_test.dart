import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/screens/add_edit_expense_screen.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> tapFormButton(WidgetTester tester, String buttonText) async {
  final button = find.widgetWithText(FilledButton, buttonText);

  final scrollable = find.byType(Scrollable).first;

  await tester.scrollUntilVisible(
    button,
    250,
    scrollable: scrollable,
    maxScrolls: 10,
  );

  await tester.pumpAndSettle();

  // Move slightly further upward so the button is fully
  // inside the test viewport and safely tappable.
  await tester.drag(scrollable, const Offset(0, -80));

  await tester.pumpAndSettle();

  await tester.tap(button);

  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows validation errors when required fields are empty', (
    tester,
  ) async {
    final firestore = FakeFirebaseFirestore();

    final service = ExpenseService(firestore: firestore);

    await tester.pumpWidget(
      MaterialApp(home: AddEditExpenseScreen(expenseService: service)),
    );

    await tester.pumpAndSettle();

    await tapFormButton(tester, 'Save Expense');

    expect(find.text('Title is required'), findsOneWidget);

    expect(find.text('Enter a valid amount'), findsOneWidget);
  });

  testWidgets('saves valid expense to Firestore', (tester) async {
    final firestore = FakeFirebaseFirestore();

    final service = ExpenseService(firestore: firestore);

    await tester.pumpWidget(
      MaterialApp(home: AddEditExpenseScreen(expenseService: service)),
    );

    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Lunch',
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Amount'),
      '1250',
    );

    await tapFormButton(tester, 'Save Expense');

    final snapshot = await firestore.collection('expenses').get();

    expect(snapshot.docs.length, 1);

    final data = snapshot.docs.first.data();

    expect(data['title'], 'Lunch');

    expect(data['amount'], 1250);

    expect(data['category'], 'Other');
  });

  testWidgets('saves selected category and note to Firestore', (tester) async {
    final firestore = FakeFirebaseFirestore();

    final service = ExpenseService(firestore: firestore);

    await tester.pumpWidget(
      MaterialApp(home: AddEditExpenseScreen(expenseService: service)),
    );

    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Bus Trip',
    );

    await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '500');

    final categoryDropdown = find.byType(DropdownButtonFormField<String>);

    await tester.ensureVisible(categoryDropdown);

    await tester.pumpAndSettle();

    await tester.tap(categoryDropdown);

    await tester.pumpAndSettle();

    await tester.tap(find.text('Transport').last);

    await tester.pumpAndSettle();

    final noteField = find.widgetWithText(TextFormField, 'Note');

    await tester.scrollUntilVisible(
      noteField,
      200,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.pumpAndSettle();

    await tester.enterText(noteField, 'Trip to Colombo');

    await tapFormButton(tester, 'Save Expense');

    final snapshot = await firestore.collection('expenses').get();

    expect(snapshot.docs.length, 1);

    final data = snapshot.docs.first.data();

    expect(data['category'], 'Transport');

    expect(data['note'], 'Trip to Colombo');
  });

  testWidgets('shows date selector', (tester) async {
    final firestore = FakeFirebaseFirestore();

    final service = ExpenseService(firestore: firestore);

    await tester.pumpWidget(
      MaterialApp(home: AddEditExpenseScreen(expenseService: service)),
    );

    await tester.pumpAndSettle();

    final selectDate = find.text('Select Date');

    await tester.scrollUntilVisible(
      selectDate,
      200,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.pumpAndSettle();

    expect(selectDate, findsOneWidget);
  });

  testWidgets('closes screen after expense is saved successfully', (
    tester,
  ) async {
    final firestore = FakeFirebaseFirestore();

    final service = ExpenseService(firestore: firestore);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddEditExpenseScreen(expenseService: service),
                      ),
                    );
                  },
                  child: const Text('Open Form'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open Form'));

    await tester.pumpAndSettle();

    expect(find.text('Add Expense'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Dinner',
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Amount'),
      '1800',
    );

    await tapFormButton(tester, 'Save Expense');

    expect(find.text('Open Form'), findsOneWidget);

    final snapshot = await firestore.collection('expenses').get();

    expect(snapshot.docs.length, 1);

    expect(snapshot.docs.first.data()['title'], 'Dinner');

    expect(snapshot.docs.first.data()['amount'], 1800);
  });

  testWidgets('loads existing expense and updates it', (tester) async {
    final firestore = FakeFirebaseFirestore();

    final service = ExpenseService(firestore: firestore);

    final doc = await firestore
        .collection('expenses')
        .add(
          Expense(
            title: 'Lunch',
            amount: 1000,
            category: 'Food',
            date: DateTime(2026, 9, 28),
            note: 'Old note',
          ).toMap(),
        );

    final expense = Expense(
      id: doc.id,
      title: 'Lunch',
      amount: 1000,
      category: 'Food',
      date: DateTime(2026, 9, 28),
      note: 'Old note',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AddEditExpenseScreen(expenseService: service, expense: expense),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Edit Expense'), findsOneWidget);

    expect(find.text('Lunch'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Dinner',
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Amount'),
      '1800',
    );

    await tapFormButton(tester, 'Update Expense');

    final updatedDoc = await firestore.collection('expenses').doc(doc.id).get();

    expect(updatedDoc.exists, true);

    expect(updatedDoc.data()?['title'], 'Dinner');

    expect(updatedDoc.data()?['amount'], 1800);
  });

  testWidgets('shows professional expense form sections', (tester) async {
    final firestore = FakeFirebaseFirestore();

    final service = ExpenseService(firestore: firestore);

    await tester.pumpWidget(
      MaterialApp(home: AddEditExpenseScreen(expenseService: service)),
    );

    await tester.pumpAndSettle();

    expect(find.text('Expense Details'), findsOneWidget);

    expect(find.text('Additional Information'), findsOneWidget);

    expect(find.byKey(const Key('expense_form_card')), findsOneWidget);

    final saveButton = find.text('Save Expense');

    await tester.scrollUntilVisible(
      saveButton,
      250,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.pumpAndSettle();

    expect(saveButton, findsOneWidget);
  });
}
