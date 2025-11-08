import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/getwidget.dart';
import 'package:path_provider/path_provider.dart';

import '../db/app_database.dart';
import '../services/providers.dart';
import '../services/reminder_service.dart';
import '../services/settings_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('Dark mode'),
              subtitle: const Text('Toggle between light and dark themes'),
              value: settings.themeMode == ThemeMode.dark,
              onChanged: (value) {
                ref
                    .read(settingsProvider.notifier)
                    .updateTheme(value ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Default reminder time'),
              subtitle: Text('${settings.defaultReminder.format(context)}'),
              trailing: const Icon(Icons.schedule),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: settings.defaultReminder,
                );
                if (picked != null) {
                  await ref.read(settingsProvider.notifier).updateReminder(picked);
                }
              },
            ),
          ),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: const Text('Export backup'),
                  subtitle: const Text('Save a JSON backup to your documents'),
                  trailing: const Icon(Icons.download),
                  onTap: () => _exportBackup(context, ref),
                ),
                const Divider(height: 0),
                ListTile(
                  title: const Text('Import backup'),
                  subtitle: const Text('Restore from the latest export file'),
                  trailing: const Icon(Icons.upload),
                  onTap: () => _importBackup(context, ref),
                ),
              ],
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Remove Ads'),
              subtitle: const Text('Thanks for supporting Defer It!'),
              trailing: const Icon(Icons.favorite_border),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ads removed – just kidding, none here.')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final items = await db.select(db.deferredItems).get();
    final payload = items
        .map((e) => {
              'id': e.id,
              'title': e.title,
              'content': e.content,
              'type': e.type,
              'remindAt': e.remindAt?.toIso8601String(),
              'isDone': e.isDone,
              'notes': e.notes,
              'createdAt': e.createdAt.toIso8601String(),
            })
        .toList();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/defer_it_backup.json');
    await file.writeAsString(jsonEncode(payload));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Backup saved to ${file.path}')),
    );
  }

  Future<void> _importBackup(BuildContext context, WidgetRef ref) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/defer_it_backup.json');
      if (!await file.exists()) {
        throw Exception('No backup file found.');
      }
      final db = ref.read(databaseProvider);
      final reminder = ref.read(reminderServiceProvider);
      final content = await file.readAsString();
      final data = jsonDecode(content) as List<dynamic>;
      for (final entry in data) {
        final map = entry as Map<String, dynamic>;
        final remindAt = map['remindAt'] != null
            ? DateTime.tryParse(map['remindAt'] as String)
            : null;
        final companion = DeferredItemsCompanion(
          id: Value(map['id'] as int),
          title: Value(map['title'] as String),
          content: Value(map['content'] as String),
          type: Value(map['type'] as String),
          remindAt: Value(remindAt),
          isDone: Value(map['isDone'] as bool),
          notes: map['notes'] == null
              ? const Value.absent()
              : Value(map['notes'] as String),
        );
        final id = await db.upsertDeferredItem(companion);
        await reminder.scheduleForItem(
          id: id,
          title: map['title'] as String,
          body: map['content'] as String,
          remindAt: remindAt,
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup restored successfully.')),
      );
      ref.invalidate(dashboardBucketsProvider);
      ref.invalidate(doneItemsProvider);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $error')),
      );
    }
  }
}
