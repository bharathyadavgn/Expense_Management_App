import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/auth_provider.dart';
import '../../../../providers/report_provider.dart';
import '../../../../widgets/app_scaffold.dart';

class FinancePaymentPage extends ConsumerStatefulWidget {
  const FinancePaymentPage({Key? key}) : super(key: key);

  @override
  ConsumerState<FinancePaymentPage> createState() => _FinancePaymentPageState();
}

class _FinancePaymentPageState extends ConsumerState<FinancePaymentPage> {
  Map<String, Object?>? report;
  List<Map<String, Object?>> expenses = [];
  bool processing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final reportId = args['reportId'] as int;

    _load(reportId);
  }

  Future<void> _load(int reportId) async {
    final notifier = ref.read(reportProvider.notifier);

    final r = await notifier.getReportById(reportId);
    final e = await notifier.getReportExpenses(reportId);

    if (!mounted) return;

    setState(() {
      report = r;
      expenses = e;
    });
  }

   
  // CONFIRM PAYMENT
   
  Future<bool?> _confirmPayment(double amount) {
    return showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Confirm Payment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                'You are about to process payment of ₹${amount.toStringAsFixed(2)}.',
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Confirm'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

   
  // PROCESS PAYMENT
   
  Future<void> _processPayment() async {
    if (report == null) return;

    final reportId = report!['id'] as int;
    final amount = (report!['total_amount'] as num).toDouble();

    final confirmed = await _confirmPayment(amount);
    if (confirmed != true) return;

    setState(() => processing = true);

    final financeId = ref.read(authProvider).user!.id;

    try {
      await ref
          .read(reportProvider.notifier)
          .processMockPayment(reportId, financeId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment processed successfully'),
        ),
      );

      Navigator.pop(context, true);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment failed')),
      );
    } finally {
      setState(() => processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (report == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final submittedDate =
        (report!['submission_date'] as String).split('T').first;

    return AppScaffold(
      title: 'Process Payment',
      body: Column(
        children: [
          
          // REPORT SUMMARY
          
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report!['title'] as String,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text('Submitted on $submittedDate'),
                  const SizedBox(height: 14),
                  Text(
                    '₹${(report!['total_amount'] as num).toDouble().toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Total Amount',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          
          // EXPENSE LIST
          
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: expenses.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
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
                    '₹${(e['amount'] as num).toDouble().toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(e['category'] as String),
                );
              },
            ),
          ),

          
          // ACTION BUTTON
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: processing ? null : _processPayment,
                child: processing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Process Payment'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
