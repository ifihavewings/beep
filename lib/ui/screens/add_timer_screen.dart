/// ============================================================================
/// AddTimerScreen - Create New Timer
/// ============================================================================
/// 
/// **Design Principle:**
/// Simple form for creating timers with minimal required input.
/// Uses native time picker for platform-appropriate experience.
/// ============================================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/timer_model.dart';
import '../../l10n/app_localizations.dart';
import '../state/timer_state.dart';

/// Screen for adding a new timer
class AddTimerScreen extends ConsumerStatefulWidget {
  const AddTimerScreen({super.key});

  @override
  ConsumerState<AddTimerScreen> createState() => _AddTimerScreenState();
}

class _AddTimerScreenState extends ConsumerState<AddTimerScreen> {
  /// Controller for timer label input
  final _labelController = TextEditingController();

  /// Selected time for the timer
  TimeOfDay _selectedTime = TimeOfDay.now();

  /// Selected repeat mode
  TimerRepeatMode _repeatMode = TimerRepeatMode.oneTime;

  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newTimer),
        actions: [
          TextButton(
            onPressed: _saveTimer,
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
                setState(() => _repeatMode = modes.first);
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
          ],
        ),
      ),
    );
  }

  /// Format TimeOfDay for display
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Show time picker dialog
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  /// Get preview text based on current settings
  String _getPreviewText(AppLocalizations l10n) {
    final label = _labelController.text.isEmpty 
        ? l10n.label 
        : _labelController.text;
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

    // Add timer through state notifier
    ref.read(timerListProvider.notifier).addTimer(
          label: _labelController.text.trim(),
          targetTime: targetTime,
          repeatMode: _repeatMode,
        );

    // Show confirmation and return
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.timerAdded)),
    );
    Navigator.pop(context);
  }
}
