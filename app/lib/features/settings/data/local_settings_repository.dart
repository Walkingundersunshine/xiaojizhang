import 'package:drift/drift.dart';
import 'package:jizhangben/core/database/app_database.dart';
import 'package:jizhangben/features/currencies/domain/currency_definition.dart';
import 'package:jizhangben/features/exchange_rates/domain/scaled_exchange_rate.dart';

final class LocalSettingsRepository {
  const LocalSettingsRepository(this.database);

  final AppDatabase database;

  Stream<String> watchBaseCurrencyCode() {
    final query = database.select(database.appPreferences)
      ..where((row) => row.id.equals(1));
    return query.watchSingle().map((preference) => preference.baseCurrencyCode);
  }

  Future<String> getBaseCurrencyCode() async {
    final preference = await (database.select(
      database.appPreferences,
    )..where((row) => row.id.equals(1))).getSingle();
    return preference.baseCurrencyCode;
  }

  Future<void> setBaseCurrencyCode(String currencyCode) async {
    final currency = SupportedCurrencies.require(currencyCode);
    if (!ExchangeRateRules.isConvertible(currency.code)) {
      throw ArgumentError.value(
        currencyCode,
        'currencyCode',
        'MOP 和 TWD 不能设为本位币',
      );
    }
    final changed =
        await (database.update(
          database.appPreferences,
        )..where((row) => row.id.equals(1))).write(
          AppPreferencesCompanion(
            baseCurrencyCode: Value(currency.code),
            updatedAtUtcMilliseconds: Value(
              DateTime.now().toUtc().millisecondsSinceEpoch,
            ),
          ),
        );
    if (changed == 0) {
      throw StateError('本位币设置不存在');
    }
  }
}
