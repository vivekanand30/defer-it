// GENERATED CODE - MANUAL IMPLEMENTATION FOR OFFLINE BUILD
// ignore_for_file: type=lint

part of 'app_database.dart';

class DeferredItem extends DataClass implements Insertable<DeferredItem> {
  final int id;
  final String title;
  final String content;
  final String type;
  final DateTime? remindAt;
  final bool isDone;
  final String? notes;
  final DateTime createdAt;
  const DeferredItem({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    this.remindAt,
    required this.isDone,
    this.notes,
    required this.createdAt,
  });

  factory DeferredItem.fromData(Map<String, dynamic> data, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return DeferredItem(
      id: const IntType().mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      title: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}title'])!,
      content: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}content'])!,
      type: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}type'])!,
      remindAt: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}remind_at']),
      isDone: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}is_done'])!,
      notes: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}notes']),
      createdAt: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  Map<String, Expression<Object?>> toColumns(bool nullToAbsent) {
    final map = <String, Expression<Object?>>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || remindAt != null) {
      map['remind_at'] = Variable<DateTime?>(remindAt);
    }
    map['is_done'] = Variable<bool>(isDone);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String?>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DeferredItemsCompanion toCompanion(bool nullToAbsent) {
    return DeferredItemsCompanion(
      id: Value(id),
      title: Value(title),
      content: Value(content),
      type: Value(type),
      remindAt:
          remindAt == null && nullToAbsent ? const Value.absent() : Value(remindAt),
      isDone: Value(isDone),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }
}

class DeferredItemsCompanion extends UpdateCompanion<DeferredItem> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> content;
  final Value<String> type;
  final Value<DateTime?> remindAt;
  final Value<bool> isDone;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const DeferredItemsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.type = const Value.absent(),
    this.remindAt = const Value.absent(),
    this.isDone = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });

  DeferredItemsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String content,
    String type = 'text',
    Value<DateTime?> remindAt = const Value(null),
    Value<bool> isDone = const Value(false),
    Value<String?> notes = const Value(null),
    Value<DateTime> createdAt = const Value.absent(),
  })  : title = Value(title),
        content = Value(content),
        type = Value(type),
        remindAt = remindAt,
        isDone = isDone,
        notes = notes,
        createdAt = createdAt;

  @override
  Map<String, Expression<Object?>> toColumns(bool nullToAbsent) {
    final map = <String, Expression<Object?>>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (remindAt.present) {
      map['remind_at'] = Variable<DateTime?>(remindAt.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String?>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }
}

class $DeferredItemsTable extends DeferredItems
    with TableInfo<$DeferredItemsTable, DeferredItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeferredItemsTable(this.attachedDatabase, [this._alias]);

  final VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> _id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    hasAutoIncrement: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  @override
  GeneratedColumn<int> get id => _id;

  final VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> _title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
  );
  @override
  GeneratedColumn<String> get title => _title;

  final VerificationMeta _contentMeta = const VerificationMeta('content');
  late final GeneratedColumn<String> _content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
  );
  @override
  GeneratedColumn<String> get content => _content;

  final VerificationMeta _typeMeta = const VerificationMeta('type');
  late final GeneratedColumn<String> _type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    defaultValue: const Constant('text'),
  );
  @override
  GeneratedColumn<String> get type => _type;

  final VerificationMeta _remindAtMeta = const VerificationMeta('remindAt');
  late final GeneratedColumn<DateTime> _remindAt = GeneratedColumn<DateTime>(
    'remind_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
  );
  @override
  GeneratedColumn<DateTime> get remindAt => _remindAt;

  final VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  late final GeneratedColumn<bool> _isDone = GeneratedColumn<bool>(
    'is_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    defaultValue: const Constant(false),
  );
  @override
  GeneratedColumn<bool> get isDone => _isDone;

  final VerificationMeta _notesMeta = const VerificationMeta('notes');
  late final GeneratedColumn<String> _notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
  );
  @override
  GeneratedColumn<String> get notes => _notes;

  final VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  late final GeneratedColumn<DateTime> _createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    defaultValue: const CurrentDateAndTime(),
  );
  @override
  GeneratedColumn<DateTime> get createdAt => _createdAt;

  @override
  List<GeneratedColumn> get $columns =>
      [id, title, content, type, remindAt, isDone, notes, createdAt];

  @override
  String get aliasedName => _alias ?? 'deferred_items';

  @override
  String get actualTableName => 'deferred_items';

  @override
  VerificationContext validateIntegrity(Insertable<DeferredItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('remind_at')) {
      context.handle(_remindAtMeta,
          remindAt.isAcceptableOrUnknown(data['remind_at']!, _remindAtMeta));
    }
    if (data.containsKey('is_done')) {
      context.handle(_isDoneMeta,
          isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
          _createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};

  @override
  DeferredItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    return DeferredItem.fromData(data, prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $DeferredItemsTable createAlias(String alias) {
    return $DeferredItemsTable(attachedDatabase, alias);
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $DeferredItemsTable deferredItems = $DeferredItemsTable(this);

  @override
  Iterable<TableInfo<Table, dynamic>> get allTables => [deferredItems];
}
