import 'dart:io';
import 'package:expense_management_app/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/report_provider.dart';
import '../../../../providers/auth_provider.dart';

class ManagerReportReviewPage extends ConsumerStatefulWidget {
  const ManagerReportReviewPage({super.key});

  @override
  ConsumerState<ManagerReportReviewPage> createState() =>
      _ManagerReportReviewPageState();
}

class _ManagerReportReviewPageState
    extends ConsumerState<ManagerReportReviewPage> {
  Map<String, Object?>? report;
  List<Map<String, Object?>> expenses = [];
  List<Map<String, Object?>> history = [];

  final _commentCtrl = TextEditingController();
  bool _processing = false;

  late int reportId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    reportId = args['reportId'] as int;
    _loadData();
  }

  Future<void> _loadData() async {
    final notifier = ref.read(reportProvider.notifier);

    final r = await notifier.getReportById(reportId);
    final e = await notifier.getReportExpenses(reportId);
    final h = await notifier.getStatusHistory(reportId);

    if (!mounted) return;

    setState(() {
      report = r;
      expenses = e;
      history = h;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (report == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final purpose = report!['purpose'] as String?;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(backgroundColor:AppTheme.black,title: const Text("Review Report")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             
            // HEADER
             
            Text(
              report!['title'] as String,
              style:
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (purpose != null && purpose.trim().isNotEmpty)
              Text(purpose, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Text('Total Amount: ₹${report!['total_amount']}'),
            Text(
              'Submitted: ${report!['submission_date'].toString().split('T').first}',
            ),

            const SizedBox(height: 16),

             
            // EXPENSES
             
            const Text('Expenses',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (ctx, i) {
                  final e = expenses[i];
                  return ListTile(
                      leading: e['receipt_path'] != null
                          ? GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              insetPadding: const EdgeInsets.all(16),
                              child: InteractiveViewer(
                                child: Image.file(
                                  File(e['receipt_path'] as String),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(
                            File(e['receipt_path'] as String),
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                      : const Icon(Icons.receipt_long),
                    title: Text(
                        '₹${e['amount']} - ${e['category']}'),
                    subtitle: Text(
                        e['date'].toString().split('T').first),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

             
            // STATUS HISTORY
            const Text(
              'Status History',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (ctx, i) {
                  final h = history[i];

                  final status = h['status'] as String;
                  final comment = h['comment']?.toString();
                  final date =
                      h['timestamp'].toString().split('T').first;

                  //  Determine who wrote the comment
                  final isManagerAction = status == 'Rejected' ||
                      status == 'Approved' ||
                      status == 'Pending Payment';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isManagerAction
                          ? Colors.red.shade50
                          : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isManagerAction
                            ? Colors.red.shade200
                            : Colors.blue.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isManagerAction
                                  ? 'Manager • $status'
                                  : 'Employee • $status',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isManagerAction
                                    ? Colors.red
                                    : Colors.blue,
                              ),
                            ),
                            Text(
                              date,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        // COMMENT
                        if (comment != null && comment.trim().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(comment),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),


            const SizedBox(height: 12),

             
            // COMMENT INPUT
             
            TextField(
              controller: _commentCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Manager Comment (required for rejection)',
              ),
            ),

            const SizedBox(height: 12),

             
            // ACTIONS
             
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _processing
                        ? null
                        : () async {
                      setState(() => _processing = true);

                      final managerId =
                          ref.read(authProvider).user!.id;

                      await ref
                          .read(reportProvider.notifier)
                          .approveReport(
                        reportId,
                        managerId,
                        comment: _commentCtrl.text
                            .trim()
                            .isEmpty
                            ? null
                            : _commentCtrl.text.trim(),
                      );

                      Navigator.pop(context, true);
                    },
                    child: const Text('Approve'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red),
                    onPressed: _processing
                        ? null
                        : () async {
                      if (_commentCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Comment required for rejection'),
                          ),
                        );
                        return;
                      }

                      setState(() => _processing = true);

                      final managerId =
                          ref.read(authProvider).user!.id;

                      await ref
                          .read(reportProvider.notifier)
                          .rejectReport(
                        reportId,
                        managerId,
                        _commentCtrl.text.trim(),
                      );

                      Navigator.pop(context, true);
                    },
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
