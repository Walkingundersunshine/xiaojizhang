import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:jizhangben/features/categories/domain/default_expense_categories.dart';
import 'package:jizhangben/core/storage/app_storage_paths.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get parentId => text().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.restrict,
  )();
  TextColumn get name => text().withLength(min: 1, max: 40)();
  IntColumn get sortOrder => integer()();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@TableIndex(
  name: 'expenses_occurred_at_utc',
  columns: {#occurredAtUtcMilliseconds},
)
@TableIndex(name: 'expenses_currency_code', columns: {#currencyCode})
@TableIndex(name: 'expenses_category_id', columns: {#categoryId})
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amountMinor => integer()();
  TextColumn get currencyCode => text().withLength(min: 3, max: 3)();
  TextColumn get categoryId =>
      text().references(Categories, #id, onDelete: KeyAction.restrict)();
  IntColumn get occurredAtUtcMilliseconds => integer()();
  IntColumn get occurredTimezoneOffsetMinutes => integer()();
  TextColumn get note => text().withLength(max: 500).nullable()();
  IntColumn get createdAtUtcMilliseconds => integer()();
  IntColumn get updatedAtUtcMilliseconds => integer()();
}

@TableIndex(name: 'exchange_rates_requested_date', columns: {#requestedDate})
class ExchangeRates extends Table {
  TextColumn get requestedDate => text().withLength(min: 10, max: 10)();
  TextColumn get sourceDate => text().withLength(min: 10, max: 10)();
  TextColumn get baseCurrencyCode => text().withLength(min: 3, max: 3)();
  TextColumn get quoteCurrencyCode => text().withLength(min: 3, max: 3)();
  IntColumn get scaledRate => integer()();
  IntColumn get fetchedAtUtcMilliseconds => integer()();

  @override
  Set<Column<Object>> get primaryKey => {
    requestedDate,
    baseCurrencyCode,
    quoteCurrencyCode,
  };
}

class AppPreferences extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get baseCurrencyCode => text().withLength(min: 3, max: 3)();
  IntColumn get updatedAtUtcMilliseconds => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@TableIndex(
  name: 'paired_devices_certificate_sha256',
  columns: {#certificateSha256},
  unique: true,
)
class PairedDevices extends Table {
  TextColumn get deviceId => text().withLength(min: 8, max: 100)();
  TextColumn get displayName => text().withLength(min: 1, max: 60)();
  TextColumn get certificatePem => text().withLength(min: 1, max: 16384)();
  TextColumn get certificateSha256 => text().withLength(min: 64, max: 64)();
  IntColumn get pairedAtUtcMilliseconds => integer()();
  IntColumn get lastSyncAtUtcMilliseconds => integer().nullable()();
  BoolColumn get isRevoked => boolean().withDefault(const Constant(false))();
  IntColumn get revokedAtUtcMilliseconds => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {deviceId};
}

@DriftDatabase(
  tables: [Categories, Expenses, ExchangeRates, AppPreferences, PairedDevices],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  factory AppDatabase.open() => AppDatabase(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(exchangeRates);
      }
      if (from < 3) {
        await migrator.createTable(appPreferences);
      }
      if (from < 4) {
        await migrator.createTable(pairedDevices);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      if (details.wasCreated) {
        await _insertDefaultCategories();
      }
      await _ensureDefaultPreferences();
    },
  );

  Future<void> _insertDefaultCategories() async {
    await batch((batch) {
      for (
        var groupIndex = 0;
        groupIndex < DefaultExpenseCategories.groups.length;
        groupIndex++
      ) {
        final group = DefaultExpenseCategories.groups[groupIndex];
        batch.insert(
          categories,
          CategoriesCompanion.insert(
            id: group.id,
            name: group.name,
            sortOrder: groupIndex,
            isSystem: const Value(true),
          ),
        );
        for (
          var childIndex = 0;
          childIndex < group.children.length;
          childIndex++
        ) {
          final child = group.children[childIndex];
          batch.insert(
            categories,
            CategoriesCompanion.insert(
              id: child.id,
              parentId: Value(group.id),
              name: child.name,
              sortOrder: childIndex,
              isSystem: const Value(true),
            ),
          );
        }
      }
    });
  }

  Future<void> _ensureDefaultPreferences() async {
    await into(appPreferences).insert(
      AppPreferencesCompanion.insert(
        id: const Value(1),
        baseCurrencyCode: 'CNY',
        updatedAtUtcMilliseconds: DateTime.now().toUtc().millisecondsSinceEpoch,
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final supportDirectory = await getStableApplicationSupportDirectory();
    final databaseFile = File(
      p.join(supportDirectory.path, 'jizhangben.sqlite'),
    );
    return NativeDatabase.createInBackground(databaseFile);
  });
}
