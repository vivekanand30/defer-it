import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handles the interaction with flutter_local_notifications for the app.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'defer_it_reminders';
  static const String channelName = 'Defer It Reminders';
  static const String channelDescription =
      'Reminders to revisit saved content.';

  static const String actionOpen = 'OPEN_ITEM';
  static const String actionSnooze = 'SNOOZE_ITEM';
  static const String actionDone = 'COMPLETE_ITEM';

  Future<void> initialize(
    void Function(NotificationResponse response) onTap,
  ) async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: onTap,
      onDidReceiveBackgroundNotificationResponse: onTap,
    );

    const androidChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.max,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Schedule notification for a given [DateTime].
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        priority: Priority.high,
        importance: Importance.max,
        actions: const [
          AndroidNotificationAction(
            actionOpen,
            'Open',
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            actionSnooze,
            'Snooze',
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            actionDone,
            'Done',
          ),
        ],
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _plugin.schedule(
      id,
      title,
      body,
      scheduledAt.toLocal(),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: id.toString(),
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);

  Future<void> cancelAll() => _plugin.cancelAll();
}
