import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/expense_provider.dart';
import '../../../providers/report_provider.dart';
import '../../../widgets/app_scaffold.dart';

class EmployeeDashboard extends ConsumerStatefulWidget {
  const EmployeeDashboard({Key? key}) : super(key: key);

  @override
  ConsumerState<EmployeeDashboard> createState() =>
      _EmployeeDashboardState();
}
class _EmployeeDashboardState
    extends ConsumerState<EmployeeDashboard> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final auth = ref.read(authProvider);
      final userId = auth.user!.id;

      ref.read(expenseProvider.notifier)
          .loadExpensesForUser(userId);

      ref.read(reportProvider.notifier)
          .loadReportsForUser(userId);
    });
  }


  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authProvider);
    final userName = auth.user?.name ?? 'Employee';

    final expenseState = ref.watch(expenseProvider);
    final reportState = ref.watch(reportProvider);

    debugPrint("TOTAL EXPENSES");
    expenseState.whenData((list) {
      debugPrint('TOTAL EXPENSES: ${list.length}');
    });

    debugPrint("TOTAL REPORTS");
    reportState.whenData((list) {
      debugPrint('TOTAL REPORTS: ${list.length}');
    });

    Future<void> _refresh() async {
      final auth = ref.read(authProvider);
      final userId = auth.user!.id;

      await ref
          .read(expenseProvider.notifier)
          .loadExpensesForUser(userId);

      await ref
          .read(reportProvider.notifier)
          .loadReportsForUser(userId);
    }


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
        title: 'Employee Dashboard',
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

                
                // PRIMARY ACTIONS
                
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/create-expense'),
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text('New Expense'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/create-report'),
                          icon: const Icon(Icons.receipt_long,
                              color: Colors.white),
                          label: const Text('New Report'),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                
                // SUMMARY CARDS (STABLE LAYOUT)
                
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Total Expenses',
                        icon: Icons.payment,
                        color: Colors.blueAccent,
                        value: expenseState.when(
                          data: (list) => list.length.toString(),
                          loading: () => '—',
                          error: (_, __) => '—',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Total Reports',
                        icon: Icons.assignment,
                        color: Colors.blueAccent,
                        value: reportState.when(
                          data: (list) => list.length.toString(),
                          loading: () => '—',
                          error: (_, __) => '—',
                        ),
                      ),
                    ),
                  ],
                ),



                const SizedBox(height: 28),

                
                // NAVIGATION LIST
                
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFFFF3E0),
                          child: Icon(Icons.list_alt, color: AppTheme.primary),
                        ),
                        title: const Text(
                          'My Expenses',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text('View all your expenses'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            Navigator.pushNamed(context, '/my-expenses'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFFF3E0),
                          child: Icon(Icons.description, color: Colors.orange),
                        ),
                        title: const Text(
                          'My Reports',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text('Review & submit reports'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            Navigator.pushNamed(context, '/my-reports'),
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

 
// SUMMARY CARD (STABLE ACROSS DEVICES)
 
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Card(
        color: Color(0xFFFFF4E8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TITLE
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 20,
                      ),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
