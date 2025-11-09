import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/getwidget.dart';

import '../db/app_database.dart';
import '../services/providers.dart';
import '../services/reminder_service.dart';
import '../widgets/defer_bottom_sheet.dart';

class AddItemScreen extends ConsumerWidget {
  const AddItemScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('New reminder')),
      body: Center(
        child: GFButton(
          text: 'Open add sheet',
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => DeferBottomSheet(
                onSubmit: (title, content, remindAt, notes) async {
                  final db = ref.read(databaseProvider);
                  final reminder = ref.read(reminderServiceProvider);
                  final companion = DeferredItemsCompanion(
                    title: Value(title),
                    content: Value(content),
                    type: Value(content.startsWith('http') ? 'link' : 'text'),
                    remindAt: Value(remindAt),
                    notes: notes.isEmpty
                        ? const Value.absent()
                        : Value(notes),
                  );
                  final id = await db.upsertDeferredItem(companion);
                  await reminder.scheduleForItem(
                    id: id,
                    title: title,
                    body: content,
                    remindAt: remindAt,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
