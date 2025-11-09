import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/getwidget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/deferred_item.dart';
import '../services/providers.dart';
import '../services/reminder_service.dart';

class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({super.key, required this.itemId});

  final int itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemFuture = ref.watch(_itemProvider(itemId));

    return Scaffold(
      appBar: AppBar(title: const Text('Item details')),
      body: itemFuture.when(
        data: (item) {
          if (item == null) {
            return const Center(child: Text('Item not found'));
          }
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(item.content, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 12),
                Text('Reminder: ${item.remindAtLabel}'),
                const SizedBox(height: 12),
                if (item.notes != null && item.notes!.isNotEmpty) ...[
                  Text('Notes', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(item.notes!),
                ],
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: GFButton(
                        text: 'Open Link',
                        onPressed: () => _openLink(item.content),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GFButton(
                        text: 'Done',
                        color: Colors.green,
                        onPressed: () async {
                          await ref.read(databaseProvider).markDone(item.id);
                          await ref
                              .read(reminderServiceProvider)
                              .cancelForItem(item.id);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GFButton(
                        text: 'Snooze',
                        color: Colors.orange,
                        onPressed: () async {
                          final newTime = DateTime.now().add(const Duration(minutes: 15));
                          await ref.read(databaseProvider).snoozeItem(item.id, newTime);
                          await ref.read(reminderServiceProvider).scheduleForItem(
                                id: item.id,
                                title: item.title,
                                body: item.content,
                                remindAt: newTime,
                              );
                          ref.invalidate(dashboardBucketsProvider);
                          ref.invalidate(doneItemsProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Snoozed until ${newTime.toLocal()}'),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GFButton(
                        text: 'Delete',
                        color: Colors.redAccent,
                        onPressed: () async {
                          await ref.read(databaseProvider).deleteDeferredItem(item.id);
                          await ref
                              .read(reminderServiceProvider)
                              .cancelForItem(item.id);
                          ref.invalidate(dashboardBucketsProvider);
                          ref.invalidate(doneItemsProvider);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: GFLoader(type: GFLoaderType.circle)),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Future<void> _openLink(String content) async {
    final uri = Uri.tryParse(content.trim());
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

final _itemProvider = FutureProvider.family<DeferredItemModel?, int>((ref, id) {
  return ref.read(databaseProvider).getById(id);
});
