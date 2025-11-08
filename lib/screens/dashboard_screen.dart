import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/getwidget.dart';

import '../db/app_database.dart';
import '../models/deferred_item.dart';
import '../services/providers.dart';
import '../services/reminder_service.dart';
import '../services/share_service.dart';
import '../widgets/defer_bottom_sheet.dart';
import '../widgets/item_card.dart';
import 'item_detail_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  StreamSubscription<SharedPayload>? _shareSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenForShares();
    });
  }

  void _listenForShares() {
    final shareService = ref.read(shareServiceProvider);
    _shareSubscription?.cancel();
    _shareSubscription = shareService.stream.listen((payload) {
      _openAddSheet(initialTitle: payload.title, initialContent: payload.content);
    });
  }

  @override
  void dispose() {
    _shareSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openAddSheet({String initialTitle = '', String initialContent = ''}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DeferBottomSheet(
        initialTitle: initialTitle,
        initialContent: initialContent,
        onSubmit: (title, content, remindAt, notes) async {
          await _saveItem(title, content, remindAt, notes);
        },
      ),
    );
  }

  Future<void> _saveItem(
    String title,
    String content,
    DateTime? remindAt,
    String notes,
  ) async {
    final db = ref.read(databaseProvider);
    final reminder = ref.read(reminderServiceProvider);
    final type = _inferType(content);

    // Save shared item to DB
    final companion = DeferredItemsCompanion(
      title: Value(title),
      content: Value(content),
      type: Value(type),
      remindAt: Value(remindAt),
      notes: notes.isEmpty ? const Value.absent() : Value(notes),
    );
    final id = await db.upsertDeferredItem(companion);

    // Schedule notification
    await reminder.scheduleForItem(
      id: id,
      title: title,
      body: content,
      remindAt: remindAt,
    );

    ref.invalidate(dashboardBucketsProvider);
    ref.invalidate(doneItemsProvider);
  }

  Future<void> _markDone(DeferredItemModel item, {bool isDone = true}) async {
    final db = ref.read(databaseProvider);
    await db.markDone(item.id, isDone: isDone);
    if (isDone) {
      await ref.read(reminderServiceProvider).cancelForItem(item.id);
    }
    ref.invalidate(dashboardBucketsProvider);
    ref.invalidate(doneItemsProvider);
  }

  Future<void> _snoozeItem(DeferredItemModel item) async {
    final reminder = ref.read(reminderServiceProvider);
    final db = ref.read(databaseProvider);
    final newTime = DateTime.now().add(const Duration(minutes: 15));
    await db.snoozeItem(item.id, newTime);
    await reminder.scheduleForItem(
      id: item.id,
      title: item.title,
      body: item.content,
      remindAt: newTime,
    );
    ref.invalidate(dashboardBucketsProvider);
    ref.invalidate(doneItemsProvider);
  }

  String _inferType(String content) {
    final uri = Uri.tryParse(content.trim());
    if (uri != null && uri.hasScheme) {
      return 'link';
    }
    return 'text';
  }

  void _openDetail(DeferredItemModel item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ItemDetailScreen(itemId: item.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bucketsAsync = ref.watch(dashboardBucketsProvider);
    final doneAsync = ref.watch(doneItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Defer It'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Overdue'),
            Tab(text: 'Done'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _BucketList(
            asyncBuckets: bucketsAsync,
            section: DashboardSection.today,
            onOpen: _openDetail,
            onDone: _markDone,
            onSnooze: _snoozeItem,
          ),
          _BucketList(
            asyncBuckets: bucketsAsync,
            section: DashboardSection.upcoming,
            onOpen: _openDetail,
            onDone: _markDone,
            onSnooze: _snoozeItem,
          ),
          _BucketList(
            asyncBuckets: bucketsAsync,
            section: DashboardSection.overdue,
            onOpen: _openDetail,
            onDone: _markDone,
            onSnooze: _snoozeItem,
          ),
          doneAsync.when(
            data: (items) => _ItemList(
              items: items,
              onOpen: _openDetail,
              onDone: (item) => _markDone(item, isDone: false),
              onSnooze: _snoozeItem,
            ),
            loading: () => const Center(child: GFLoader(type: GFLoaderType.circle)),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddSheet(),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _BucketList extends StatelessWidget {
  const _BucketList({
    required this.asyncBuckets,
    required this.section,
    required this.onOpen,
    required this.onDone,
    required this.onSnooze,
  });

  final AsyncValue<Map<DashboardSection, List<DeferredItemModel>>> asyncBuckets;
  final DashboardSection section;
  final void Function(DeferredItemModel) onOpen;
  final Future<void> Function(DeferredItemModel) onDone;
  final Future<void> Function(DeferredItemModel) onSnooze;

  @override
  Widget build(BuildContext context) {
    return asyncBuckets.when(
      data: (buckets) {
        final items = buckets[section] ?? [];
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sunny, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Nothing here yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }
        return _ItemList(
          items: items,
          onOpen: onOpen,
          onDone: onDone,
          onSnooze: onSnooze,
        );
      },
      loading: () => const Center(child: GFLoader(type: GFLoaderType.circle)),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class _ItemList extends StatelessWidget {
  const _ItemList({
    required this.items,
    required this.onOpen,
    required this.onDone,
    required this.onSnooze,
  });

  final List<DeferredItemModel> items;
  final void Function(DeferredItemModel) onOpen;
  final Future<void> Function(DeferredItemModel) onDone;
  final Future<void> Function(DeferredItemModel) onSnooze;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final item = items[index];
        return Dismissible(
          key: ValueKey(item.id),
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            color: Colors.green,
            child: const Icon(Icons.done, color: Colors.white),
          ),
          secondaryBackground: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            color: Colors.orange,
            child: const Icon(Icons.snooze, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              await onDone(item);
              return true;
            } else {
              await onSnooze(item);
              return false;
            }
          },
          child: ItemCard(
            item: item,
            onTap: () => onOpen(item),
            onDone: () => onDone(item),
            onSnooze: () => onSnooze(item),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: items.length,
    );
  }
}
