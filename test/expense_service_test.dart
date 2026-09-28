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
}
