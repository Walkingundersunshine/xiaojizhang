import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:jizhangben/core/database/app_database.dart';
import 'package:jizhangben/core/storage/app_storage_paths.dart';
import 'package:jizhangben/features/currencies/domain/currency_definition.dart';
import 'package:jizhangben/features/exchange_rates/domain/scaled_exchange_rate.dart';
import 'package:path/path.dart' as p;

typedef RecoveryDirectoryProvider = Future<Directory> Function();

final class BackupFormatException implements Exception {
  const BackupFormatException(this.message);

  final String message;

  @override
  String toString() => '备份文件无效：$message';
}

final class BackupPreview {
  const BackupPreview({
    required this.createdAtUtcMilliseconds,
    required this.categoryCount,
    required this.expenseCount,
    required this.exchangeRateCount,
    required this.baseCurrencyCode,
  });

  final int createdAtUtcMilliseconds;
  final int categoryCount;
  final int expenseCount;
  final int exchangeRateCount;
  final String baseCurrencyCode;
}

final class RestoreResult {
  const RestoreResult({
    required this.preview,
    required this.recoveryBackupPath,
  });

  final BackupPreview preview;
  final String recoveryBackupPath;
}

final class DataManagementService {
  DataManagementService(
    this.database, {
    RecoveryDirectoryProvider? recoveryDirectoryProvider,
  }) : _recoveryDirectoryProvider =
           recoveryDirectoryProvider ?? _defaultRecoveryDirectory;

  static const backupFormat = 'jizhang-backup';
  static const backupFormatVersion = 1;
  static const maximumBackupBytes = 100 * 1024 * 1024;

  final AppDatabase database;
  final RecoveryDirectoryProvider _recoveryDirectoryProvider;

  Future<String> createCsv() async {
    final expenses =
        await (database.select(database.expenses)..orderBy([
              (row) => OrderingTerm.asc(row.occurredAtUtcMilliseconds),
              (row) => OrderingTerm.asc(row.id),
            ]))
            .get();
    final categories = await database.select(database.categories).get();
    final byId = {for (final category in categories) category.id: category};
    const headers = [
      'expense_id',
      'amount_minor',
      'currency_code',
      'parent_category_id',
      'parent_category_name',
      'category_id',
      'category_name',
      'occurred_at_utc_milliseconds',
      'occurred_timezone_offset_minutes',
      'note',
      'created_at_utc_milliseconds',
      'updated_at_utc_milliseconds',
    ];
    final buffer = StringBuffer('\ufeff${headers.join(',')}\r\n');
    for (final expense in expenses) {
      final category = byId[expense.categoryId];
      final parent = category == null ? null : byId[category.parentId];
      if (category == null || parent == null) {
        throw StateError('花销 ${expense.id} 的分类关系不完整，无法导出');
      }
      buffer
        ..writeAll([
          _csvNumber(expense.id),
          _csvNumber(expense.amountMinor),
          _csvText(expense.currencyCode),
          _csvText(parent.id),
          _csvText(parent.name),
          _csvText(category.id),
          _csvText(category.name),
          _csvNumber(expense.occurredAtUtcMilliseconds),
          _csvNumber(expense.occurredTimezoneOffsetMinutes),
          _csvText(expense.note ?? ''),
          _csvNumber(expense.createdAtUtcMilliseconds),
          _csvNumber(expense.updatedAtUtcMilliseconds),
        ], ',')
        ..write('\r\n');
    }
    return buffer.toString();
  }

