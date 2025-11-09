import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.defaultReminder,
  });

  final ThemeMode themeMode;
  final TimeOfDay defaultReminder;

  AppSettings copyWith({ThemeMode? themeMode, TimeOfDay? defaultReminder}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      defaultReminder: defaultReminder ?? this.defaultReminder,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.index,
        'defaultReminderHour': defaultReminder.hour,
        'defaultReminderMinute': defaultReminder.minute,
      };

  static AppSettings fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: ThemeMode.values[json['themeMode'] as int? ?? 0],
      defaultReminder: TimeOfDay(
        hour: json['defaultReminderHour'] as int? ?? 9,
        minute: json['defaultReminderMinute'] as int? ?? 0,
      ),
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier(this._storage)
      : super(const AppSettings(
          themeMode: ThemeMode.system,
          defaultReminder: TimeOfDay(hour: 9, minute: 0),
        ));

  final FlutterSecureStorage _storage;
  static const _key = 'defer_it_settings';

  Future<void> load() async {
    final value = await _storage.read(key: _key);
    if (value == null) return;
    final jsonMap = jsonDecode(value) as Map<String, dynamic>;
    state = AppSettings.fromJson(jsonMap);
  }

  Future<void> updateTheme(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _persist();
  }

  Future<void> updateReminder(TimeOfDay time) async {
    state = state.copyWith(defaultReminder: time);
    await _persist();
  }

  Future<void> _persist() async {
    await _storage.write(key: _key, value: jsonEncode(state.toJson()));
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final storage = const FlutterSecureStorage();
  final notifier = SettingsNotifier(storage);
  notifier.load();
  return notifier;
});
