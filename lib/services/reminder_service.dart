import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import '../db/app_database.dart';
import 'notification_service.dart';

const backgroundTaskName = 'defer_it_background_refresh';

/// Coordinates scheduled reminders and background refreshes.
class ReminderService {
  ReminderService(this._database);

  final AppDatabase _database;

  Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      await Workmanager().initialize(_callbackDispatcher, isInDebugMode: false);
      await Workmanager().registerPeriodicTask(
        'refresh-due-reminders',
        backgroundTaskName,
        frequency: const Duration(hours: 6),
        constraints: Constraints(networkType: NetworkType.not_required),
      );
    } catch (e) {
      debugPrint('Workmanager init failed: $e');
    }
  }

  Future<void> scheduleForItem({
    required int id,
    required String title,
    required String body,
    required DateTime? remindAt,
  }) async {
    if (remindAt == null) {
      await NotificationService.instance.cancel(id);
      return;
    }

    // Schedule notification
    await NotificationService.instance.scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledAt: remindAt,
    );
  }

  Future<void> cancelForItem(int id) async {
    await NotificationService.instance.cancel(id);
  }

  Future<void> handleNotificationResponse(NotificationResponse response) async {
    final payload = response.payload;
    if (payload == null) return;
    final id = int.tryParse(payload);
    if (id == null) return;

    switch (response.actionId) {
      case NotificationService.actionDone:
        await _database.markDone(id);
        await cancelForItem(id);
        break;
      case NotificationService.actionSnooze:
        final newTime = DateTime.now().add(const Duration(minutes: 15));
        await _database.snoozeItem(id, newTime);
        await scheduleForItem(
          id: id,
          title: 'Snoozed reminder',
          body: 'We will remind you again in 15 minutes.',
          remindAt: newTime,
        );
        break;
      default:
        break;
    }
  }

  /// Returns a reminder time relative to now based on quick preset.
  static DateTime computePreset(ReminderPreset preset) {
    final now = DateTime.now();
    switch (preset) {
      case ReminderPreset.tonight:
        final tonight = DateTime(now.year, now.month, now.day, 20, 0);
        return tonight.isBefore(now) ? now.add(const Duration(hours: 1)) : tonight;
      case ReminderPreset.tomorrow:
        final tomorrow = now.add(const Duration(days: 1));
        return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0);
      case ReminderPreset.weekend:
        var target = now;
        while (target.weekday != DateTime.saturday) {
          target = target.add(const Duration(days: 1));
        }
        return DateTime(target.year, target.month, target.day, 10, 0);
      case ReminderPreset.custom:
        return now.add(const Duration(hours: 1));
    }
  }
}

enum ReminderPreset { tonight, tomorrow, weekend, custom }

@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('Executing background task: ' '$task');
    return Future.value(true);
  });
}
