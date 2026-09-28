import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/expense.dart';

class ExpenseService {
  final FirebaseFirestore _firestore;

  ExpenseService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addExpense(Expense expense) async {
    await _firestore.collection('expenses').add(expense.toMap());
  }

  Stream<List<Expense>> getExpenses() {
    return _firestore
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Expense.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }

  Future<double> getMonthlyTotal(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);

    final startOfNextMonth = DateTime(month.year, month.month + 1, 1);

    final snapshot = await _firestore
        .collection('expenses')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThan: Timestamp.fromDate(startOfNextMonth))
        .get();

    double total = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      total += (data['amount'] as num).toDouble();
    }

    return total;
  }

  Future<void> updateExpense(Expense expense) async {
    if (expense.id == null) {
      throw ArgumentError('Expense id is required for update');
    }

    await _firestore
        .collection('expenses')
        .doc(expense.id)
        .update(expense.toMap());
  }

  Future<void> deleteExpense(String id) async {
    await _firestore.collection('expenses').doc(id).delete();
  }
}