  Future<String> createBackupJson() async {
    final document = await database.transaction(() async {
      final categories =
          await (database.select(database.categories)..orderBy([
                (row) => OrderingTerm.asc(row.parentId),
                (row) => OrderingTerm.asc(row.sortOrder),
                (row) => OrderingTerm.asc(row.id),
              ]))
              .get();
      final expenses = await (database.select(
        database.expenses,
      )..orderBy([(row) => OrderingTerm.asc(row.id)])).get();
      final rates =
          await (database.select(database.exchangeRates)..orderBy([
                (row) => OrderingTerm.asc(row.requestedDate),
                (row) => OrderingTerm.asc(row.baseCurrencyCode),
                (row) => OrderingTerm.asc(row.quoteCurrencyCode),
              ]))
              .get();
      final preferences = await (database.select(
        database.appPreferences,
      )..orderBy([(row) => OrderingTerm.asc(row.id)])).get();
      return <String, Object?>{
        'format': backupFormat,
        'format_version': backupFormatVersion,
        'created_at_utc_milliseconds': DateTime.now()
            .toUtc()
            .millisecondsSinceEpoch,
        'database_schema_version': database.schemaVersion,
        'data': <String, Object?>{
          'categories': [
            for (final row in categories)
              <String, Object?>{
                'id': row.id,
                'parent_id': row.parentId,
                'name': row.name,
                'sort_order': row.sortOrder,
                'is_system': row.isSystem,
                'is_active': row.isActive,
              },
          ],
          'expenses': [
            for (final row in expenses)
              <String, Object?>{
                'id': row.id,
                'amount_minor': row.amountMinor,
                'currency_code': row.currencyCode,
                'category_id': row.categoryId,
                'occurred_at_utc_milliseconds': row.occurredAtUtcMilliseconds,
                'occurred_timezone_offset_minutes':
                    row.occurredTimezoneOffsetMinutes,
                'note': row.note,
                'created_at_utc_milliseconds': row.createdAtUtcMilliseconds,
                'updated_at_utc_milliseconds': row.updatedAtUtcMilliseconds,
              },
          ],
          'exchange_rates': [
            for (final row in rates)
              <String, Object?>{
                'requested_date': row.requestedDate,
                'source_date': row.sourceDate,
                'base_currency_code': row.baseCurrencyCode,
                'quote_currency_code': row.quoteCurrencyCode,
                'scaled_rate': row.scaledRate,
                'fetched_at_utc_milliseconds': row.fetchedAtUtcMilliseconds,
              },
          ],
          'preferences': [
            for (final row in preferences)
              <String, Object?>{
                'id': row.id,
                'base_currency_code': row.baseCurrencyCode,
                'updated_at_utc_milliseconds': row.updatedAtUtcMilliseconds,
              },
          ],
        },
      };
    });
    return '${const JsonEncoder.withIndent('  ').convert(document)}\n';
  }

  BackupPreview inspectBackupJson(String source) =>
      _parseAndValidate(source).preview;

  Future<RestoreResult> restoreFromJson(String source) async {
    final backup = _parseAndValidate(source);
    final currentBackup = await createBackupJson();
    final recoveryPath = await _writeRecoveryBackup(currentBackup);

    await database.transaction(() async {
      await database.delete(database.expenses).go();
      await database.delete(database.exchangeRates).go();
      await database.delete(database.appPreferences).go();
      await (database.delete(
        database.categories,
      )..where((row) => row.parentId.isNotNull())).go();
      await (database.delete(
        database.categories,
      )..where((row) => row.parentId.isNull())).go();

      await database.batch((batch) {
        for (final row in backup.categories.where(
          (category) => category.parentId == null,
        )) {
          batch.insert(database.categories, row.toCompanion());
        }
        for (final row in backup.categories.where(
          (category) => category.parentId != null,
        )) {
          batch.insert(database.categories, row.toCompanion());
        }
        for (final row in backup.expenses) {
          batch.insert(database.expenses, row.toCompanion());
        }
        for (final row in backup.exchangeRates) {
          batch.insert(database.exchangeRates, row.toCompanion());
        }
        for (final row in backup.preferences) {
          batch.insert(database.appPreferences, row.toCompanion());
        }
      });
    });

    return RestoreResult(
      preview: backup.preview,
      recoveryBackupPath: recoveryPath,
    );
  }

  Future<RestoreResult> restoreFromFile(File file) async {
    final length = await file.length();
    if (length > maximumBackupBytes) {
      throw const BackupFormatException('文件超过 100 MB 上限');
    }
    return restoreFromJson(await file.readAsString());
  }

