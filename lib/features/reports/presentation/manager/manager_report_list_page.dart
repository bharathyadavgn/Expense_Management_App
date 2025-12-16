import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme.dart';
import '../../../../providers/report_provider.dart';

class ManagerReportListPage extends ConsumerStatefulWidget {
  const ManagerReportListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ManagerReportListPage> createState() =>
      _ManagerReportListPageState();
}

class _ManagerReportListPageState
    extends ConsumerState<ManagerReportListPage> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(reportProvider.notifier).loadReportsForUser(null);
    });
  }

  Future<void> _refresh() async {
    await ref.read(reportProvider.notifier).loadReportsForUser(null);
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportProvider);

    return Scaffold(
      appBar: AppBar(backgroundColor:AppTheme.black,title: const Text("Pending Approvals")),
      body: reportState.when(
        loading: () =>
        const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
        const Center(child: Text('Failed to load reports')),
        data: (reports) {
          final pendingReports =
          reports.where((r) => r.status == 'Submitted').toList();

          if (pendingReports.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: pendingReports.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final report = pendingReports[i];

                final date = report.submissionDate == null
                    ? '-'
                    : report.submissionDate!.split('T').first;

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final refreshed =
                      await Navigator.pushNamed(
                        context,
                        '/manager-review',
                        arguments: {'reportId': report.id},
                      );

                      // refresh ONLY if review page says so
                      if (refreshed == true) {
                        await _refresh();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
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
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₹${report.totalAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const _StatusPill(
                                label: 'Pending Approval',
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Submitted on $date',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall,
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

 
// STATUS PILL
 
class _StatusPill extends StatelessWidget {
  final String label;

  const _StatusPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.orange.shade800,
        ),
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
            Icons.pending_actions,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No pending approvals',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Submitted reports will appear here',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
