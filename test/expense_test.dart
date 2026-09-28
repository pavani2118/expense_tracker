import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/expense.dart';

void main() {
  test('Expense converts to map correctly', () {
    final expense = Expense(
      id: '1',
      title: 'Lunch',
      amount: 1250.00,
      category: 'Food',
      date: DateTime(2026, 9, 28),
      note: 'Rice and curry',
    );

    final map = expense.toMap();

    expect(map['title'], 'Lunch');
    expect(map['amount'], 1250.00);
    expect(map['category'], 'Food');
    expect(map['note'], 'Rice and curry');
  });
}
