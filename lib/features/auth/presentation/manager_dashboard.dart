import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/report_provider.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/card_row.dart';

class ManagerDashboard extends ConsumerStatefulWidget {
  const ManagerDashboard({Key? key}) : super(key: key);

  @override
  ConsumerState<ManagerDashboard> createState() =>
      _ManagerDashboardState();
}

class _ManagerDashboardState
    extends ConsumerState<ManagerDashboard> {

  @override
  void initState() {
    super.initState();

    //  Load reports when manager enters dashboard
    Future.microtask(() {
      ref.read(reportProvider.notifier).loadReportsForUser(null);
    });
  }

  Future<void> _refresh() async {
    await ref.read(reportProvider.notifier).loadReportsForUser(null);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authProvider);
    final reportState = ref.watch(reportProvider);
    final userName = auth.user?.name ?? 'Manager';

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
        title: 'Manager Dashboard',
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // WELCOME
                
                Text(
                  'Welcome, $userName 👋',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),

                
                // SUMMARY CARDS
                
                SizedBox(
                  height: 120,
                  child: Row(
                    children: [
                      Expanded(
                        child: CardRow(
                          title: 'Pending Approvals',
                          value: reportState.when(
                            data: (list) => list
                                .where((r) => r.status == 'Submitted')
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
                          title: 'Approved (Sent to Finance)',
                          value: reportState.when(
                            data: (list) => list
                                .where((r) =>
                            r.status == 'Pending Payment' ||
                                r.status == 'Paid')
                                .length
                                .toString(),
                            loading: () => '—',
                            error: (_, __) => '—',
                          ),
                          icon: Icons.check_circle_outline,
                          iconColor: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CardRow(
                          title: 'Rejected Reports',
                          value: reportState.when(
                            data: (list) => list
                                .where((r) => r.status == 'Rejected')
                                .length
                                .toString(),
                            loading: () => '—',
                            error: (_, __) => '—',
                          ),
                          icon: Icons.cancel_outlined,
                          iconColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                
                // NAVIGATION
                
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFFF3E0),
                          child: Icon(Icons.pending_actions,
                              color: Colors.orange),
                        ),
                        title: const Text(
                          'Pending Approvals',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle:
                        const Text('Review and approve expense reports'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final refreshed = await Navigator.pushNamed(
                            context,
                            '/manager-reports',
                          );

                          if (refreshed == true) {
                            await _refresh();
                          }
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE8F5E9),
                          child: Icon(Icons.check_circle_outline,
                              color: Colors.green),
                        ),
                        title: const Text(
                          'Approved Reports',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle:
                        const Text('Reports sent to finance'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            Navigator.pushNamed(context, '/approved-reports'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFDECEA),
                          child: Icon(Icons.cancel_outlined,
                              color: Colors.red),
                        ),
                        title: const Text(
                          'Rejected Reports',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle:
                        const Text('Reports rejected with comments'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            Navigator.pushNamed(context, '/rejected-reports'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE3F2FD),
                          child:
                          Icon(Icons.bar_chart, color: Colors.blue),
                        ),
                        title: const Text(
                          'Team Analytics',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                            'View team spending overview'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            Navigator.pushNamed(context, '/manager-analytics'),
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
