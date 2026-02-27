/// ============================================================================
/// ChimeScheduler - Hourly Chime Scheduling Engine
/// ============================================================================
/// 
/// **Design Principle:**
/// Centralizes all time-based scheduling logic. Uses a timer-based approach
/// for in-app chimes and system alarms for background operation.
/// 
/// **How it works:**
/// 1. Calculates time until next hour boundary
/// 2. Sets a timer to trigger at that moment
/// 3. On trigger: plays sound, shows notification, schedules next hour
/// 
/// **Background Considerations:**
/// - Mobile: Uses platform alarm APIs (Android AlarmManager, iOS BGTaskScheduler)
/// - Desktop: Can rely on app staying in memory
/// - Web: Limited to tab being open (no true background)
/// 
/// **Quiet Hours:**
/// Chimes are suppressed during user-defined quiet hours (e.g., 22:00-07:00)
/// ============================================================================
library;

import 'dart:async';
import 'package:flutter/foundation.dart';

import '../notification/notification_service.dart';
import '../audio/audio_service.dart';

/// Handles scheduling and triggering of hourly chimes
class ChimeScheduler {
  // Private constructor for singleton
  ChimeScheduler._();
  
  /// Global singleton instance
  static final ChimeScheduler instance = ChimeScheduler._();

  /// Timer for next chime
  Timer? _chimeTimer;

  /// Flag indicating if chimes are enabled
  bool _isEnabled = false;

  /// Quiet hours start (hour in 24h format, e.g., 22 for 10 PM)
  int _quietStart = 22;

  /// Quiet hours end (hour in 24h format, e.g., 7 for 7 AM)
  int _quietEnd = 7;

  /// Check if chimes are currently enabled
  bool get isEnabled => _isEnabled;

  /// Start the hourly chime scheduler
  /// 
  /// Calculates time until next hour and sets up recurring chimes.
  /// Call this when the app starts or when user enables chimes.
  void start({int? quietStart, int? quietEnd}) {
    if (_isEnabled) return; // Already running

    _isEnabled = true;
    if (quietStart != null) _quietStart = quietStart;
    if (quietEnd != null) _quietEnd = quietEnd;

    _scheduleNextChime();
  }

  /// Stop the hourly chime scheduler
  /// 
  /// Cancels any pending timers. Call when user disables chimes.
  void stop() {
    _isEnabled = false;
    _chimeTimer?.cancel();
    _chimeTimer = null;
  }

  /// Update quiet hours configuration
  /// 
  /// [start] - Hour to start quiet mode (0-23)
  /// [end] - Hour to end quiet mode (0-23)
  void setQuietHours({required int start, required int end}) {
    _quietStart = start;
    _quietEnd = end;
  }

  /// Schedule the next hourly chime
  /// 
  /// Calculates duration until the next hour boundary and sets a timer.
  void _scheduleNextChime() {
    if (!_isEnabled) return;

    final now = DateTime.now();
    
    // Calculate next hour boundary
    // e.g., if it's 14:35:20, next hour is 15:00:00
    final nextHour = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour + 1, // Next hour
      0,            // 0 minutes
      0,            // 0 seconds
    );

    // Calculate duration until next hour
    final durationUntilNextHour = nextHour.difference(now);

    // Set timer for next chime
    _chimeTimer = Timer(durationUntilNextHour, _onChimeTrigger);

    if (kDebugMode) {
      print('[ChimeScheduler] Next chime scheduled for $nextHour '
          '(in ${durationUntilNextHour.inMinutes} minutes)');
    }
  }

  /// Called when a chime timer fires
  /// 
  /// Checks quiet hours, plays sound, shows notification, schedules next.
  void _onChimeTrigger() {
    if (!_isEnabled) return;

    final now = DateTime.now();
    final currentHour = now.hour;

    // Check if we're in quiet hours
    if (!_isInQuietHours(currentHour)) {
      // Play chime sound and show notification
      _playChime(currentHour);
    } else {
      if (kDebugMode) {
        print('[ChimeScheduler] Skipping chime - quiet hours active');
      }
    }

    // Schedule next hour's chime
    _scheduleNextChime();
  }

  /// Check if the given hour falls within quiet hours
  /// 
  /// Handles overnight quiet periods (e.g., 22:00 to 07:00)
  bool _isInQuietHours(int hour) {
    if (_quietStart <= _quietEnd) {
      // Simple case: quiet hours don't span midnight
      // e.g., 13:00 to 14:00
      return hour >= _quietStart && hour < _quietEnd;
    } else {
      // Overnight case: quiet hours span midnight
      // e.g., 22:00 to 07:00
      return hour >= _quietStart || hour < _quietEnd;
    }
  }

  /// Play chime sound and show notification
  void _playChime(int hour) {
    // Format hour for display
    final displayHour = _formatHour(hour);

    // Play audio
    AudioService.instance.playChime();

    // Show notification
    NotificationService.instance.showNotification(
      id: 0, // Use 0 for hourly chimes
      title: 'Beep',
      body: "It's $displayHour",
    );

    if (kDebugMode) {
      print('[ChimeScheduler] Chime triggered for $displayHour');
    }
  }

  /// Format hour for display (follows system 12/24h preference)
  /// 
  /// Returns formatted string like "3:00 PM" or "15:00"
  String _formatHour(int hour) {
    // For now, using 12-hour format with AM/PM
    // TODO: Read system preference for 12/24 hour format
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:00 $period';
  }

  /// Get time until next chime (for UI display)
  Duration? getTimeUntilNextChime() {
    if (!_isEnabled) return null;

    final now = DateTime.now();
    final nextHour = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour + 1,
      0,
      0,
    );

    return nextHour.difference(now);
  }
}
