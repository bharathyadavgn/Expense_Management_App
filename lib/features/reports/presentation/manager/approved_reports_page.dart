import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme.dart';
import '../../../../providers/report_provider.dart';
import '../../../../widgets/status_badge.dart';

class ApprovedReportsPage extends ConsumerWidget {
  const ApprovedReportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportState = ref.watch(reportProvider);

    return Scaffold(
      appBar: AppBar(
          backgroundColor: AppTheme.black,
          title: const Text('Approved Reports')),
      body: reportState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load reports')),
        data: (reports) {
          final approvedReports = reports.where((r) =>
          r.status == 'Pending Payment' || r.status == 'Paid'
          ).toList();


          if (approvedReports.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(reportProvider.notifier).loadReportsForUser(null);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: approvedReports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final report = approvedReports[i];

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
                              StatusBadge(status: report.status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            report.status == 'Paid'
                                ? 'Paid • Payment completed'
                                : 'Approved • Awaiting payment',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            'Submitted on $date',
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
            Icons.check_circle_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No approved reports',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Approved reports will appear here',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
