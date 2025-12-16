import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/expense_provider.dart';
import '../../../providers/report_provider.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/primary_button.dart';

class AttachExpensesPage extends ConsumerStatefulWidget {
  const AttachExpensesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AttachExpensesPage> createState() => _AttachExpensesPageState();
}

class _AttachExpensesPageState extends ConsumerState<AttachExpensesPage> {
  final Set<int> _selectedExpenseIds = {};
  double _totalSelectedAmount = 0;

  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    
    // RECEIVE TEMP REPORT DATA
    
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final String title = args['title'];
    final String? purpose = args['purpose'];

    final auth = ref.read(authProvider);
    final userId = auth.user?.id ?? 1;

    final expenseState = ref.watch(expenseProvider);

    return AppScaffold(
      title: 'Attach Expenses',
      body: expenseState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Failed to load expenses')),
        data: (expenses) {
          final available = expenses
              .where((e) =>
                  e.userId == userId && (e.reportId == null || e.reportId == 0))
              .toList();

          if (available.isEmpty) {
            return _EmptyState(
              onCreate: () => Navigator.pushNamed(context, '/create-expense'),
            );
          }

          return Column(
            children: [
              
              // EXPENSE LIST
              
              Expanded(
                child: ListView.separated(
                  itemCount: available.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final ex = available[i];
                    final selected = _selectedExpenseIds.contains(ex.id);
                    final date = DateTime.tryParse(ex.date)
                        ?.toLocal()
                        .toString()
                        .split(' ')
                        .first ??
                        ex.date;

                    return CheckboxListTile(
                      value: selected,
                      onChanged: _processing
                          ? null
                          : (checked) {
                              setState(() {
                                if (checked == true) {
                                  _selectedExpenseIds.add(ex.id!);
                                  _totalSelectedAmount += ex.amount;
                                } else {
                                  _selectedExpenseIds.remove(ex.id);
                                  _totalSelectedAmount -= ex.amount;
                                }
                              });
                            },
                      title: Text(
                        '₹${ex.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${ex.category} • $date',
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  },
                ),
              ),

              
              // FOOTER SUMMARY + ACTION
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Selected Expenses',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '₹${_totalSelectedAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'Create Report & Attach',
                      loading: _processing,
                      onPressed: _selectedExpenseIds.isEmpty || _processing
                          ? null
                          : () async {
                        setState(() => _processing = true);

                        final reportId = await ref
                            .read(reportProvider.notifier)
                            .createReport(
                          title: title,
                          purpose: purpose,
                          userId: userId,
                        );

                        await ref
                            .read(reportProvider.notifier)
                            .attachExpensesToReport(
                          reportId,
                          _selectedExpenseIds.toList(),
                        );

                        await ref
                            .read(expenseProvider.notifier)
                            .loadExpensesForUser(userId);

                        await ref
                            .read(reportProvider.notifier)
                            .loadReportsForUser(userId);

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.grey.shade900,
                            content: Row(
                              children: const [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 20),
                                SizedBox(width: 12),
                                Text('Report created and expenses attached'),
                              ],
                            ),
                          ),
                        );

                        await Future.delayed(const Duration(milliseconds: 600));

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/my-reports',
                              (route) => route.isFirst,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

 
// EMPTY STATE
 
class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assignment_outlined,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No unassigned expenses available',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create expenses before submitting a report',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Create Expense'),
          ),
        ],
      ),
    );
  }
}
