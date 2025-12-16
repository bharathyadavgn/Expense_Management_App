import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/report_provider.dart';
import '../../../../widgets/app_scaffold.dart';

class FinancePaymentHistoryPage extends ConsumerStatefulWidget {
  const FinancePaymentHistoryPage({super.key});

  @override
  ConsumerState<FinancePaymentHistoryPage> createState() =>
      _FinancePaymentHistoryPageState();
}

class _FinancePaymentHistoryPageState
    extends ConsumerState<FinancePaymentHistoryPage> {
  late Future<List<Map<String, Object?>>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = ref.read(reportProvider.notifier).getAllPayments();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Payment History',
      body: RefreshIndicator(
        onRefresh: () async {
          setState(_load);
          await _future;
        },
        child: FutureBuilder<List<Map<String, Object?>>>(
          future: _future,
          builder: (context, snapshot) {
            // ------------------
            // LOADING
            // ------------------
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // ------------------
            // ERROR
            // ------------------
            if (snapshot.hasError) {
              return const Center(
                child: Text('Failed to load payment history'),
              );
            }

            // ------------------
            // EMPTY
            // ------------------
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const _EmptyState();
            }

            final payments = snapshot.data!;

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: payments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final p = payments[i];

                final amount =
                (p['amount'] as num).toDouble().toStringAsFixed(0);
                final txnId = p['transaction_id'] as String;
                final date =
                    (p['date'] as String).split('T').first;

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // AMOUNT + STATUS
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₹$amount',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const _StatusPill(),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // META
                        Text(
                          'Transaction ID: $txnId',
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Paid on $date',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ------------------------------------------------
// STATUS PILL
// ------------------------------------------------
class _StatusPill extends StatelessWidget {
  const _StatusPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Paid',
        style: TextStyle(
          color: Colors.green,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ------------------------------------------------
// EMPTY STATE
// ------------------------------------------------
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No payments yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Processed payments will appear here',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