  Future<String> _writeRecoveryBackup(String source) async {
    final directory = await _recoveryDirectoryProvider();
    await directory.create(recursive: true);
    final stamp = _fileTimestamp(DateTime.now().toUtc());
    final destination = File(
      p.join(directory.path, 'before-restore-$stamp.jizhang'),
    );
    final temporary = File('${destination.path}.tmp');
    await temporary.writeAsString(source, encoding: utf8, flush: true);
    if (await destination.exists()) {
      await destination.delete();
    }
    await temporary.rename(destination.path);
    return destination.path;
  }

  _ValidatedBackup _parseAndValidate(String source) {
    if (utf8.encode(source).length > maximumBackupBytes) {
      throw const BackupFormatException('文件超过 100 MB 上限');
    }
    Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw BackupFormatException('JSON 无法解析：${error.message}');
    }
    final root = _map(decoded, '根对象');
    if (_string(root['format'], 'format') != backupFormat) {
      throw const BackupFormatException('format 不是 jizhang-backup');
    }
    final version = _integer(root['format_version'], 'format_version');
    if (version != backupFormatVersion) {
      throw BackupFormatException('不支持 format_version=$version');
    }
    final createdAt = _int64(
      root['created_at_utc_milliseconds'],
      'created_at_utc_milliseconds',
    );
    final schemaVersion = _integer(
      root['database_schema_version'],
      'database_schema_version',
    );
    if (schemaVersion < 1 || schemaVersion > database.schemaVersion) {
      throw BackupFormatException('不支持 database_schema_version=$schemaVersion');
    }
    final data = _map(root['data'], 'data');
    final categories = _list(data['categories'], 'data.categories').indexed
        .map((entry) => _CategoryBackup.parse(entry.$2, entry.$1))
        .toList(growable: false);
    final expenses = _list(data['expenses'], 'data.expenses').indexed
        .map((entry) => _ExpenseBackup.parse(entry.$2, entry.$1))
        .toList(growable: false);
    final exchangeRates = _list(data['exchange_rates'], 'data.exchange_rates')
        .indexed
        .map((entry) => _RateBackup.parse(entry.$2, entry.$1))
        .toList(growable: false);
    final preferences = _list(data['preferences'], 'data.preferences').indexed
        .map((entry) => _PreferenceBackup.parse(entry.$2, entry.$1))
        .toList(growable: false);

    _validateRelations(categories, expenses, exchangeRates, preferences);
    return _ValidatedBackup(
      preview: BackupPreview(
        createdAtUtcMilliseconds: createdAt,
        categoryCount: categories.length,
        expenseCount: expenses.length,
        exchangeRateCount: exchangeRates.length,
        baseCurrencyCode: preferences.single.baseCurrencyCode,
      ),
      categories: categories,
      expenses: expenses,
      exchangeRates: exchangeRates,
      preferences: preferences,
    );
  }

  void _validateRelations(
    List<_CategoryBackup> categories,
    List<_ExpenseBackup> expenses,
    List<_RateBackup> rates,
    List<_PreferenceBackup> preferences,
  ) {
    if (categories.isEmpty) {
      throw const BackupFormatException('分类列表不能为空');
    }
    final byId = <String, _CategoryBackup>{};
    final siblingNames = <String>{};
    for (final category in categories) {
      if (byId.putIfAbsent(category.id, () => category) != category) {
        throw BackupFormatException('分类 ID 重复：${category.id}');
      }
      final siblingKey =
          '${category.parentId ?? '<root>'}\u0000${category.name.toLowerCase()}';
      if (!siblingNames.add(siblingKey)) {
        throw BackupFormatException('同一级分类名称重复：${category.name}');
      }
    }
    for (final category in categories) {
      if (category.parentId == null) continue;
      final parent = byId[category.parentId];
      if (parent == null) {
        throw BackupFormatException('分类 ${category.id} 的一级分类不存在');
      }
      if (parent.parentId != null) {
        throw BackupFormatException('分类 ${category.id} 超过两级');
      }
    }
    final expenseIds = <int>{};
    for (final expense in expenses) {
      if (!expenseIds.add(expense.id)) {
        throw BackupFormatException('花销 ID 重复：${expense.id}');
      }
      final category = byId[expense.categoryId];
      if (category == null || category.parentId == null) {
        throw BackupFormatException('花销 ${expense.id} 未关联有效二级分类');
      }
    }
    final rateKeys = <String>{};
    for (final rate in rates) {
      final key =
          '${rate.requestedDate}\u0000${rate.baseCurrencyCode}\u0000${rate.quoteCurrencyCode}';
      if (!rateKeys.add(key)) {
        throw BackupFormatException('汇率记录重复：${rate.requestedDate}');
      }
    }
    if (preferences.length != 1 || preferences.single.id != 1) {
      throw const BackupFormatException('本位币设置必须且只能包含 id=1 的一条记录');
    }
  }

  static Future<Directory> _defaultRecoveryDirectory() async {
    final support = await getStableApplicationSupportDirectory();
    return Directory(p.join(support.path, 'recovery-backups'));
  }
}

