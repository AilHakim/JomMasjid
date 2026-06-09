import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class StatusPill extends StatelessWidget {
  final String text;
  final bool isDanger;

  const StatusPill({super.key, required this.text, this.isDanger = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        // FIXED: Replaced withOpacity with withValues(alpha: ...)
        color: isDanger ? AppTheme.red700.withValues(alpha: 0.1) : AppTheme.teal50,
        borderRadius: BorderRadius.circular(999), 
        border: Border.all(
          // FIXED: Replaced withOpacity with withValues(alpha: ...)
          color: isDanger ? AppTheme.red700.withValues(alpha: 0.3) : AppTheme.teal200,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDanger ? AppTheme.red700 : AppTheme.teal700,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}