/// ============================================================================
/// TimerListCard - Individual Timer Display Card
/// ============================================================================
/// 
/// **Design Principle:**
/// Compact card showing timer info with quick actions (toggle, delete).
/// Uses swipe-to-delete pattern common on mobile.
/// ============================================================================
library;

import 'package:flutter/material.dart';

import '../../data/models/timer_model.dart';
import '../../l10n/app_localizations.dart';

/// Card displaying a single timer with actions
class TimerListCard extends StatelessWidget {
  /// Timer data to display
  final TimerModel timer;

  /// Callback when toggle is tapped
  final VoidCallback onToggle;

  /// Callback when edit is tapped
  final VoidCallback onEdit;

  /// Callback when delete is tapped
  final VoidCallback onDelete;

  const TimerListCard({
    super.key,
    required this.timer,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final timeRemaining = timer.getTimeRemaining();
    final l10n = AppLocalizations.of(context);

    return Dismissible(
      key: Key(timer.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Theme.of(context).colorScheme.error,
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.onError,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: onEdit, // Tap to edit timer
          onLongPress: () => _showContextMenu(context, l10n), // Long press for menu
          borderRadius: BorderRadius.circular(12),
          child: ListTile(
            // Timer icon based on repeat mode
            leading: CircleAvatar(
            backgroundColor: timer.isEnabled
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(
              _getRepeatIcon(),
              color: timer.isEnabled
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
          ),

          // Timer label
          title: Text(
            timer.label,
            style: TextStyle(
              decoration: timer.isEnabled ? null : TextDecoration.lineThrough,
              color: timer.isEnabled ? null : Theme.of(context).colorScheme.outline,
            ),
          ),

          // Time info
          subtitle: Text(
            _getSubtitleText(timeRemaining, l10n),
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),

          // Trailing actions: edit icon and toggle switch
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit button
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                iconSize: 20,
                tooltip: l10n.edit,
                onPressed: onEdit,
              ),
              // Toggle switch
              Switch(
                value: timer.isEnabled,
                onChanged: (_) => onToggle(),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  /// Show context menu on long press
  void _showContextMenu(BuildContext context, AppLocalizations l10n) {
    final RenderBox overlay = 
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        100,
        200,
        overlay.size.width - 100,
        overlay.size.height - 200,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'edit',
          child: ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(l10n.edit),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem<String>(
          value: 'toggle',
          child: ListTile(
            leading: const Icon(Icons.toggle_on_outlined),
            title: Text(l10n.toggle),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              l10n.delete,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    ).then((value) {
      switch (value) {
        case 'edit':
          onEdit();
          break;
        case 'toggle':
          onToggle();
          break;
        case 'delete':
          _confirmDelete(context, l10n);
          break;
      }
    });
  }

  /// Show delete confirmation dialog
  void _confirmDelete(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteTimerTitle),
        content: Text(l10n.deleteTimerMessage(timer.label)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  /// Get icon based on repeat mode
  IconData _getRepeatIcon() {
    switch (timer.repeatMode) {
      case TimerRepeatMode.oneTime:
        return Icons.timer_outlined;
      case TimerRepeatMode.daily:
        return Icons.repeat;
      case TimerRepeatMode.weekly:
        return Icons.calendar_today;
    }
  }

  /// Get subtitle text with time info
  String _getSubtitleText(Duration? timeRemaining, AppLocalizations l10n) {
    final time = _formatTime(timer.targetTime);
    
    if (!timer.isEnabled) {
      return '${l10n.disabled} • $time';
    }

    if (timeRemaining == null) {
      return l10n.expired;
    }

    final repeatLabel = timer.repeatMode == TimerRepeatMode.oneTime
        ? l10n.once
        : timer.repeatMode == TimerRepeatMode.daily
            ? l10n.daily
            : l10n.weekly;

    return '$repeatLabel • $time • ${_formatDuration(timeRemaining)}';
  }

  /// Format DateTime for time display
  String _formatTime(DateTime time) {
    final hour = time.hour > 12 
        ? time.hour - 12 
        : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Format duration for display
  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 60) {
      return 'in ${duration.inMinutes}m';
    }
    if (duration.inHours < 24) {
      return 'in ${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return 'in ${duration.inDays}d';
  }
}