final class _ValidatedBackup {
  const _ValidatedBackup({
    required this.preview,
    required this.categories,
    required this.expenses,
    required this.exchangeRates,
    required this.preferences,
  });

  final BackupPreview preview;
  final List<_CategoryBackup> categories;
  final List<_ExpenseBackup> expenses;
  final List<_RateBackup> exchangeRates;
  final List<_PreferenceBackup> preferences;
}

final class _CategoryBackup {
  const _CategoryBackup({
    required this.id,
    required this.parentId,
    required this.name,
    required this.sortOrder,
    required this.isSystem,
    required this.isActive,
  });

  factory _CategoryBackup.parse(Object? value, int index) {
    final path = 'data.categories[$index]';
    final map = _map(value, path);
    return _CategoryBackup(
      id: _boundedString(map['id'], '$path.id', 200),
      parentId: _nullableBoundedString(
        map['parent_id'],
        '$path.parent_id',
        200,
      ),
      name: _boundedString(map['name'], '$path.name', 40),
      sortOrder: _nonNegativeInteger(map['sort_order'], '$path.sort_order'),
      isSystem: _boolean(map['is_system'], '$path.is_system'),
      isActive: _boolean(map['is_active'], '$path.is_active'),
    );
  }

  final String id;
  final String? parentId;
  final String name;
  final int sortOrder;
  final bool isSystem;
  final bool isActive;

  CategoriesCompanion toCompanion() => CategoriesCompanion.insert(
    id: id,
    parentId: Value(parentId),
    name: name,
    sortOrder: sortOrder,
    isSystem: Value(isSystem),
    isActive: Value(isActive),
  );
}

final class _ExpenseBackup {
  const _ExpenseBackup({
    required this.id,
    required this.amountMinor,
    required this.currencyCode,
    required this.categoryId,
    required this.occurredAtUtcMilliseconds,
    required this.occurredTimezoneOffsetMinutes,
    required this.note,
    required this.createdAtUtcMilliseconds,
    required this.updatedAtUtcMilliseconds,
  });

  factory _ExpenseBackup.parse(Object? value, int index) {
    final path = 'data.expenses[$index]';
    final map = _map(value, path);
    final currency = _currency(map['currency_code'], '$path.currency_code');
    final offset = _integer(
      map['occurred_timezone_offset_minutes'],
      '$path.occurred_timezone_offset_minutes',
    );
    if (offset < -840 || offset > 840) {
      throw BackupFormatException(
        '$path.occurred_timezone_offset_minutes 超出 -840 至 840',
      );
    }
    return _ExpenseBackup(
      id: _positiveInteger(map['id'], '$path.id'),
      amountMinor: _positiveInt64(map['amount_minor'], '$path.amount_minor'),
      currencyCode: currency,
      categoryId: _boundedString(map['category_id'], '$path.category_id', 200),
      occurredAtUtcMilliseconds: _int64(
        map['occurred_at_utc_milliseconds'],
        '$path.occurred_at_utc_milliseconds',
      ),
      occurredTimezoneOffsetMinutes: offset,
      note: _nullableBoundedString(map['note'], '$path.note', 500),
      createdAtUtcMilliseconds: _int64(
        map['created_at_utc_milliseconds'],
        '$path.created_at_utc_milliseconds',
      ),
      updatedAtUtcMilliseconds: _int64(
        map['updated_at_utc_milliseconds'],
        '$path.updated_at_utc_milliseconds',
      ),
    );
  }

