/// ============================================================================
/// ClockDisplay - Large Time Display Widget
/// ============================================================================
/// 
/// **Design Principle:**
/// A visually prominent clock display that serves as the focal point of the
/// home screen. Uses large typography for easy reading at a glance.
/// ============================================================================
library;

import 'package:flutter/material.dart';

/// Large clock display widget
class ClockDisplay extends StatelessWidget {
  /// Current time to display
  final DateTime time;

  /// Whether to use 24-hour format
  final bool use24HourFormat;

  const ClockDisplay({
    super.key,
    required this.time,
    this.use24HourFormat = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 32,
        ),
        child: Column(
          children: [
            // Main time display
            Text(
              _formatTime(),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                  ),
            ),

            const SizedBox(height: 8),

            // Date display
            Text(
              _formatDate(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Format time based on 12/24 hour preference
  String _formatTime() {
    if (use24HourFormat) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else {
      final hour = time.hour > 12 
          ? time.hour - 12 
          : (time.hour == 0 ? 12 : time.hour);
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    }
  }

  /// Format date for display
  String _formatDate() {
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 
      'Friday', 'Saturday', 'Sunday'
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    final weekday = weekdays[time.weekday - 1];
    final month = months[time.month - 1];
    final day = time.day;

    return '$weekday, $month $day';
  }
}
