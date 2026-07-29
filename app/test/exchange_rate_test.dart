import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jizhangben/core/database/app_database.dart';
import 'package:jizhangben/features/exchange_rates/data/frankfurter_exchange_rate_source.dart';
import 'package:jizhangben/features/exchange_rates/data/local_exchange_rate_repository.dart';
import 'package:jizhangben/features/exchange_rates/domain/scaled_exchange_rate.dart';

void main() {
  test('汇率按 12 位小数精确缩放并支持科学计数法', () {
    expect(ExchangeRateRules.parseScaledRate('7.812345'), 7812345000000);
    expect(ExchangeRateRules.parseScaledRate('1.2345678901234'), 1234567890123);
    expect(ExchangeRateRules.parseScaledRate('1.2e3'), 1200000000000000);
  });

  test('跨币种换算只在目标最小单位四舍五入一次', () {
    final rates = _completeRates();

    final converted = ExchangeRateRules.convertMinorUnits(
      amountMinor: 10000,
      sourceCurrencyCode: 'CNY',
      targetCurrencyCode: 'USD',
      eurRates: rates,
    );

    expect(converted, 1500);
    expect(
      () => ExchangeRateRules.convertMinorUnits(
        amountMinor: 10000,
        sourceCurrencyCode: 'MOP',
        targetCurrencyCode: 'CNY',
        eurRates: rates,
      ),
      throwsArgumentError,
    );
  });

  test('历史汇率按请求日期缓存并保留实际工作日', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final source = _FakeRateSource(
      HistoricalRateSnapshot(
        requestedDate: '2026-07-26',
        sourceDate: '2026-07-24',
        eurRates: _completeRates(),
      ),
    );
    final repository = LocalExchangeRateRepository(database, source);
    addTearDown(database.close);

    final first = await repository.getForDate(DateTime(2026, 7, 26));
    final second = await repository.getForDate(DateTime(2026, 7, 26));
    final rows = await database.select(database.exchangeRates).get();

    expect(source.fetchCount, 1);
    expect(first.sourceDate, '2026-07-24');
    expect(second.sourceDate, '2026-07-24');
    expect(rows, hasLength(10));
  });
}

Map<String, int> _completeRates() {
  const decimalRates = <String, String>{
    'EUR': '1',
    'CNY': '8',
    'USD': '1.2',
    'GBP': '0.8',
    'JPY': '160',
    'HKD': '9',
    'SGD': '1.5',
    'AUD': '1.7',
    'CAD': '1.6',
    'KRW': '1500',
  };
  return {
    for (final entry in decimalRates.entries)
      entry.key: ExchangeRateRules.parseScaledRate(entry.value),
  };
}

final class _FakeRateSource implements HistoricalExchangeRateSource {
  _FakeRateSource(this.snapshot);

  final HistoricalRateSnapshot snapshot;
  var fetchCount = 0;

  @override
  Future<HistoricalRateSnapshot> fetch(String requestedDate) async {
    fetchCount++;
    return snapshot;
  }
}
