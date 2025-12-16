import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../providers/expense_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/primary_button.dart';
import '../../../core/theme.dart';

class CreateExpensePage extends ConsumerStatefulWidget {
  const CreateExpensePage({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateExpensePage> createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends ConsumerState<CreateExpensePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _amountCtrl = TextEditingController();
  final _merchantCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  String _category = 'Travel';
  DateTime _pickedDate = DateTime.now();
  File? _receiptFile;

  double _amountValue = 0;
  bool _isFormValid = false;
  bool _saving = false;
  bool _showSuccess = false;

  late final AnimationController _successController;
  late final Animation<double> _scaleAnim;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _amountCtrl.addListener(_validateForm);
    _merchantCtrl.addListener(_validateForm);
    _descriptionCtrl.addListener(_validateForm);

    _successController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scaleAnim =
        CurvedAnimation(parent: _successController, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _merchantCtrl.dispose();
    _descriptionCtrl.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final amount = double.tryParse(_amountCtrl.text) ?? 0;

    final isAmountValid = amount > 0; // allow any positive amount
    final receiptOk = amount <= 200 || _receiptFile != null;

    setState(() {
      _amountValue = amount;
      _isFormValid = isAmountValid && receiptOk;
    });
  }


  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (picked == null) return;

    final tempFile = File(picked.path);

    final appDir = await getApplicationDocumentsDirectory();
    final ext = picked.path.split('.').last;
    final fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final savedFile = await tempFile.copy('${appDir.path}/$fileName');

    final sizeMB = (await savedFile.length()) / (1024 * 1024);
    if (sizeMB > 5) {
      _showSnack('Image too large. Max 5 MB allowed.');
      return;
    }

    setState(() => _receiptFile = savedFile);
    _validateForm();
  }

  void _previewReceipt() {
    if (_receiptFile == null) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(child: Image.file(_receiptFile!)),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_amountValue > 200 && _receiptFile == null) {
      _showSnack('Mandatory for amount > ₹200');
      return;
    }

    setState(() => _saving = true);

    final auth = ref.read(authProvider);
    final userId = auth.user?.id ?? 1;

    try {
      await ref.read(expenseProvider.notifier).addExpense(
        userId: userId,
        amount: _amountValue,
        category: _category,
        date: _pickedDate.toIso8601String(),
        merchant: _merchantCtrl.text.trim().isEmpty ? null : _merchantCtrl.text,
        description:
        _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text,
        receiptFile: _receiptFile,
      );

      setState(() => _showSuccess = true);
      _successController.forward();
      await Future.delayed(const Duration(milliseconds: 900));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnack('Error saving expense');
    } finally {
      setState(() => _saving = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _pickedDate.toLocal().toString().split(' ').first;

    return Stack(
      children: [
        AppScaffold(
          title: 'Create Expense',
          body: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _amountCtrl,
                  autofocus: true,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount (₹)',
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                  validator: (v) {
                    final val = double.tryParse(v ?? '');
                    if (val == null) return 'Enter valid amount';
                    if (val <= 0) return 'Amount must be greater than 0';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'Travel', child: Text('Travel')),
                    DropdownMenuItem(value: 'Food', child: Text('Food')),
                    DropdownMenuItem(value: 'Accommodation', child: Text('Accommodation')),
                    DropdownMenuItem(value: 'Supplies', child: Text('Supplies')),
                    DropdownMenuItem(value: 'Others', child: Text('Others')),
                  ],
                  onChanged: (v) => setState(() => _category = v ?? 'Travel'),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _merchantCtrl,
                  decoration: const InputDecoration(labelText: 'Merchant'),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 16),

                 
// EXPENSE DATE
 
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _pickedDate,
                      firstDate: DateTime(2010),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _pickedDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Expense Date',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      dateLabel,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

 
// RECEIPT
 
                Text(
                  _amountValue > 200
                      ? 'Receipt (required for amount > ₹200)'
                      : 'Receipt (optional)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _amountValue > 200 ? Colors.red : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),

                GestureDetector(
                  onTap: _previewReceipt,
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _amountValue > 200 && _receiptFile == null
                            ? Colors.red
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: _receiptFile == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.receipt_long, size: 48),
                        SizedBox(height: 8),
                      ],
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _receiptFile!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                PrimaryButton(
                  label: 'Save Expense',
                  onPressed: _isFormValid && !_saving ? _submit : null,
                  loading: _saving,
                ),
              ],
            ),
          ),
        ),

        if (_saving)
          Container(
            color: Colors.black.withOpacity(0.55),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),

        if (_showSuccess)
          Center(
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.success,
                ),
                child: const Icon(Icons.check, size: 64, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
