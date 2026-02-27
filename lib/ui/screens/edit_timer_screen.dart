/// ============================================================================
/// EditTimerScreen - Edit Existing Timer
/// ============================================================================
/// 
/// **Design Principle:**
/// Reuses the same form layout as AddTimerScreen but pre-fills with existing
/// timer data. Provides both update and delete functionality.
/// 
/// **Key Features:**
/// - Pre-populated form fields from existing timer
/// - Same validation rules as creating new timer
/// - Delete button with confirmation dialog
/// - Visual feedback on save/delete actions
/// ============================================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/timer_model.dart';
import '../../l10n/app_localizations.dart';
import '../state/timer_state.dart';

/// Screen for editing an existing timer
class EditTimerScreen extends ConsumerStatefulWidget {
  /// The timer to edit
  final TimerModel timer;

  const EditTimerScreen({
    super.key,
    required this.timer,
  });

  @override
  ConsumerState<EditTimerScreen> createState() => _EditTimerScreenState();
}

class _EditTimerScreenState extends ConsumerState<EditTimerScreen> {
  /// Controller for timer label input
  late final TextEditingController _labelController;

  /// Selected time for the timer
  late TimeOfDay _selectedTime;

  /// Selected repeat mode
  late TimerRepeatMode _repeatMode;

  /// Track if changes were made
  bool _hasChanges = false;

  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize form fields with existing timer data
    _labelController = TextEditingController(text: widget.timer.label);
    _selectedTime = TimeOfDay(
      hour: widget.timer.targetTime.hour,
      minute: widget.timer.targetTime.minute,
    );
    _repeatMode = widget.timer.repeatMode;

    // Listen for changes in label field
    _labelController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _labelController.removeListener(_onFieldChanged);
    _labelController.dispose();
    super.dispose();
  }

  /// Mark that changes have been made
  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return PopScope(
      // Warn user about unsaved changes
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _hasChanges) {
          _showDiscardChangesDialog();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.editTimer),
          actions: [
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.deleteTimer,
              onPressed: _confirmDelete,
            ),
            // Save button
            TextButton(
              onPressed: _hasChanges ? _saveTimer : null,
              child: Text(l10n.save),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ========================================
              // Timer Label
              // ========================================
              TextFormField(
                controller: _labelController,
                decoration: InputDecoration(
                  labelText: l10n.label,
                  hintText: l10n.labelHint,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterLabel;
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 24),

              // ========================================
              // Time Picker
              // ========================================
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.time),
                subtitle: Text(
                  _formatTime(_selectedTime),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                trailing: const Icon(Icons.access_time),
                onTap: _pickTime,
              ),

              const SizedBox(height: 24),

              // ========================================
              // Repeat Mode
              // ========================================
              Text(l10n.repeat),
              const SizedBox(height: 8),

              SegmentedButton<TimerRepeatMode>(
                segments: [
                  ButtonSegment(
                    value: TimerRepeatMode.oneTime,
                    label: Text(l10n.once),
                    icon: const Icon(Icons.looks_one),
                  ),
                  ButtonSegment(
                    value: TimerRepeatMode.daily,
                    label: Text(l10n.daily),
                    icon: const Icon(Icons.repeat),
                  ),
                ],
                selected: {_repeatMode},
                onSelectionChanged: (Set<TimerRepeatMode> modes) {
                  setState(() {
                    _repeatMode = modes.first;
                    _hasChanges = true;
                  });
                },
              ),

              const SizedBox(height: 32),

              // ========================================
              // Preview
              // ========================================
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.preview,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(_getPreviewText(l10n)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ========================================
              // Timer Info
              // ========================================
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.timerInfo,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(l10n.created, _formatDateTime(widget.timer.createdAt)),
                      const SizedBox(height: 4),
                      _buildInfoRow(l10n.status, widget.timer.isEnabled ? l10n.enabled : l10n.disabled),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ========================================
              // Delete Button (Alternative prominent position)
              // ========================================
              OutlinedButton.icon(
                onPressed: _confirmDelete,
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.deleteTimer),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build an info row for timer details
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        Text(value),
      ],
    );
  }

  /// Format TimeOfDay for display
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Format DateTime for display
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }

  /// Show time picker dialog
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _hasChanges = true;
      });
    }
  }

  /// Get preview text based on current settings
  String _getPreviewText(AppLocalizations l10n) {
    final label =
        _labelController.text.isEmpty ? l10n.label : _labelController.text;
    final time = _formatTime(_selectedTime);

    switch (_repeatMode) {
      case TimerRepeatMode.oneTime:
        return l10n.willTriggerAt(label, time);
      case TimerRepeatMode.daily:
        return l10n.willTriggerDaily(label, time);
      case TimerRepeatMode.weekly:
        return l10n.willTriggerWeekly(label, time);
    }
  }

  /// Show confirmation dialog before deleting
  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTimerTitle),
        content: Text(l10n.deleteTimerMessage(widget.timer.label)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final l10n = AppLocalizations.of(context);
      
      // Delete timer through state notifier
      ref.read(timerListProvider.notifier).removeTimer(widget.timer.id);

      // Show confirmation and return
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.timerDeleted)),
      );
      Navigator.pop(context);
    }
  }

  /// Show dialog when user tries to leave with unsaved changes
  Future<void> _showDiscardChangesDialog() async {
    final l10n = AppLocalizations.of(context);
    
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.discardChangesTitle),
        content: Text(l10n.discardChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.keepEditing),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.discard),
          ),
        ],
      ),
    );

    if (shouldDiscard == true && mounted) {
      Navigator.pop(context);
    }
  }

  /// Save the timer and return to home screen
  void _saveTimer() {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);

    // Calculate target DateTime
    final now = DateTime.now();
    var targetTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // If one-time and time has passed today, set for tomorrow
    if (_repeatMode == TimerRepeatMode.oneTime && targetTime.isBefore(now)) {
      targetTime = targetTime.add(const Duration(days: 1));
    }

    // Create updated timer model
    final updatedTimer = widget.timer.copyWith(
      label: _labelController.text.trim(),
      targetTime: targetTime,
      repeatMode: _repeatMode,
    );

    // Update timer through state notifier
    ref.read(timerListProvider.notifier).updateTimer(updatedTimer);

    // Show confirmation and return
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.timerUpdated)),
    );
    Navigator.pop(context);
  }
}
