import 'package:flutter/widgets.dart';
import '../core/database/db_helper.dart';

Future<void> seedSampleData() async {
  final db = await DBHelper.database;
  // Check if users already seeded (simple check)
  final users = await db.query('users');
  if (users.isNotEmpty) return;

  // Seed users
  await db.insert('users', {'name': 'Employee One', 'role': 'employee', 'manager_id': 2, 'email': 'emp1@company.com', 'phone': '9999999999'});
  await db.insert('users', {'name': 'Employee Two', 'role': 'employee', 'manager_id': 2, 'email': 'emp2@company.com', 'phone': '9999999998'});
  await db.insert('users', {'name': 'Manager One', 'role': 'manager', 'email': 'mgr1@company.com', 'phone': '8888888888'});
  await db.insert('users', {'name': 'Finance One', 'role': 'finance', 'email': 'fin1@company.com', 'phone': '7777777777'});

  // create sample expenses & reports
  final r1 = await db.insert('reports', {'title': 'Trip to Bangalore', 'purpose': 'Client visit', 'user_id': 1, 'total_amount': 4500.0, 'status': 'Submitted', 'submission_date': DateTime.now().toIso8601String()});
  await db.insert('expenses', {'report_id': r1, 'user_id': 1, 'amount': 2500.0, 'category': 'Travel', 'date': DateTime.now().toIso8601String(), 'merchant': 'Taxi', 'description': 'Airport to client'});
  await db.insert('expenses', {'report_id': r1, 'user_id': 1, 'amount': 2000.0, 'category': 'Food', 'date': DateTime.now().toIso8601String(), 'merchant': 'Restaurant', 'description': 'Lunch'});

  final r2 = await db.insert('reports', {'title': 'Office Supplies', 'purpose': 'Stationery', 'user_id': 2, 'total_amount': 1200.0, 'status': 'Pending Payment', 'submission_date': DateTime.now().subtract(Duration(days:3)).toIso8601String()});
  await db.insert('expenses', {'report_id': r2, 'user_id': 2, 'amount': 1200.0, 'category': 'Supplies', 'date': DateTime.now().toIso8601String(), 'merchant': 'Stationery shop', 'description': 'Pens and paper'});

  // Approved and Paid sample
  final r3 = await db.insert('reports', {'title': 'Hotel Stay', 'purpose': 'Client meeting', 'user_id': 1, 'total_amount': 5000.0, 'status': 'Paid', 'submission_date': DateTime.now().subtract(Duration(days:10)).toIso8601String()});
  await db.insert('expenses', {'report_id': r3, 'user_id': 1, 'amount': 5000.0, 'category': 'Hotel', 'date': DateTime.now().toIso8601String(), 'merchant': 'Hotel ABC', 'description': '2 nights'});
  await db.insert('payments', {'report_id': r3, 'finance_user_id': 4, 'transaction_id': 'TXN-MOCK-seed-1', 'amount': 5000.0, 'date': DateTime.now().subtract(Duration(days:5)).toIso8601String(), 'status':'Completed'});
}
