import 'package:flutter/material.dart';

class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({Key? key, this.title = 'Coming Soon'})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(
          child: Text('This screen will be implemented in Day 2+')),
    );
  }
}
