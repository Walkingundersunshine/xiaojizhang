import 'package:jizhangben/features/exchange_rates/data/local_exchange_rate_repository.dart';
import 'package:jizhangben/features/exchange_rates/domain/scaled_exchange_rate.dart';
import 'package:jizhangben/features/expenses/data/local_expense_repository.dart';

final class CategoryStatistic {
  const CategoryStatistic({
    required this.categoryId,
    required this.categoryName,
    required this.amountMinor,
  });

  final String categoryId;
  final String categoryName;
  final int amountMinor;
}

final class StatisticsSummary {
  const StatisticsSummary({
    required this.expenseCount,
    required this.baseCurrencyCode,
    required this.convertedTotalMinor,
    required this.originalTotalsMinor,
    required this.categoryStatistics,
    required this.rateSourceDates,
    required this.failedRateDates,
  });

  final int expenseCount;
  final String baseCurrencyCode;
  final int? convertedTotalMinor;
  final Map<String, int> originalTotalsMinor;
  final List<CategoryStatistic> categoryStatistics;
  final Set<String> rateSourceDates;
  final Set<String> failedRateDates;
}

final class StatisticsService {
  const StatisticsService(this.exchangeRates);

  final LocalExchangeRateRepository exchangeRates;

  Future<StatisticsSummary> calculate({
    required List<ExpenseListItem> expenses,
    required String baseCurrencyCode,
  }) async {
    final originalTotals = <String, int>{};
    final datesNeedingRates = <String, DateTime>{};
    for (final item in expenses) {
      final code = item.expense.currencyCode;
      originalTotals.update(
        code,
        (value) => value + item.expense.amountMinor,
        ifAbsent: () => item.expense.amountMinor,
      );
      if (ExchangeRateRules.isConvertible(code) && code != baseCurrencyCode) {
        final local = item.occurrence.localWallClock;
        datesNeedingRates[formatRateDate(local)] = local;
      }
    }

    final snapshots = <String, HistoricalRateSnapshot>{};
    final failedDates = <String>{};
    final entries = datesNeedingRates.entries.toList();
    for (var start = 0; start < entries.length; start += 4) {
      final batch = entries.skip(start).take(4);
      await Future.wait([
        for (final entry in batch)
          () async {
            try {
              snapshots[entry.key] = await exchangeRates.getForDate(
                entry.value,
              );
            } catch (_) {
              failedDates.add(entry.key);
            }
          }(),
      ]);
    }

    var convertedTotal = 0;
    final categoryTotals = <String, int>{};
    final categoryNames = <String, String>{};
    final sourceDates = <String>{};
    for (final item in expenses) {
      final sourceCode = item.expense.currencyCode;
      if (!ExchangeRateRules.isConvertible(sourceCode)) continue;
      final int converted;
      if (sourceCode == baseCurrencyCode) {
        converted = item.expense.amountMinor;
      } else {
        final date = formatRateDate(item.occurrence.localWallClock);
        final snapshot = snapshots[date];
        if (snapshot == null) continue;
        sourceDates.add(snapshot.sourceDate);
        converted = exchangeRates.convertMinorUnits(
          amountMinor: item.expense.amountMinor,
          sourceCurrencyCode: sourceCode,
          targetCurrencyCode: baseCurrencyCode,
          snapshot: snapshot,
        );
      }
      convertedTotal += converted;
      categoryTotals.update(
        item.parentCategoryId,
        (value) => value + converted,
        ifAbsent: () => converted,
      );
      categoryNames[item.parentCategoryId] = item.parentCategoryName;
    }

    final categories = [
      for (final entry in categoryTotals.entries)
        CategoryStatistic(
          categoryId: entry.key,
          categoryName: categoryNames[entry.key]!,
          amountMinor: entry.value,
        ),
    ]..sort((a, b) => b.amountMinor.compareTo(a.amountMinor));

    return StatisticsSummary(
      expenseCount: expenses.length,
      baseCurrencyCode: baseCurrencyCode,
      convertedTotalMinor: failedDates.isEmpty ? convertedTotal : null,
      originalTotalsMinor: Map.unmodifiable(originalTotals),
      categoryStatistics: failedDates.isEmpty
          ? List.unmodifiable(categories)
          : const [],
      rateSourceDates: Set.unmodifiable(sourceDates),
      failedRateDates: Set.unmodifiable(failedDates),
    );
  }
}
