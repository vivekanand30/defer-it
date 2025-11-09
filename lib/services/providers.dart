import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart';
import '../models/deferred_item.dart';
import 'reminder_service.dart';
import 'share_service.dart';
import 'settings_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final reminderServiceProvider = Provider<ReminderService>((ref) {
  final db = ref.watch(databaseProvider);
  final service = ReminderService(db);
  return service;
});

final shareServiceProvider = Provider<ShareService>((ref) {
  final service = ShareService();
  ref.onDispose(service.dispose);
  service.initialize();
  return service;
});

final activeItemsProvider = StreamProvider.autoDispose((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllActive();
});

final doneItemsProvider = StreamProvider.autoDispose((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchDone();
});

final dashboardBucketsProvider =
    FutureProvider.autoDispose<Map<DashboardSection, List<DeferredItemModel>>>(
  (ref) {
    final db = ref.watch(databaseProvider);
    return db.getBuckets();
  },
);
