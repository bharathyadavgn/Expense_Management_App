import 'package:expense_management_app/core/theme.dart';
import 'package:flutter/material.dart';

import 'app_drawer.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget body;
  final Widget? floatingActionButton;

  const AppScaffold({
    Key? key,
    required this.title,
    required this.body,
    this.leading,
    this.actions,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.black,
        leading: leading,
        title: Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
        actions: actions,
      ),
      drawer: const AppDrawer(),
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(16.0), child: body)),
      floatingActionButton: floatingActionButton,
    );
  }
}
