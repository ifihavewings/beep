/// ============================================================================
/// ChimeStatusCard - Hourly Chime Status Display
/// ============================================================================
/// 
/// **Design Principle:**
/// Shows at-a-glance status of hourly chime feature with quick toggle.
/// Displays next chime time and quiet hours info.
/// ============================================================================
library;

import 'package:flutter/material.dart';

import '../../core/scheduler/chime_scheduler.dart';
import '../../l10n/app_localizations.dart';

/// Card showing hourly chime status
class ChimeStatusCard extends StatelessWidget {
  /// Whether chimes are enabled
  final bool isEnabled;

  /// Quiet hours start (0-23)
  final int quietStart;

  /// Quiet hours end (0-23)
  final int quietEnd;

  /// Callback when toggle is changed
  final ValueChanged<bool> onToggle;

  const ChimeStatusCard({
    super.key,
    required this.isEnabled,
    required this.quietStart,
    required this.quietEnd,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final timeUntilNext = ChimeScheduler.instance.getTimeUntilNextChime();
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isEnabled 
                          ? Icons.notifications_active 
                          : Icons.notifications_off_outlined,
                      color: isEnabled
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.hourlyChime,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                Switch(
                  value: isEnabled,
                  onChanged: onToggle,
                ),
              ],
            ),

            // Status details
            if (isEnabled) ...[
              const Divider(height: 24),
              
              // Next chime info
              if (timeUntilNext != null)
                _buildInfoRow(
                  context,
                  icon: Icons.schedule,
                  label: l10n.nextChime,
                  value: _formatDuration(timeUntilNext),
                ),

              const SizedBox(height: 8),

              // Quiet hours info
              _buildInfoRow(
                context,
                icon: Icons.bedtime_outlined,
                label: l10n.quietHours,
                value: '${_formatHour(quietStart)} - ${_formatHour(quietEnd)}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build an info row with icon, label, and value
  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  /// Format duration for display
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = duration.inHours;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }

  /// Format hour for display
  String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour $period';
  }
}
