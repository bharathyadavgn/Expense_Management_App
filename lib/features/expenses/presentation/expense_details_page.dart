import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../widgets/app_scaffold.dart';
import '../../expenses/domain/entities/expense_entity.dart';

class ExpenseDetailsPage extends StatelessWidget {
  const ExpenseDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ExpenseEntity expense =
    ModalRoute.of(context)!.settings.arguments as ExpenseEntity;

    final formattedDate =
        DateTime.tryParse(expense.date)?.toLocal().toString().split(' ').first ??
            expense.date;

    return AppScaffold(
      title: 'Expense Details',
      body: ListView(
        children: [
           
          // AMOUNT SECTION
           
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '₹${expense.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(expense.category),
                    backgroundColor: AppTheme.surface,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

           
          // METADATA
           
          Card(
            child: Column(
              children: [
                _InfoRow(label: 'Date', value: formattedDate),
                _Divider(),
                _InfoRow(
                    label: 'Merchant',
                    value: expense.merchant ?? '—'),
                _Divider(),
                _InfoRow(
                    label: 'Description',
                    value: expense.description ?? '—'),
              ],
            ),
          ),
          const SizedBox(height: 16),

           
          // RECEIPT PREVIEW
           
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Receipt',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  if (expense.receiptPath == null)
                    const Text(
                      'No receipt uploaded',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    GestureDetector(
                      onTap: () => _showFullImage(
                          context, expense.receiptPath!),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(expense.receiptPath!),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

           
          /// ACTIONS
           
          // Row(
          //   children: [
          //     Expanded(
          //       child: OutlinedButton.icon(
          //         onPressed: () {
          //           // future: edit expense
          //         },
          //         icon: const Icon(Icons.edit),
          //         label: const Text('Edit'),
          //       ),
          //     ),
          //     const SizedBox(width: 12),
          //     Expanded(
          //       child: OutlinedButton.icon(
          //         onPressed: () {
          //           // future: delete expense
          //         },
          //         icon: const Icon(Icons.delete, color: Colors.red),
          //         label: const Text(
          //           'Delete',
          //           style: TextStyle(color: Colors.red),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: Image.file(File(path)),
        ),
      ),
    );
  }
}


 //REUSABLE INFO ROW
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: Colors.grey.shade300);
  }
}
