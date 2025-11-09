import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/deferred_item.dart';

part 'app_database.g.dart';

class DeferredItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  TextColumn get type => text().withDefault(const Constant('text'))();
  DateTimeColumn get remindAt => dateTime().nullable()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'defer_it.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(tables: [DeferredItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Insert or update a deferred item
  Future<int> upsertDeferredItem(DeferredItemsCompanion companion) {
    return into(deferredItems).insertOnConflictUpdate(companion);
  }

  Future<void> deleteDeferredItem(int id) async {
    await (delete(deferredItems)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> markDone(int id, {bool isDone = true}) async {
    await (update(deferredItems)..where((tbl) => tbl.id.equals(id))).write(
      DeferredItemsCompanion(isDone: Value(isDone)),
    );
  }

  Future<void> snoozeItem(int id, DateTime newTime) async {
    await (update(deferredItems)..where((tbl) => tbl.id.equals(id))).write(
      DeferredItemsCompanion(remindAt: Value(newTime)),
    );
  }

  Stream<List<DeferredItemModel>> watchAllActive() {
    final query = (select(deferredItems)
          ..where((tbl) => tbl.isDone.equals(false))
          ..orderBy([
            (tbl) => OrderingTerm(
                  expression: tbl.remindAt,
                  mode: OrderingMode.asc,
                  nulls: NullsOrder.last,
                ),
            (tbl) => OrderingTerm(expression: tbl.createdAt),
          ]))
        .watch();

    return query.map(
      (rows) => rows.map(_mapDataToModel).toList(),
    );
  }

  Stream<List<DeferredItemModel>> watchDone() {
    return (select(deferredItems)
          ..where((tbl) => tbl.isDone.equals(true))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.remindAt)])).
        watch().map((rows) => rows.map(_mapDataToModel).toList());
  }

  Future<DeferredItemModel?> getById(int id) async {
    final row = await (select(deferredItems)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _mapDataToModel(row);
  }

  DeferredItemModel _mapDataToModel(DeferredItem row) {
    return DeferredItemModel(
      id: row.id,
      title: row.title,
      content: row.content,
      type: row.type,
      remindAt: row.remindAt,
      isDone: row.isDone,
      notes: row.notes,
    );
  }

  /// Organises active items into logical buckets based on their reminder time.
  Future<Map<DashboardSection, List<DeferredItemModel>>> getBuckets() async {
    final rows = await (select(deferredItems)
          ..where((tbl) => tbl.isDone.equals(false)))
        .get();
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));

    final map = <DashboardSection, List<DeferredItemModel>>{
      DashboardSection.today: [],
      DashboardSection.upcoming: [],
      DashboardSection.overdue: [],
    };

    for (final row in rows) {
      final model = _mapDataToModel(row);
      final remindAt = model.remindAt;
      if (remindAt == null) {
        map[DashboardSection.upcoming]!.add(model);
        continue;
      }
      if (remindAt.isBefore(todayStart)) {
        map[DashboardSection.overdue]!.add(model);
      } else if (remindAt.isBefore(tomorrowStart)) {
        map[DashboardSection.today]!.add(model);
      } else {
        map[DashboardSection.upcoming]!.add(model);
      }
    }

    for (final entry in map.entries) {
      entry.value.sortBy((item) => item.remindAt ?? DateTime.fromMillisecondsSinceEpoch(item.id));
    }

    return map;
  }
}

enum DashboardSection { today, upcoming, overdue }
