import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/expense_provider.dart';
import '../../../widgets/app_scaffold.dart';

class ExpenseListPage extends ConsumerStatefulWidget {
  const ExpenseListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ExpenseListPage> createState() =>
      _ExpenseListPageState();
}
class _ExpenseListPageState extends ConsumerState<ExpenseListPage> {

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
  Widget build(BuildContext context) {
    final auth = ref.read(authProvider);
    final state = ref.watch(expenseProvider);
    final userId = auth.user?.id ?? 1;

    return AppScaffold(
      title: 'My Expenses',
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading expenses')),
        data: (list) {
          final expenses = list;

          if (expenses.isEmpty) {
            return _EmptyState(
              onCreate: () => Navigator.pushNamed(context, '/create-expense'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final auth = ref.read(authProvider);
              final userId = auth.user!.id;

              await ref
                  .read(expenseProvider.notifier)
                  .loadExpensesForUser(userId);
            },
            child: ListView.separated(
              itemCount: expenses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final ex = expenses[i];
                final date = DateTime.tryParse(ex.date)
                        ?.toLocal()
                        .toString()
                        .split(' ')
                        .first ??
                    ex.date;

                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    leading: _ReceiptThumb(
                      path: ex.receiptPath,
                    ),
                    title: Text(
                      ex.category,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('₹${ex.amount.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(
                          date,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/expense-details',
                        arguments: ex, // ExpenseEntity
                      );
                    },
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


// RECEIPT THUMBNAIL WIDGET

class _ReceiptThumb extends StatelessWidget {
  final String? path;

  const _ReceiptThumb({this.path});

  @override
  Widget build(BuildContext context) {
    if (path == null) {
      return const CircleAvatar(
        child: Icon(Icons.receipt_long),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(path!),
        width: 48,
        height: 48,
        fit: BoxFit.cover,
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
          Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No expenses yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first expense to get started',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Create Expense'),
          ),
        ],
      ),
    );
  }
}
