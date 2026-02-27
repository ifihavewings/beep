/// ============================================================================
/// TimerState - Riverpod State Management for Custom Timers
/// ============================================================================
/// 
/// **Design Principle:**
/// Manages the list of user-created timers with CRUD operations.
/// Integrates with notification service for scheduling alerts.
/// ============================================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/timer_model.dart';
import '../../data/repositories/settings_repository.dart';
import '../../core/notification/notification_service.dart';
import 'settings_state.dart';

/// Provider for timer list state
final timerListProvider = StateNotifierProvider<TimerListNotifier, List<TimerModel>>(
  (ref) {
    final repository = ref.watch(settingsRepositoryProvider);
    return TimerListNotifier(repository);
  },
);

/// StateNotifier for managing timer list
class TimerListNotifier extends StateNotifier<List<TimerModel>> {
  final SettingsRepository _repository;
  final _uuid = const Uuid();

  TimerListNotifier(this._repository) : super([]) {
    _loadTimers();
  }

  /// Load timers from storage
  void _loadTimers() {
    state = _repository.loadTimers();
    
    // Reschedule all active timers
    for (final timer in state.where((t) => t.isEnabled)) {
      _scheduleNotification(timer);
    }
  }

  /// Add a new timer
  Future<void> addTimer({
    required String label,
    required DateTime targetTime,
    TimerRepeatMode repeatMode = TimerRepeatMode.oneTime,
    List<int> weekDays = const [],
  }) async {
    final timer = TimerModel(
      id: _uuid.v4(),
      label: label,
      targetTime: targetTime,
      repeatMode: repeatMode,
      weekDays: weekDays,
      createdAt: DateTime.now(),
    );

    state = [...state, timer];
    await _repository.saveTimers(state);
    
    _scheduleNotification(timer);
  }

  /// Remove a timer by ID
  Future<void> removeTimer(String timerId) async {
    // Cancel notification
    await NotificationService.instance.cancelNotification(timerId.hashCode);
    
    state = state.where((t) => t.id != timerId).toList();
    await _repository.saveTimers(state);
  }

  /// Toggle timer enabled state
  Future<void> toggleTimer(String timerId) async {
    state = state.map((timer) {
      if (timer.id == timerId) {
        final updated = timer.copyWith(isEnabled: !timer.isEnabled);
        
        if (updated.isEnabled) {
          _scheduleNotification(updated);
        } else {
          NotificationService.instance.cancelNotification(timerId.hashCode);
        }
        
        return updated;
      }
      return timer;
    }).toList();
    
    await _repository.saveTimers(state);
  }

  /// Update an existing timer
  Future<void> updateTimer(TimerModel timer) async {
    // Cancel old notification
    await NotificationService.instance.cancelNotification(timer.id.hashCode);
    
    state = state.map((t) => t.id == timer.id ? timer : t).toList();
    await _repository.saveTimers(state);
    
    if (timer.isEnabled) {
      _scheduleNotification(timer);
    }
  }

  /// Schedule a notification for a timer
  void _scheduleNotification(TimerModel timer) {
    if (!timer.isEnabled) return;

    final now = DateTime.now();
    DateTime scheduledTime;

    if (timer.repeatMode == TimerRepeatMode.oneTime) {
      if (timer.targetTime.isBefore(now)) return; // Past timer
      scheduledTime = timer.targetTime;
    } else {
      // For recurring timers, schedule for next occurrence
      scheduledTime = _getNextOccurrence(timer);
    }

    NotificationService.instance.scheduleNotification(
      id: timer.id.hashCode,
      title: 'Beep Timer',
      body: timer.label,
      scheduledTime: scheduledTime,
      payload: timer.id,
    );
  }

  /// Calculate next occurrence for recurring timers
  DateTime _getNextOccurrence(TimerModel timer) {
    final now = DateTime.now();
    var next = DateTime(
      now.year,
      now.month,
      now.day,
      timer.targetTime.hour,
      timer.targetTime.minute,
    );

    if (next.isBefore(now)) {
      next = next.add(const Duration(days: 1));
    }

    return next;
  }

  /// Get timer by ID
  TimerModel? getTimer(String id) {
    try {
      return state.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}
