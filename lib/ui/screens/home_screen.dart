/// ============================================================================
/// HomeScreen - Main Application Screen
/// ============================================================================
/// 
/// **Design Principle:**
/// The home screen provides a dashboard view with:
/// 1. Current time display (large, centered)
/// 2. Next chime countdown
/// 3. Quick access to timers and settings
/// 
/// **Layout:**
/// Uses a single-column layout that works well on all screen sizes
/// (phones, tablets, desktop)
/// ============================================================================
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../state/settings_state.dart';
import '../state/timer_state.dart';
import '../widgets/clock_display.dart';
import '../widgets/chime_status_card.dart';
import '../widgets/timer_list_card.dart';
import 'settings_screen.dart';
import 'add_timer_screen.dart';
import 'edit_timer_screen.dart';

/// Main screen of the Beep application
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Timer for updating the clock display every second
  Timer? _clockTimer;
  
  /// Current time for display
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Update clock every second
    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _currentTime = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final timers = ref.watch(timerListProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      // ========================================
      // App Bar
      // ========================================
      appBar: AppBar(
        title: Text(l10n.appName),
        centerTitle: true,
        actions: [
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settings,
            onPressed: () => _openSettings(context),
          ),
        ],
      ),

      // ========================================
      // Main Content
      // ========================================
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Large clock display
              ClockDisplay(
                time: _currentTime,
                use24HourFormat: settings.use24HourFormat,
              ),

              const SizedBox(height: 24),

              // Hourly chime status card
              ChimeStatusCard(
                isEnabled: settings.hourlyChimeEnabled,
                quietStart: settings.quietHoursStart,
                quietEnd: settings.quietHoursEnd,
                onToggle: (enabled) {
                  ref.read(settingsProvider.notifier)
                      .setHourlyChimeEnabled(enabled);
                },
              ),

              const SizedBox(height: 16),

              // Timer list section
              _buildTimerSection(context, timers),
            ],
          ),
        ),
      ),

      // ========================================
      // Floating Action Button
      // ========================================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddTimer(context),
        icon: const Icon(Icons.add_alarm),
        label: Text(l10n.addTimer),
      ),
    );
  }

  /// Build the timer list section
  Widget _buildTimerSection(BuildContext context, List timers) {
    final l10n = AppLocalizations.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.timers,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${timers.length} ${l10n.active}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),

        // Timer list or empty state
        if (timers.isEmpty)
          _buildEmptyTimerState(context)
        else
          ...timers.map((timer) => TimerListCard(
                timer: timer,
                onToggle: () {
                  ref.read(timerListProvider.notifier).toggleTimer(timer.id);
                },
                onEdit: () => _openEditTimer(context, timer),
                onDelete: () {
                  ref.read(timerListProvider.notifier).removeTimer(timer.id);
                },
              )),
      ],
    );
  }

  /// Empty state when no timers exist
  Widget _buildEmptyTimerState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.timer_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noTimersYet,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tapToAddTimer,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  /// Navigate to settings screen
  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  /// Navigate to add timer screen
  void _openAddTimer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddTimerScreen(),
      ),
    );
  }

  /// Navigate to edit timer screen
  void _openEditTimer(BuildContext context, timer) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTimerScreen(timer: timer),
      ),
    );
  }
}
