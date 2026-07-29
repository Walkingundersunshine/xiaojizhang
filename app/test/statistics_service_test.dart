import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jizhangben/core/database/app_database.dart';
import 'package:jizhangben/features/exchange_rates/data/frankfurter_exchange_rate_source.dart';
import 'package:jizhangben/features/exchange_rates/data/local_exchange_rate_repository.dart';
import 'package:jizhangben/features/exchange_rates/domain/scaled_exchange_rate.dart';
import 'package:jizhangben/features/expenses/data/local_expense_repository.dart';
import 'package:jizhangben/features/expenses/domain/expense_occurrence.dart';
import 'package:jizhangben/features/statistics/data/statistics_service.dart';

void main() {
  late AppDatabase database;
  late LocalExpenseRepository expenses;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    expenses = LocalExpenseRepository(database);
  });

  tearDown(() => database.close());

  test('月度统计按历史汇率折算并保留不可换算原币', () async {
    final occurrence = ExpenseOccurrence.fromLocal(DateTime(2026, 7, 15, 12));
    await expenses.create(
      ExpenseDraft(
        amountMinor: 10000,
        currencyCode: 'CNY',
        categoryId: 'food.lunch',
        occurrence: occurrence,
      ),
    );
    await expenses.create(
      ExpenseDraft(
        amountMinor: 1000,
        currencyCode: 'USD',
        categoryId: 'transport.public',
        occurrence: occurrence,
      ),
    );
    await expenses.create(
      ExpenseDraft(
        amountMinor: 5000,
        currencyCode: 'MOP',
        categoryId: 'transport.public',
        occurrence: occurrence,
      ),
    );
    final items = await expenses
        .watchDetailedInLocalRange(
          startInclusive: DateTime(2026, 7),
          endExclusive: DateTime(2026, 8),
        )
        .first;
    final source = _StatisticsRateSource(_snapshot('2026-07-15'));
    final rates = LocalExchangeRateRepository(database, source);

    final summary = await StatisticsService(
      rates,
    ).calculate(expenses: items, baseCurrencyCode: 'CNY');

    expect(summary.expenseCount, 3);
    expect(summary.convertedTotalMinor, 16667);
    expect(summary.originalTotalsMinor, {
      'CNY': 10000,
      'USD': 1000,
      'MOP': 5000,
    });
    expect(
      summary.categoryStatistics.map((category) => category.amountMinor),
      containsAll([10000, 6667]),
    );
    expect(summary.failedRateDates, isEmpty);
    expect(source.fetchCount, 1);
  });

  test('汇率失败时不显示不完整折算总额', () async {
    final occurrence = ExpenseOccurrence.fromLocal(DateTime(2026, 7, 16, 12));
    await expenses.create(
      ExpenseDraft(
        amountMinor: 1000,
        currencyCode: 'USD',
        categoryId: 'food.lunch',
        occurrence: occurrence,
      ),
    );
    final items = await expenses
        .watchDetailedInLocalRange(
          startInclusive: DateTime(2026, 7),
          endExclusive: DateTime(2026, 8),
        )
        .first;
    final rates = LocalExchangeRateRepository(database, _FailingRateSource());

    final summary = await StatisticsService(
      rates,
    ).calculate(expenses: items, baseCurrencyCode: 'CNY');

    expect(summary.convertedTotalMinor, isNull);
    expect(summary.categoryStatistics, isEmpty);
    expect(summary.failedRateDates, {'2026-07-16'});
  });
}

HistoricalRateSnapshot _snapshot(String date) {
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
  return HistoricalRateSnapshot(
    requestedDate: date,
    sourceDate: date,
    eurRates: {
      for (final entry in decimalRates.entries)
        entry.key: ExchangeRateRules.parseScaledRate(entry.value),
    },
  );
}

final class _StatisticsRateSource implements HistoricalExchangeRateSource {
  _StatisticsRateSource(this.snapshot);

  final HistoricalRateSnapshot snapshot;
  var fetchCount = 0;

  @override
  Future<HistoricalRateSnapshot> fetch(String requestedDate) async {
    fetchCount++;
    return snapshot;
  }
}

final class _FailingRateSource implements HistoricalExchangeRateSource {
  @override
  Future<HistoricalRateSnapshot> fetch(String requestedDate) {
    throw const SocketExceptionForTest();
  }
}

final class SocketExceptionForTest implements Exception {
  const SocketExceptionForTest();
}
