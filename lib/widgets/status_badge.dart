import 'package:flutter/material.dart';
import '../core/theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double radius;
  const StatusBadge({Key? key, required this.status, this.radius = 8}) : super(key: key);

  Color _colorForStatus(String s) {
    final key = s.toLowerCase();
    if (key.contains('draft')) return Colors.grey;
    if (key.contains('submitted')) return AppTheme.primary;
    if (key.contains('approved')) return AppTheme.success;
    if (key.contains('pending')) return AppTheme.warning;
    if (key.contains('paid')) return AppTheme.success;
    if (key.contains('rejected')) return AppTheme.danger;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
