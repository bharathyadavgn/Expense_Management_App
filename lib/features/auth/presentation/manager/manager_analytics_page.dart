import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme.dart';
import '../../../../providers/report_provider.dart';

class ManagerAnalyticsPage extends ConsumerStatefulWidget {
  const ManagerAnalyticsPage({super.key});

  @override
  ConsumerState<ManagerAnalyticsPage> createState() =>
      _ManagerAnalyticsPageState();
}

class _ManagerAnalyticsPageState
    extends ConsumerState<ManagerAnalyticsPage> {
  bool loading = true;

  int totalReports = 0;
  int submitted = 0;
  int approved = 0;
  int rejected = 0;
  int pendingPayment = 0;

  Map<String, double> byCategory = {};
  Map<String, double> byEmployee = {};

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final notifier = ref.read(reportProvider.notifier);

    try {
      setState(() => loading = true);

      final reports = await notifier.rawAllReports();
      final expenses = await notifier.getAllExpenses();
      final userMap = await notifier.getUserMap();

       
      // REPORT COUNTS
       
      totalReports = reports.length;
      submitted =
          reports.where((r) => r['status'] == 'Submitted').length;
      rejected =
          reports.where((r) => r['status'] == 'Rejected').length;
      pendingPayment =
          reports.where((r) => r['status'] == 'Pending Payment').length;

      approved = reports.where((r) =>
      r['status'] == 'Pending Payment' ||
          r['status'] == 'Paid').length;

       
      // APPROVED REPORT IDS
       
      final approvedReportIds = reports
          .where((r) =>
      r['status'] == 'Pending Payment' ||
          r['status'] == 'Paid')
          .map((r) => r['id'] as int)
          .toSet();

       
      // SPENDING BY CATEGORY
       
      byCategory.clear();
      for (final e in expenses) {
        final reportId = e['report_id'] as int?;
        if (reportId == null || !approvedReportIds.contains(reportId)) {
          continue;
        }

        final category = (e['category'] ?? 'Other') as String;
        final amount = (e['amount'] as num).toDouble();

        byCategory[category] =
            (byCategory[category] ?? 0) + amount;
      }

       
      // SPENDING BY EMPLOYEE
       
      byEmployee.clear();
      for (final r in reports) {
        if (r['status'] != 'Pending Payment' &&
            r['status'] != 'Paid') continue;

        final userId = r['user_id'] as int;
        final name = userMap[userId] ?? 'Unknown';
        final amount = (r['total_amount'] as num).toDouble();

        byEmployee[name] =
            (byEmployee[name] ?? 0) + amount;
      }

      setState(() => loading = false);
    } catch (_) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.black,
        title: const Text('Manager Analytics'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadAnalytics,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               
              // SUMMARY
               
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _statCard('Total Reports',
                      totalReports.toString(), Colors.blue),
                  _statCard('Pending Approval',
                      submitted.toString(), Colors.orange),
                  _statCard('Approved',
                      approved.toString(), Colors.green),
                  _statCard('Rejected',
                      rejected.toString(), Colors.red),
                  _statCard('Pending Payment',
                      pendingPayment.toString(), Colors.purple),
                ],
              ),

              const SizedBox(height: 24),

               
              // CATEGORY BREAKDOWN
               
              const Text(
                'Spending by Category',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...byCategory.entries.map(
                    (e) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(e.key),
                  trailing: Text(
                    '₹${e.value.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 24),

               
              // EMPLOYEE BREAKDOWN
               
              const Text(
                'Spending by Employee',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...byEmployee.entries.map(
                    (e) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(e.key),
                  trailing: Text(
                    '₹${e.value.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return SizedBox(
      width: 160,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
