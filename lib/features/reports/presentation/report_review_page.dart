import 'dart:io';

import 'package:expense_management_app/core/database/db_helper.dart';
import 'package:expense_management_app/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/report_provider.dart';

class ReportReviewPage extends ConsumerWidget {
  const ReportReviewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final reportId = args?['reportId'] as int? ?? 0;

    return Scaffold(
      appBar: AppBar(backgroundColor:AppTheme.black, title: const Text('Report Review')),
      body: FutureBuilder(
        future: _loadReportData(ref, reportId),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done)
            return const Center(child: CircularProgressIndicator());
          final data = snapshot.data as Map<String, dynamic>;
          final report = data['report'];
          final expenses = data['expenses'] as List<Map<String, Object?>>;
          final total = data['total'] as double;
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report['title'] as String,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(report['purpose'] as String? ?? ''),
                const SizedBox(height: 12),
                Text('Expenses:',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (ctx, i) {
                      final e = expenses[i];
                      final amount = (e['amount'] as num).toDouble();
                      final category = e['category'] as String;
                      return ListTile(
                        leading: e['receipt_path'] != null
                            ? Image.file(File(e['receipt_path'] as String),
                                width: 56, height: 56, fit: BoxFit.cover)
                            : const Icon(Icons.receipt),
                        title:
                            Text("₹${amount.toStringAsFixed(2)} - $category"),
                        subtitle: Text(e['date'] as String? ?? ''),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Text('Total: ₹\$total',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final auth = ref.read(authProvider);
                          final actorId = auth.user?.id ?? 1;

                          await ref
                              .read(reportProvider.notifier)
                              .submitReport(reportId, actorId);

                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Report submitted')));

                          Navigator.popUntil(
                              context, ModalRoute.withName('/employee'));
                        },
                        child: const Text('Submit Report'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _loadReportData(
      WidgetRef ref, int reportId) async {
    final db = await DBHelper.database;
    final maps =
        await db.query('reports', where: 'id = ?', whereArgs: [reportId]);
    final report = maps.first;
    final expenses = await db
        .query('expenses', where: 'report_id = ?', whereArgs: [reportId]);
    final sums = await db.rawQuery(
        'SELECT SUM(amount) as total FROM expenses WHERE report_id = ?',
        [reportId]);
    final total = (sums.first['total'] as num?)?.toDouble() ?? 0.0;
    return {'report': report, 'expenses': expenses, 'total': total};
  }
}
