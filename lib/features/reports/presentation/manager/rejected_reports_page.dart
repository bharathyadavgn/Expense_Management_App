import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme.dart';
import '../../../../providers/report_provider.dart';
import '../../../../widgets/status_badge.dart';

class RejectedReportsPage extends ConsumerWidget {
  const RejectedReportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportState = ref.watch(reportProvider);

    return Scaffold(
      appBar: AppBar(backgroundColor:AppTheme.black,title: const Text("Rejected Reports")),
      body: reportState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load reports')),
        data: (reports) {
          final rejectedReports =
              reports.where((r) => r.status == 'Rejected').toList();

          if (rejectedReports.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(reportProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: rejectedReports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final report = rejectedReports[i];

                final date = report.submissionDate == null
                    ? '-'
                    : report.submissionDate!.split('T').first;

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/manager-reportview',
                        arguments: {'reportId': report.id},
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₹${report.totalAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const StatusBadge(status: 'Rejected'),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Rejected • Submitted on $date',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

 
// EMPTY STATE
 
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cancel_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No rejected reports',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Rejected reports will appear here',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
