import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('addExpense saves expense to Firestore', () async {
    final firestore = FakeFirebaseFirestore();
    final service = ExpenseService(firestore: firestore);

    final expense = Expense(
      title: 'Lunch',
      amount: 1250,
      category: 'Food',
      date: DateTime(2026, 9, 28),
      note: 'Rice and curry',
    );

    await service.addExpense(expense);

    final snapshot = await firestore.collection('expenses').get();

    expect(snapshot.docs.length, 1);
    expect(snapshot.docs.first.data()['title'], 'Lunch');
    expect(snapshot.docs.first.data()['amount'], 1250);
    expect(snapshot.docs.first.data()['category'], 'Food');
  });

  test('getExpenses returns expenses ordered by date', () async {
    final firestore = FakeFirebaseFirestore();
    final service = ExpenseService(firestore: firestore);

    await service.addExpense(
      Expense(
        title: 'Older Expense',
        amount: 100,
        category: 'Food',
        date: DateTime(2026, 9, 20),
      ),
    );

    await service.addExpense(
      Expense(
        title: 'Newer Expense',
        amount: 200,
        category: 'Transport',
        date: DateTime(2026, 9, 28),
      ),
    );

    final expenses = await service.getExpenses().first;

    expect(expenses.length, 2);
    expect(expenses.first.title, 'Newer Expense');
    expect(expenses.last.title, 'Older Expense');
  });

  test('getMonthlyTotal returns total for selected month', () async {
    final firestore = FakeFirebaseFirestore();
    final service = ExpenseService(firestore: firestore);

    await service.addExpense(
      Expense(
        title: 'Lunch',
        amount: 1000,
        category: 'Food',
        date: DateTime(2026, 9, 10),
      ),
    );

    await service.addExpense(
      Expense(
        title: 'Bus',
        amount: 500,
        category: 'Transport',
        date: DateTime(2026, 9, 20),
      ),
    );

    await service.addExpense(
      Expense(
        title: 'Old Expense',
        amount: 3000,
        category: 'Shopping',
        date: DateTime(2026, 8, 15),
      ),
    );

    final total = await service.getMonthlyTotal(DateTime(2026, 9, 1));

    expect(total, 1500);
  });

  test('updateExpense updates an existing expense', () async {
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
          ).toMap(),
        );

    final updatedExpense = Expense(
      id: doc.id,
      title: 'Dinner',
      amount: 1800,
      category: 'Food',
      date: DateTime(2026, 9, 28),
    );

    await service.updateExpense(updatedExpense);

    final updatedDoc = await firestore.collection('expenses').doc(doc.id).get();

    expect(updatedDoc.data()?['title'], 'Dinner');
    expect(updatedDoc.data()?['amount'], 1800);
  });

  test('deleteExpense removes an expense', () async {
    final firestore = FakeFirebaseFirestore();
    final service = ExpenseService(firestore: firestore);

    final doc = await firestore
        .collection('expenses')
        .add(
          Expense(
            title: 'Bus',
            amount: 250,
            category: 'Transport',
            date: DateTime(2026, 9, 28),
          ).toMap(),
        );

    await service.deleteExpense(doc.id);

    final deletedDoc = await firestore.collection('expenses').doc(doc.id).get();

    expect(deletedDoc.exists, false);
  });
}
