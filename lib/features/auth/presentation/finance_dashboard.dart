import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/report_provider.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/card_row.dart';

class FinanceDashboard extends ConsumerStatefulWidget {
  const FinanceDashboard({Key? key}) : super(key: key);

  @override
  ConsumerState<FinanceDashboard> createState() =>
      _FinanceDashboardState();
}

class _FinanceDashboardState
    extends ConsumerState<FinanceDashboard> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(reportProvider.notifier).loadReportsForUser(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authProvider);
    final reportState = ref.watch(reportProvider);
    final userName = auth.user?.name ?? 'Finance';

    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Do you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        return shouldExit ?? false;
      },
      child: AppScaffold(
        title: 'Finance Dashboard',
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(reportProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 

                Text(
                  'Welcome, $userName 👋',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),

                 
                // SUMMARY CARDS
                 
                Row(
                  children: [
                    Expanded(
                      child: CardRow(
                        title: 'Pending Payments',
                        value: reportState.when(
                          data: (list) => list
                              .where((r) =>
                          r.status == 'Pending Payment')
                              .length
                              .toString(),
                          loading: () => '—',
                          error: (_, __) => '—',
                        ),
                        icon: Icons.pending_actions,
                        iconColor: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CardRow(
                        title: 'Paid Reports',
                        value: reportState.when(
                          data: (list) => list
                              .where((r) => r.status == 'Paid')
                              .length
                              .toString(),
                          loading: () => '—',
                          error: (_, __) => '—',
                        ),
                        icon: Icons.check_circle_outline,
                        iconColor: Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                 
                // ACTION LIST
                 
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFFF3E0),
                          child: Icon(
                            Icons.payments,
                            color: Colors.orange,
                          ),
                        ),
                        title: const Text(
                          'Process Payments',
                          style:
                          TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          'Approved reports awaiting payment',
                        ),
                        trailing:
                        const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/finance-reports',
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE8F5E9),
                          child: Icon(
                            Icons.receipt_long,
                            color: Colors.green,
                          ),
                        ),
                        title: const Text(
                          'Payment History',
                          style:
                          TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          'View completed payments',
                        ),
                        trailing:
                        const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/payment-history',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
