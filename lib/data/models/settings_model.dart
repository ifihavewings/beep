/// ============================================================================
/// SettingsModel - User Preferences Data Model
/// ============================================================================
/// 
/// **Design Principle:**
/// Immutable data class containing all user-configurable settings.
/// Provides sensible defaults for first-time users.
/// ============================================================================
library;

import 'package:flutter/material.dart';

/// Immutable data model for application settings
@immutable
class SettingsModel {
  // ========================================
  // Hourly Chime Settings
  // ========================================
  
  /// Whether hourly chimes are enabled
  final bool hourlyChimeEnabled;

  /// Quiet hours start (0-23)
  final int quietHoursStart;

  /// Quiet hours end (0-23)
  final int quietHoursEnd;

  // ========================================
  // Audio Settings
  // ========================================
  
  /// Master volume (0.0 to 1.0)
  final double volume;

  /// Whether to vibrate on mobile devices
  final bool vibrateEnabled;

  // ========================================
  // Display Settings
  // ========================================
  
  /// Theme mode (system, light, dark)
  final ThemeMode themeMode;

  /// Use 24-hour time format
  final bool use24HourFormat;

  // ========================================
  // Language Settings
  // ========================================
  
  /// Locale code (null means follow system)
  final String? localeCode;

  /// Default values for new users
  const SettingsModel({
    this.hourlyChimeEnabled = true,
    this.quietHoursStart = 22,  // 10 PM
    this.quietHoursEnd = 7,     // 7 AM
    this.volume = 1.0,
    this.vibrateEnabled = true,
    this.themeMode = ThemeMode.system,
    this.use24HourFormat = false,
    this.localeCode,
  });

  /// Create a copy with modified fields
  SettingsModel copyWith({
    bool? hourlyChimeEnabled,
    int? quietHoursStart,
    int? quietHoursEnd,
    double? volume,
    bool? vibrateEnabled,
    ThemeMode? themeMode,
    bool? use24HourFormat,
    String? localeCode,
    bool clearLocale = false,
  }) {
    return SettingsModel(
      hourlyChimeEnabled: hourlyChimeEnabled ?? this.hourlyChimeEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      volume: volume ?? this.volume,
      vibrateEnabled: vibrateEnabled ?? this.vibrateEnabled,
      themeMode: themeMode ?? this.themeMode,
      use24HourFormat: use24HourFormat ?? this.use24HourFormat,
      localeCode: clearLocale ? null : (localeCode ?? this.localeCode),
    );
  }

  /// Create from JSON (for loading from storage)
  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      hourlyChimeEnabled: json['hourlyChimeEnabled'] as bool? ?? true,
      quietHoursStart: json['quietHoursStart'] as int? ?? 22,
      quietHoursEnd: json['quietHoursEnd'] as int? ?? 7,
      volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
      vibrateEnabled: json['vibrateEnabled'] as bool? ?? true,
      themeMode: ThemeMode.values[json['themeMode'] as int? ?? 0],
      use24HourFormat: json['use24HourFormat'] as bool? ?? false,
      localeCode: json['localeCode'] as String?,
    );
  }

  /// Convert to JSON (for saving to storage)
  Map<String, dynamic> toJson() {
    return {
      'hourlyChimeEnabled': hourlyChimeEnabled,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
      'volume': volume,
      'vibrateEnabled': vibrateEnabled,
      'themeMode': themeMode.index,
      'use24HourFormat': use24HourFormat,
      'localeCode': localeCode,
    };
  }

  @override
  String toString() {
    return 'SettingsModel(hourlyChimeEnabled: $hourlyChimeEnabled, '
        'quietHours: $quietHoursStart-$quietHoursEnd, '
        'volume: $volume, themeMode: $themeMode)';
  }
}
