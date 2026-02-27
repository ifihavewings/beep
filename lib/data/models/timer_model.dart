/// ============================================================================
/// TimerModel - Data Model for Custom Timers
/// ============================================================================
/// 
/// **Design Principle:**
/// Immutable data class representing a user-created timer.
/// Uses factory constructors for creating from JSON (persistence).
/// 
/// **Timer Types:**
/// - ONE_TIME: Single trigger, then deactivated
/// - RECURRING: Triggers at same time every day/week
/// ============================================================================
library;

import 'package:flutter/foundation.dart';

/// Enum for timer repeat modes
enum TimerRepeatMode {
  /// Triggers once, then becomes inactive
  oneTime,
  
  /// Triggers every day at the specified time
  daily,
  
  /// Triggers on specific days of the week
  weekly,
}

/// Immutable data model for a custom timer
@immutable
class TimerModel {
  /// Unique identifier for this timer
  final String id;

  /// User-defined label (e.g., "Take medication")
  final String label;

  /// Target time for one-time timers, or time of day for recurring
  final DateTime targetTime;

  /// Repeat mode (one-time, daily, weekly)
  final TimerRepeatMode repeatMode;

  /// For weekly repeat: which days to trigger (0=Sunday, 6=Saturday)
  final List<int> weekDays;

  /// Whether this timer is currently active
  final bool isEnabled;

  /// Sound to play when timer triggers (null = default)
  final String? customSoundPath;

  /// When this timer was created
  final DateTime createdAt;

  const TimerModel({
    required this.id,
    required this.label,
    required this.targetTime,
    this.repeatMode = TimerRepeatMode.oneTime,
    this.weekDays = const [],
    this.isEnabled = true,
    this.customSoundPath,
    required this.createdAt,
  });

  /// Create a copy with modified fields
  /// 
  /// Useful for immutable state updates
  TimerModel copyWith({
    String? id,
    String? label,
    DateTime? targetTime,
    TimerRepeatMode? repeatMode,
    List<int>? weekDays,
    bool? isEnabled,
    String? customSoundPath,
    DateTime? createdAt,
  }) {
    return TimerModel(
      id: id ?? this.id,
      label: label ?? this.label,
      targetTime: targetTime ?? this.targetTime,
      repeatMode: repeatMode ?? this.repeatMode,
      weekDays: weekDays ?? this.weekDays,
      isEnabled: isEnabled ?? this.isEnabled,
      customSoundPath: customSoundPath ?? this.customSoundPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Create from JSON (for loading from storage)
  factory TimerModel.fromJson(Map<String, dynamic> json) {
    return TimerModel(
      id: json['id'] as String,
      label: json['label'] as String,
      targetTime: DateTime.parse(json['targetTime'] as String),
      repeatMode: TimerRepeatMode.values[json['repeatMode'] as int],
      weekDays: (json['weekDays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      isEnabled: json['isEnabled'] as bool? ?? true,
      customSoundPath: json['customSoundPath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert to JSON (for saving to storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'targetTime': targetTime.toIso8601String(),
      'repeatMode': repeatMode.index,
      'weekDays': weekDays,
      'isEnabled': isEnabled,
      'customSoundPath': customSoundPath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Calculate time remaining until this timer triggers
  /// 
  /// Returns null if timer is in the past (for one-time timers)
  Duration? getTimeRemaining() {
    final now = DateTime.now();
    
    if (repeatMode == TimerRepeatMode.oneTime) {
      if (targetTime.isBefore(now)) return null;
      return targetTime.difference(now);
    }

    // For recurring timers, calculate next occurrence
    final todayTarget = DateTime(
      now.year,
      now.month,
      now.day,
      targetTime.hour,
      targetTime.minute,
    );

    if (todayTarget.isAfter(now)) {
      return todayTarget.difference(now);
    } else {
      // Next occurrence is tomorrow
      return todayTarget.add(const Duration(days: 1)).difference(now);
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimerModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TimerModel(id: $id, label: $label, targetTime: $targetTime, '
        'repeatMode: $repeatMode, isEnabled: $isEnabled)';
  }
}