  final int id;
  final int amountMinor;
  final String currencyCode;
  final String categoryId;
  final int occurredAtUtcMilliseconds;
  final int occurredTimezoneOffsetMinutes;
  final String? note;
  final int createdAtUtcMilliseconds;
  final int updatedAtUtcMilliseconds;

  ExpensesCompanion toCompanion() => ExpensesCompanion.insert(
    id: Value(id),
    amountMinor: amountMinor,
    currencyCode: currencyCode,
    categoryId: categoryId,
    occurredAtUtcMilliseconds: occurredAtUtcMilliseconds,
    occurredTimezoneOffsetMinutes: occurredTimezoneOffsetMinutes,
    note: Value(note),
    createdAtUtcMilliseconds: createdAtUtcMilliseconds,
    updatedAtUtcMilliseconds: updatedAtUtcMilliseconds,
  );
}

final class _RateBackup {
  const _RateBackup({
    required this.requestedDate,
    required this.sourceDate,
    required this.baseCurrencyCode,
    required this.quoteCurrencyCode,
    required this.scaledRate,
    required this.fetchedAtUtcMilliseconds,
  });

  factory _RateBackup.parse(Object? value, int index) {
    final path = 'data.exchange_rates[$index]';
    final map = _map(value, path);
    return _RateBackup(
      requestedDate: _date(map['requested_date'], '$path.requested_date'),
      sourceDate: _date(map['source_date'], '$path.source_date'),
      baseCurrencyCode: _convertibleCurrency(
        map['base_currency_code'],
        '$path.base_currency_code',
      ),
      quoteCurrencyCode: _convertibleCurrency(
        map['quote_currency_code'],
        '$path.quote_currency_code',
      ),
      scaledRate: _positiveInt64(map['scaled_rate'], '$path.scaled_rate'),
      fetchedAtUtcMilliseconds: _int64(
        map['fetched_at_utc_milliseconds'],
        '$path.fetched_at_utc_milliseconds',
      ),
    );
  }

  final String requestedDate;
  final String sourceDate;
  final String baseCurrencyCode;
  final String quoteCurrencyCode;
  final int scaledRate;
  final int fetchedAtUtcMilliseconds;

  ExchangeRatesCompanion toCompanion() => ExchangeRatesCompanion.insert(
    requestedDate: requestedDate,
    sourceDate: sourceDate,
    baseCurrencyCode: baseCurrencyCode,
    quoteCurrencyCode: quoteCurrencyCode,
    scaledRate: scaledRate,
    fetchedAtUtcMilliseconds: fetchedAtUtcMilliseconds,
  );
}

final class _PreferenceBackup {
  const _PreferenceBackup({
    required this.id,
    required this.baseCurrencyCode,
    required this.updatedAtUtcMilliseconds,
  });

  factory _PreferenceBackup.parse(Object? value, int index) {
    final path = 'data.preferences[$index]';
    final map = _map(value, path);
    return _PreferenceBackup(
      id: _positiveInteger(map['id'], '$path.id'),
      baseCurrencyCode: _convertibleCurrency(
        map['base_currency_code'],
        '$path.base_currency_code',
      ),
      updatedAtUtcMilliseconds: _int64(
        map['updated_at_utc_milliseconds'],
        '$path.updated_at_utc_milliseconds',
      ),
    );
  }

  final int id;
  final String baseCurrencyCode;
  final int updatedAtUtcMilliseconds;

