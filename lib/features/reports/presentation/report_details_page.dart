import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/expense_provider.dart';
import '../../../providers/report_provider.dart';
import '../../../widgets/status_badge.dart';

class ReportDetailsPage extends ConsumerStatefulWidget {
  const ReportDetailsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ReportDetailsPage> createState() => _ReportDetailsPageState();
}

class _ReportDetailsPageState extends ConsumerState<ReportDetailsPage> {
  bool _submitting = false;
  final _clarificationCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final auth = ref.read(authProvider);
      final userId = auth.user!.id;

      ref.read(expenseProvider.notifier)
          .loadExpensesForUser(userId);
    });
  }



  @override
  void dispose() {
    _clarificationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final report = ModalRoute.of(context)!.settings.arguments as dynamic;

    final auth = ref.read(authProvider);
    final actorId = auth.user!.id;

    final isDraft = report.status == 'Draft';
    final isRejected = report.status == 'Rejected';

    final expenseState = ref.watch(expenseProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.black,
        title: const Text("Report Details"),
      ),
      body: Column(
        children: [
          

          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
                if (report.purpose != null &&
                    report.purpose!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    report.purpose!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ₹${report.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    StatusBadge(status: report.status),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          
          // REJECTION COMMENT (IF ANY)
          
          if (isRejected)
            FutureBuilder<List<Map<String, Object?>>>(
              future:
                  ref.read(reportProvider.notifier).getStatusHistory(report.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                final history = snapshot.data!;
                final rejectedEntry = history.lastWhere(
                  (h) => h['status'] == 'Rejected',
                  orElse: () => {},
                );

                if (rejectedEntry.isEmpty) return const SizedBox();

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Manager Comment',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.red),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        rejectedEntry['comment']?.toString() ??
                            'No comment provided',
                      ),
                    ],
                  ),
                );
              },
            ),

          
          // EXPENSE LIST
          
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final auth = ref.read(authProvider);
                final userId = auth.user!.id;

                await ref
                    .read(expenseProvider.notifier)
                    .loadExpensesForUser(userId);
              },
              child: expenseState.when(
                loading: () =>
                const Center(child: CircularProgressIndicator()),
                error: (_, __) =>
                const Center(child: Text('Failed to load expenses')),
                data: (expenses) {
                  final reportId = report.id as int;

                  final reportExpenses = expenses.where((e) {
                    return e.reportId != null && e.reportId == reportId;
                  }).toList();

                  if (reportExpenses.isEmpty) {
                    return const Center(
                      child: Text('No expenses attached'),
                    );
                  }

                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: reportExpenses.length,
                    separatorBuilder: (_, __) =>
                    const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final e = reportExpenses[i];
                      return ListTile(
                        title: Text(
                          '₹${e.amount.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${e.category} • ${e.date.split('T').first}',
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          
          // CLARIFICATION + RESUBMIT
          
          if (isRejected)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _clarificationCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Clarification / Comment',
                      hintText: 'Explain the changes you made...',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting
                          ? null
                          : () async {
                              setState(() => _submitting = true);

                              await ref
                                  .read(reportProvider.notifier)
                                  .submitReport(
                                report.id,
                                actorId,
                                comment: _clarificationCtrl.text.trim().isEmpty
                                    ? null
                                    : _clarificationCtrl.text.trim(),
                              );


                              ref.invalidate(reportProvider);

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Report re-submitted successfully'),
                                ),
                              );

                              Navigator.pop(context);
                            },
                      child: const Text('Re-submit Report'),
                    ),
                  ),
                ],
              ),
            ),

          
          // SUBMIT BUTTON (DRAFT ONLY)
          
          if (isDraft)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting
                      ? null
                      : () async {
                          final confirmed = await _confirmSubmit(context);
                          if (!confirmed) return;

                          setState(() => _submitting = true);

                          await ref
                              .read(reportProvider.notifier)
                              .submitReport(report.id, actorId);

                          ref.invalidate(reportProvider);

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Report submitted successfully'),
                            ),
                          );

                          Navigator.pop(context);
                        },
                  child: const Text('Submit Report'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<bool> _confirmSubmit(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Submit Report'),
            content: const Text(
              'Once submitted, you will not be able to edit this report.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Submit'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
