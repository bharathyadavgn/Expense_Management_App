import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/report_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/app_scaffold.dart';

class ReportListPage extends ConsumerStatefulWidget {
  const ReportListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ReportListPage> createState() => _ReportListPageState();
}

class _ReportListPageState extends ConsumerState<ReportListPage> {
  // ---------------- FILTER STATE ----------------
  String _searchQuery = '';
  String? _statusFilter;
  double? _minAmount;
  double? _maxAmount;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authProvider);
    final state = ref.watch(reportProvider);
    final userId = auth.user?.id ?? 1;

    return AppScaffold(
      title: 'My Reports',
      body: Column(
        children: [
          // ---------------- SEARCH BAR ----------------
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search reports...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _openFilterSheet,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
            ),
          ),

          // ---------------- LIST ----------------
          Expanded(
            child: state.when(
              loading: () =>
              const Center(child: CircularProgressIndicator()),
              error: (_, __) =>
              const Center(child: Text('Error loading reports')),
              data: (reports) {
                final myReports = reports.where((r) {
                  if (r.userId != userId || r.totalAmount <= 0) return false;

                  // Search
                  if (_searchQuery.isNotEmpty &&
                      !r.title
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase())) {
                    return false;
                  }

                  // Status
                  if (_statusFilter != null && r.status != _statusFilter) {
                    return false;
                  }

                  // Amount
                  if (_minAmount != null &&
                      r.totalAmount < _minAmount!) return false;
                  if (_maxAmount != null &&
                      r.totalAmount > _maxAmount!) return false;

                  // Date
                  if (r.submissionDate != null) {
                    final date = DateTime.parse(r.submissionDate!);
                    if (_fromDate != null &&
                        date.isBefore(_fromDate!)) return false;
                    if (_toDate != null &&
                        date.isAfter(_toDate!)) return false;
                  }

                  return true;
                }).toList();

                if (myReports.isEmpty) {
                  return _EmptyState(
                    onCreate: () =>
                        Navigator.pushNamed(context, '/create-report'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: myReports.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final report = myReports[i];

                    return InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/report-details',
                          arguments: report,
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // MAIN CARD
                          Card(
                            elevation: 1.5,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(14),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    report.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '₹${report.totalAmount.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _helperText(report),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // STATUS STRIP
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: _statusColor(report.status)
                                  .withOpacity(0.12),
                              borderRadius:
                              const BorderRadius.vertical(
                                bottom: Radius.circular(14),
                              ),
                            ),
                            child: Text(
                              'Status: ${_statusLabel(report.status)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _statusColor(report.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- FILTER SHEET ----------------
  void _openFilterSheet() {
    final minCtrl =
    TextEditingController(text: _minAmount?.toString());
    final maxCtrl =
    TextEditingController(text: _maxAmount?.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filter Reports',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _statusFilter,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'Draft', child: Text('Draft')),
                  DropdownMenuItem(
                      value: 'Submitted', child: Text('Submitted')),
                  DropdownMenuItem(
                      value: 'Rejected', child: Text('Rejected')),
                  DropdownMenuItem(
                      value: 'Pending Payment',
                      child: Text('Pending Payment')),
                  DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                ],
                onChanged: (v) => setState(() => _statusFilter = v),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minCtrl,
                      keyboardType: TextInputType.number,
                      decoration:
                      const InputDecoration(labelText: 'Min Amount'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: maxCtrl,
                      keyboardType: TextInputType.number,
                      decoration:
                      const InputDecoration(labelText: 'Max Amount'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _statusFilter = null;
                          _minAmount = null;
                          _maxAmount = null;
                          _fromDate = null;
                          _toDate = null;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _minAmount =
                              double.tryParse(minCtrl.text);
                          _maxAmount =
                              double.tryParse(maxCtrl.text);
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------- HELPERS ----------------

String _statusLabel(String status) {
  switch (status) {
    case 'Draft':
      return 'Draft';
    case 'Submitted':
      return 'Pending Approval';
    case 'Pending Payment':
      return 'Approved – Pending Payment';
    case 'Paid':
      return 'Paid';
    case 'Rejected':
      return 'Rejected';
    default:
      return status;
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'Draft':
      return Colors.grey;
    case 'Submitted':
      return Colors.orange;
    case 'Pending Payment':
      return Colors.blue;
    case 'Paid':
      return Colors.green;
    case 'Rejected':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

String _helperText(report) {
  if (report.status == 'Draft') {
    return 'Tap to review & submit';
  }
  if (report.submissionDate != null) {
    return 'Submitted on ${report.submissionDate!.split('T').first}';
  }
  return '';
}

// ---------------- EMPTY STATE ----------------

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
            'No reports found',
            style:
            TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting search or filters',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Create Report'),
          ),
        ],
      ),
    );
  }
}