  AppPreferencesCompanion toCompanion() => AppPreferencesCompanion.insert(
    id: Value(id),
    baseCurrencyCode: baseCurrencyCode,
    updatedAtUtcMilliseconds: updatedAtUtcMilliseconds,
  );
}

Map<String, Object?> _map(Object? value, String path) {
  if (value is! Map<String, Object?>) {
    throw BackupFormatException('$path 必须是对象');
  }
  return value;
}

List<Object?> _list(Object? value, String path) {
  if (value is! List<Object?>) {
    throw BackupFormatException('$path 必须是数组');
  }
  return value;
}

String _string(Object? value, String path) {
  if (value is! String) throw BackupFormatException('$path 必须是字符串');
  return value;
}

String _boundedString(Object? value, String path, int maximumLength) {
  final result = _string(value, path);
  if (result.isEmpty || result.length > maximumLength) {
    throw BackupFormatException('$path 长度必须为 1 至 $maximumLength');
  }
  return result;
}

String? _nullableBoundedString(Object? value, String path, int maximumLength) {
  if (value == null) return null;
  final result = _string(value, path);
  if (result.length > maximumLength) {
    throw BackupFormatException('$path 长度不能超过 $maximumLength');
  }
  return result;
}

int _integer(Object? value, String path) {
  if (value is! int) throw BackupFormatException('$path 必须是整数');
  return value;
}

int _nonNegativeInteger(Object? value, String path) {
  final result = _integer(value, path);
  if (result < 0) throw BackupFormatException('$path 不能为负数');
  return result;
}

int _positiveInteger(Object? value, String path) {
  final result = _integer(value, path);
  if (result <= 0) throw BackupFormatException('$path 必须大于 0');
  return result;
}

int _int64(Object? value, String path) {
  final result = _integer(value, path);
  if (result < -9223372036854775808 || result > 9223372036854775807) {
    throw BackupFormatException('$path 超出 64 位整数范围');
  }
  return result;
}

int _positiveInt64(Object? value, String path) {
  final result = _int64(value, path);
  if (result <= 0) throw BackupFormatException('$path 必须大于 0');
  return result;
}

bool _boolean(Object? value, String path) {
  if (value is! bool) throw BackupFormatException('$path 必须是布尔值');
  return value;
}

String _currency(Object? value, String path) {
  final code = _string(value, path);
  try {
    return SupportedCurrencies.require(code).code;
  } on ArgumentError {
    throw BackupFormatException('$path 包含不支持的货币：$code');
  }
}

String _convertibleCurrency(Object? value, String path) {
  final code = _currency(value, path);
  if (!ExchangeRateRules.isConvertible(code)) {
    throw BackupFormatException('$path 包含不可换算货币：$code');
  }
  return code;
}

String _date(Object? value, String path) {
  final result = _string(value, path);
  final match = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(result);
  final parsed = DateTime.tryParse(result);
  if (!match || parsed == null || _dateText(parsed) != result) {
    throw BackupFormatException('$path 不是有效的 YYYY-MM-DD 日期');
  }
  return result;
}

String _dateText(DateTime value) {
  String two(int number) => number.toString().padLeft(2, '0');
  return '${value.year.toString().padLeft(4, '0')}-${two(value.month)}-${two(value.day)}';
}

String _csvNumber(int value) => value.toString();

String _csvText(String value) {
  var safe = value;
  if (safe.isNotEmpty && '=+-@\t\r'.contains(safe[0])) {
    safe = "'$safe";
  }
  if (safe.contains(',') ||
      safe.contains('"') ||
      safe.contains('\r') ||
      safe.contains('\n')) {
    return '"${safe.replaceAll('"', '""')}"';
  }
  return safe;
}

String _fileTimestamp(DateTime value) {
  String two(int number) => number.toString().padLeft(2, '0');
  String three(int number) => number.toString().padLeft(3, '0');
  return '${value.year}${two(value.month)}${two(value.day)}-'
      '${two(value.hour)}${two(value.minute)}${two(value.second)}-'
      '${three(value.millisecond)}';
}
