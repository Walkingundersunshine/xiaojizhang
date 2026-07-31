import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jizhangben/core/database/app_database.dart';
import 'package:jizhangben/features/categories/data/local_category_repository.dart';
import 'package:jizhangben/features/data_management/data/data_management_service.dart';
import 'package:jizhangben/features/expenses/data/local_expense_repository.dart';
import 'package:jizhangben/features/expenses/domain/expense_occurrence.dart';
import 'package:jizhangben/features/settings/data/local_settings_repository.dart';

void main() {
  late AppDatabase database;
  late LocalExpenseRepository expenses;
  late LocalCategoryRepository categories;
  late LocalSettingsRepository settings;
  late Directory recoveryDirectory;
  late DataManagementService service;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    expenses = LocalExpenseRepository(database);
    categories = LocalCategoryRepository(database);
    settings = LocalSettingsRepository(database);
    recoveryDirectory = await Directory.systemTemp.createTemp(
      'jizhang-recovery-test-',
    );
    service = DataManagementService(
      database,
      recoveryDirectoryProvider: () async => recoveryDirectory,
    );
  });

  tearDown(() async {
    await database.close();
    if (await recoveryDirectory.exists()) {
      await recoveryDirectory.delete(recursive: true);
    }
  });

  test('CSV 使用 UTF-8 BOM、固定英文技术字段并安全转义文本', () async {
    final occurred = ExpenseOccurrence.fromStored(
      utcMilliseconds: DateTime.utc(
        2026,
        7,
        30,
        3,
        4,
        5,
      ).millisecondsSinceEpoch,
      timezoneOffsetMinutes: 8 * 60,
    );
    final id = await expenses.create(
      ExpenseDraft(
        amountMinor: 1234,
        currencyCode: 'USD',
        categoryId: 'food.lunch',
        occurrence: occurred,
        note: '=SUM(1,2)\n午餐',
      ),
    );

    final csv = await service.createCsv();

    expect(
      csv.startsWith('\ufeffexpense_id,amount_minor,currency_code,'),
      isTrue,
    );
    expect(csv, contains('$id,1234,USD,food,餐饮,food.lunch,午餐,'));
    expect(csv, contains('${occurred.utcMilliseconds},480,'));
    expect(csv, contains('"\'=SUM(1,2)\n午餐"'));
    expect(csv.endsWith('\r\n'), isTrue);
  });

  test('完整备份可恢复分类、花销、汇率和本位币', () async {
    await settings.setBaseCurrencyCode('USD');
    await _createExpense(
      expenses,
      utc: DateTime.utc(2026, 7, 30, 8),
      categoryId: 'food.lunch',
      note: '原始记录',
    );
    await database
        .into(database.exchangeRates)
        .insert(
          ExchangeRatesCompanion.insert(
            requestedDate: '2026-07-30',
            sourceDate: '2026-07-30',
            baseCurrencyCode: 'EUR',
            quoteCurrencyCode: 'USD',
            scaledRate: 1170000000000,
            fetchedAtUtcMilliseconds: DateTime.utc(
              2026,
              7,
              30,
            ).millisecondsSinceEpoch,
          ),
        );
    final source = await service.createBackupJson();
    final preview = service.inspectBackupJson(source);
    expect(preview.categoryCount, 95);
    expect(preview.expenseCount, 1);
    expect(preview.exchangeRateCount, 1);
    expect(preview.baseCurrencyCode, 'USD');

    await _createExpense(
      expenses,
      utc: DateTime.utc(2026, 7, 30, 9),
      categoryId: 'transport.taxi',
      note: '恢复后应消失',
    );
    await categories.rename(id: 'food', name: '餐饮修改');
    await settings.setBaseCurrencyCode('CNY');

    final result = await service.restoreFromJson(source);

    expect(result.preview.expenseCount, 1);
    expect(File(result.recoveryBackupPath).existsSync(), isTrue);
    final restoredExpenses = await database.select(database.expenses).get();
    expect(restoredExpenses, hasLength(1));
    expect(restoredExpenses.single.note, '原始记录');
    final restoredFood = await (database.select(
      database.categories,
    )..where((row) => row.id.equals('food'))).getSingle();
    expect(restoredFood.name, '餐饮');
    expect(await settings.getBaseCurrencyCode(), 'USD');
    expect(await database.select(database.exchangeRates).get(), hasLength(1));

    final safetySource = await File(result.recoveryBackupPath).readAsString();
    expect(service.inspectBackupJson(safetySource).expenseCount, 2);
  });

  test('完整备份和恢复都不导出或覆盖已配对设备信任', () async {
    await database
        .into(database.pairedDevices)
        .insert(
          PairedDevicesCompanion.insert(
            deviceId: 'android-device-001',
            displayName: '我的手机',
            certificatePem: 'public-certificate-placeholder',
            certificateSha256: List.filled(64, '0').join(),
            pairedAtUtcMilliseconds: DateTime.utc(
              2026,
              8,
              1,
            ).millisecondsSinceEpoch,
          ),
        );

    final source = await service.createBackupJson();
    final decoded = jsonDecode(source) as Map<String, Object?>;
    final data = decoded['data']! as Map<String, Object?>;
    expect(data.containsKey('paired_devices'), isFalse);
    expect(source, isNot(contains('public-certificate-placeholder')));

    await service.restoreFromJson(source);
    final trustedDevices = await database.select(database.pairedDevices).get();
    expect(trustedDevices, hasLength(1));
    expect(trustedDevices.single.deviceId, 'android-device-001');
  });

  test('无效备份在创建安全备份和修改数据库前被拒绝', () async {
    await _createExpense(
      expenses,
      utc: DateTime.utc(2026, 7, 30),
      categoryId: 'food.lunch',
    );
    final decoded =
        jsonDecode(await service.createBackupJson()) as Map<String, Object?>;
    final data = decoded['data']! as Map<String, Object?>;
    final expenseRows = data['expenses']! as List<Object?>;
    final firstExpense = expenseRows.single as Map<String, Object?>;
    firstExpense['category_id'] = 'food';

    expect(
      () => service.restoreFromJson(jsonEncode(decoded)),
      throwsA(isA<BackupFormatException>()),
    );
    expect(await database.select(database.expenses).get(), hasLength(1));
    expect(await recoveryDirectory.list().toList(), isEmpty);
  });

  test('恢复前安全备份写入失败时不替换当前账本', () async {
    await _createExpense(
      expenses,
      utc: DateTime.utc(2026, 7, 30, 10),
      categoryId: 'food.lunch',
    );
    final source = await service.createBackupJson();
    await _createExpense(
      expenses,
      utc: DateTime.utc(2026, 7, 30, 11),
      categoryId: 'transport.taxi',
    );
    final failingService = DataManagementService(
      database,
      recoveryDirectoryProvider: () async =>
          throw const FileSystemException('模拟安全备份目录不可写'),
    );

    expect(
      () => failingService.restoreFromJson(source),
      throwsA(isA<FileSystemException>()),
    );
    expect(await database.select(database.expenses).get(), hasLength(2));
  });
}

Future<int> _createExpense(
  LocalExpenseRepository repository, {
  required DateTime utc,
  required String categoryId,
  String? note,
}) {
  return repository.create(
    ExpenseDraft(
      amountMinor: 100,
      currencyCode: 'CNY',
      categoryId: categoryId,
      occurrence: ExpenseOccurrence.fromStored(
        utcMilliseconds: utc.millisecondsSinceEpoch,
        timezoneOffsetMinutes: 0,
      ),
      note: note,
    ),
  );
}
