import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jizhangben/core/database/app_database.dart';
import 'package:jizhangben/features/settings/data/local_settings_repository.dart';

void main() {
  late AppDatabase database;
  late LocalSettingsRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = LocalSettingsRepository(database);
  });

  tearDown(() => database.close());

  test('首次打开默认本位币为 CNY', () async {
    expect(await repository.getBaseCurrencyCode(), 'CNY');
  });

  test('本位币修改后持久化并拒绝 MOP/TWD', () async {
    await repository.setBaseCurrencyCode('usd');

    expect(await repository.getBaseCurrencyCode(), 'USD');
    expect(() => repository.setBaseCurrencyCode('MOP'), throwsArgumentError);
    expect(() => repository.setBaseCurrencyCode('TWD'), throwsArgumentError);
  });
}
