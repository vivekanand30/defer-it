import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

import '../models/deferred_item.dart';

typedef ItemAction = void Function();

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onDone,
    this.onSnooze,
  });

  final DeferredItemModel item;
  final ItemAction? onTap;
  final ItemAction? onDone;
  final ItemAction? onSnooze;

  IconData get _icon {
    if (item.type == 'link') {
      if (item.content.contains('youtube') || item.content.contains('youtu')) {
        return Icons.ondemand_video;
      }
      return Icons.link;
    }
    return Icons.sticky_note_2_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return GFCard(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(12),
      content: ListTile(
        onTap: onTap,
        leading: Icon(_icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          item.title,
          style: Theme.of(context).textTheme.titleMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          item.remindAtLabel,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GFIconButton(
              icon: const Icon(Icons.done_rounded),
              shape: GFIconButtonShape.circle,
              size: GFSize.SMALL,
              color: Theme.of(context).colorScheme.primaryContainer,
              onPressed: onDone,
            ),
            const SizedBox(width: 4),
            GFIconButton(
              icon: const Icon(Icons.snooze_rounded),
              shape: GFIconButtonShape.circle,
              size: GFSize.SMALL,
              color: Theme.of(context).colorScheme.secondaryContainer,
              onPressed: onSnooze,
            ),
          ],
        ),
      ),
    );
  }
}
