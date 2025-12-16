import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/app_scaffold.dart';
import '../../../widgets/primary_button.dart';

class CreateReportPage extends ConsumerStatefulWidget {
  const CreateReportPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends ConsumerState<CreateReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _purposeCtrl.dispose();
    super.dispose();
  }

  void _continueToAttach() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pushNamed(
      context,
      '/attach-expenses',
      arguments: {
        'title': _titleCtrl.text.trim(),
        'purpose':
            _purposeCtrl.text.trim().isEmpty ? null : _purposeCtrl.text.trim(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Create Report',
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'New Expense Report',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            const Text(
              'Add report details, then attach expenses.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Report Title',
                hintText: 'e.g. Client Visit – Bangalore',
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Report title is required'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _purposeCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Purpose (optional)',
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Continue to Attach Expenses',
              onPressed: _continueToAttach,
            ),
          ],
        ),
      ),
    );
  }
}
