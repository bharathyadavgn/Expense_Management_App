import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/report_provider.dart';
import '../../../../widgets/app_scaffold.dart';

class FinanceReportListPage extends ConsumerStatefulWidget {
  const FinanceReportListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<FinanceReportListPage> createState() =>
      _FinanceReportListPageState();
}

class _FinanceReportListPageState
    extends ConsumerState<FinanceReportListPage> {

  @override
  void initState() {
    super.initState();

    ///  Ensure latest data when page opens
    Future.microtask(() {
      ref.read(reportProvider.notifier).loadReportsForUser(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportProvider);

    return AppScaffold(
      title: 'Pending Payments',
      body: reportState.when(
        loading: () =>
        const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
        const Center(child: Text('Failed to load reports')),
        data: (reports) {
          final pending = reports
              .where((r) => r.status == 'Pending Payment')
              .toList();

          if (pending.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(reportProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: pending.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final r = pending[i];
                final submitted = r.submissionDate == null
                    ? '-'
                    : r.submissionDate!.split('T').first;

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
                        '/finance-payment',
                        arguments: {'reportId': r.id},
                      );

                      ///  Auto refresh after payment
                      if (refreshed == true) {
                        ref.invalidate(reportProvider);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₹${r.totalAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const _StatusPill(),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Submitted on $submitted',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tap to process payment',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary,
                            ),
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
  const _StatusPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Pending Payment',
        style: TextStyle(
          color: Colors.orange,
          fontSize: 12,
          fontWeight: FontWeight.w600,
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
            Icons.payments_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No pending payments',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'All approved reports are paid',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
