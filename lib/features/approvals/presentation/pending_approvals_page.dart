import 'package:flutter/material.dart';

class PendingApprovalsPage extends StatelessWidget {
  const PendingApprovalsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Approvals')),
      body: const Center(
          child: Text('Manager approvals will be implemented on Day 6')),
    );
  }
}
