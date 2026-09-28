import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app opens Expense Tracker dashboard', (tester) async {
    final firestore = FakeFirebaseFirestore();
    final service = ExpenseService(firestore: firestore);

    await tester.pumpWidget(MyApp(expenseService: service));

    await tester.pumpAndSettle();

    expect(find.text('Expense Tracker'), findsOneWidget);
    expect(find.text('This Month'), findsOneWidget);
    expect(find.text('Recent Expenses'), findsOneWidget);
    expect(find.text('Add Expense'), findsOneWidget);
  });
}
