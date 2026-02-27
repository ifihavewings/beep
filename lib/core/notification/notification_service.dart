/// ============================================================================
/// NotificationService - System Notification Management
/// ============================================================================
///
/// **Design Principle:**
/// Singleton pattern ensures only one notification channel is active.
/// Abstracts platform-specific notification APIs into a unified interface.
///
/// **Platform Considerations:**
/// - Android: Uses NotificationChannel (required for Android 8.0+)
/// - iOS: Requires user permission on first launch
/// - macOS: Uses UserNotifications framework
/// - Web: Uses browser Notification API (limited support)
///
/// **Limitations:**
/// - Web platform cannot play custom sounds reliably
/// - iOS/macOS require entitlements for background notifications
/// ============================================================================
library;

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Singleton service for managing system notifications
///
/// Usage:
/// ```dart
/// await NotificationService.instance.initialize();
/// await NotificationService.instance.showNotification(
///   title: 'Beep',
///   body: 'It is 3:00 PM',
/// );
/// ```
class NotificationService {
  // Private constructor for singleton pattern
  NotificationService._();

  /// Global singleton instance
  static final NotificationService instance = NotificationService._();

  /// Flutter Local Notifications plugin instance
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Flag to track initialization status
  bool _isInitialized = false;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the notification service
  ///
  /// **Must be called before any other methods**
  ///
  /// Sets up platform-specific notification channels and requests
  /// necessary permissions on iOS/macOS.
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Skip initialization on web (limited notification support)
    if (kIsWeb) {
      _isInitialized = true;
      return;
    }

    // ========================================
    // Android Configuration
    // ========================================
    // Android requires explicit initialization settings
    // The app icon should be added to android/app/src/main/res/drawable/
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // ========================================
    // iOS/macOS Configuration
    // ========================================
    // Request permission to show alerts, badges, and sounds
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings for all platforms
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    // Initialize the plugin
    await _plugin.initialize(
      initSettings,
      // Callback when user taps on notification
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions on iOS/macOS
    // Android 13+ also requires runtime permission
    await _requestPermissions();

    _isInitialized = true;
  }

  /// Request notification permissions from the system
  ///
  /// iOS/macOS: Shows system permission dialog
  /// Android 13+: Requires POST_NOTIFICATIONS permission
  Future<void> _requestPermissions() async {
    if (kIsWeb) return;

    // iOS permissions
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // macOS permissions
    await _plugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Android 13+ permissions
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Handle notification tap events
  ///
  /// Called when user taps on a notification in the system tray.
  /// Can be used to navigate to specific screens based on payload.
  void _onNotificationTapped(NotificationResponse response) {
    // TODO: Handle notification tap - navigate to relevant screen
    // The payload can contain data about which timer/chime triggered
    final payload = response.payload;
    if (payload != null) {
      // Parse payload and navigate accordingly
    }
  }

  /// Show a notification immediately
  ///
  /// [id] - Unique identifier for this notification (used for updates/cancel)
  /// [title] - Notification title
  /// [body] - Notification body text
  /// [payload] - Optional data to pass when notification is tapped
  Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      throw StateError('NotificationService must be initialized before use');
    }

    if (kIsWeb) {
      // Web fallback: Use browser alert (notifications have limited support)
      return;
    }

    // Android notification details
    const androidDetails = AndroidNotificationDetails(
      'beep_chime_channel', // Channel ID
      'Hourly Chime', // Channel name (visible in settings)
      channelDescription: 'Notifications for hourly chimes and timers',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    // iOS/macOS notification details
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Combined notification details
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _plugin.show(id, title, body, details, payload: payload);
  }

  /// Schedule a notification for a specific time
  ///
  /// [id] - Unique identifier for this notification
  /// [title] - Notification title
  /// [body] - Notification body text
  /// [scheduledTime] - When to show the notification
  /// [payload] - Optional data to pass when notification is tapped
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (!_isInitialized || kIsWeb) return;

    const androidDetails = AndroidNotificationDetails(
      'beep_timer_channel',
      'Timer Alerts',
      channelDescription: 'Notifications for custom timers',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    // Use timezone-aware scheduling
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _convertToTZDateTime(scheduledTime),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Cancel a specific notification by ID
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  /// Cancel all pending notifications
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  /// Convert DateTime to TZDateTime for scheduling
  ///
  /// Note: For simplicity, using local timezone.
  /// Production apps should use the timezone package properly.
  _convertToTZDateTime(DateTime dateTime) {
    // Import timezone package for proper timezone handling
    // For now, returning the datetime (simplified implementation)
    return dateTime;
  }
}
