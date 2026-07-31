import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jizhangben/core/database/app_database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test('schema v3 升级到 v4 时新增已配对设备表且不修改原设置', () async {
    final directory = await Directory.systemTemp.createTemp(
      'xiaojizhang-schema-migration-',
    );
    final file = File(
      '${directory.path}${Platform.pathSeparator}ledger.sqlite',
    );
    final raw = sqlite.sqlite3.open(file.path);
    raw
      ..execute('''
        CREATE TABLE app_preferences (
          id INTEGER NOT NULL DEFAULT 1 PRIMARY KEY,
          base_currency_code TEXT NOT NULL,
          updated_at_utc_milliseconds INTEGER NOT NULL
        )
      ''')
      ..execute("INSERT INTO app_preferences VALUES (1, 'USD', 123456789)")
      ..userVersion = 3;
    raw.close();

    final database = AppDatabase(NativeDatabase(file));
    try {
      expect(await database.select(database.pairedDevices).get(), isEmpty);
      final preferences = await database.select(database.appPreferences).get();
      expect(preferences, hasLength(1));
      expect(preferences.single.baseCurrencyCode, 'USD');
      final versions = await database.customSelect('PRAGMA user_version').get();
      expect(versions, hasLength(1));
      expect(versions.single.read<int>('user_version'), 4);
    } finally {
      await database.close();
      await directory.delete(recursive: true);
    }
  });
}
