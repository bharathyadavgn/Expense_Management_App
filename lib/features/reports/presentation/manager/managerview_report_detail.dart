import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme.dart';
import '../../../../providers/report_provider.dart';
import '../../../../widgets/status_badge.dart';

class ManagerReportViewPage extends ConsumerStatefulWidget {
  const ManagerReportViewPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ManagerReportViewPage> createState() =>
      _ManagerReportViewPageState();
}

class _ManagerReportViewPageState
    extends ConsumerState<ManagerReportViewPage> {
  Map<String, Object?>? report;
  List<Map<String, Object?>> expenses = [];
  List<Map<String, Object?>> history = [];

  late int reportId;
  bool loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    reportId = args['reportId'] as int;
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);

    final notifier = ref.read(reportProvider.notifier);

    final r = await notifier.getReportById(reportId);
    final e = await notifier.getReportExpenses(reportId);
    final h = await notifier.getStatusHistory(reportId);

    if (!mounted) return;

    setState(() {
      report = r;
      expenses = e;
      history = h;
      loading = false;
    });
  }

  void _openImage(String path) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: Image.file(File(path)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading || report == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final status = report!['status'] as String;

    final commentHistory = history.where((h) {
      final comment = h['comment'];
      return comment != null && comment.toString().trim().isNotEmpty;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.black,
        title: const Text('Report Details'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            //  HEADER 
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    report!['title'] as String,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                StatusBadge(status: status),
              ],
            ),

            if (report!['purpose'] != null &&
                report!['purpose'].toString().trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  report!['purpose'] as String,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),

            const SizedBox(height: 16),

            //  SUMMARY 
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _summaryItem(
                      'Total Amount',
                      '₹${report!['total_amount']}',
                    ),
                    _summaryItem(
                      'Submitted On',
                      report!['submission_date']
                          .toString()
                          .split('T')
                          .first,
                    ),
                  ],
                ),
              ),
            ),

            //  COMMENTS 
            if (commentHistory.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Comments & Clarifications',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),

              ...commentHistory.map((h) {
                final status = h['status'] as String;
                final isManager = status == 'Rejected';

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isManager
                        ? Colors.red.shade50
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isManager
                          ? Colors.red.shade200
                          : Colors.blue.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isManager
                            ? 'Manager Comment'
                            : 'Employee Clarification',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color:
                          isManager ? Colors.red : Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(h['comment'].toString()),
                      const SizedBox(height: 6),
                      Text(
                        h['timestamp']
                            .toString()
                            .split('T')
                            .first,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            const SizedBox(height: 24),

            //  EXPENSES 
            const Text(
              'Expenses',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            if (expenses.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No expenses attached'),
                ),
              )
            else
              ...expenses.map(
                    (e) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: e['receipt_path'] != null
                        ? GestureDetector(
                      onTap: () =>
                          _openImage(e['receipt_path'] as String),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.file(
                          File(e['receipt_path'] as String),
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                        : const Icon(Icons.receipt_long),
                    title: Text(
                      '₹${(e['amount'] as num).toDouble().toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${e['category']} • ${e['date'].toString().split('T').first}',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
