import 'package:drift/drift.dart';
import 'package:jizhangben/core/database/app_database.dart';
import 'package:jizhangben/features/exchange_rates/data/frankfurter_exchange_rate_source.dart';
import 'package:jizhangben/features/exchange_rates/domain/scaled_exchange_rate.dart';

final class LocalExchangeRateRepository {
  const LocalExchangeRateRepository(this.database, this.source);

  final AppDatabase database;
  final HistoricalExchangeRateSource source;

  Future<HistoricalRateSnapshot> getForDate(
    DateTime date, {
    bool allowNetwork = true,
  }) async {
    final requestedDate = formatRateDate(date);
    final cached = await findCached(requestedDate);
    if (cached != null) return cached;
    if (!allowNetwork) {
      throw StateError('$requestedDate 没有已缓存汇率，当前不允许联网');
    }

    final fetched = await source.fetch(requestedDate);
    if (fetched.requestedDate != requestedDate) {
      throw StateError('汇率来源返回了错误的请求日期');
    }
    _validateComplete(fetched);
    final fetchedAt = DateTime.now().toUtc().millisecondsSinceEpoch;
    await database.transaction(() async {
      await (database.delete(database.exchangeRates)..where(
            (row) =>
                row.requestedDate.equals(requestedDate) &
                row.baseCurrencyCode.equals('EUR'),
          ))
          .go();
      await database.batch((batch) {
        for (final entry in fetched.eurRates.entries) {
          batch.insert(
            database.exchangeRates,
            ExchangeRatesCompanion.insert(
              requestedDate: requestedDate,
              sourceDate: fetched.sourceDate,
              baseCurrencyCode: 'EUR',
              quoteCurrencyCode: entry.key,
              scaledRate: entry.value,
              fetchedAtUtcMilliseconds: fetchedAt,
            ),
          );
        }
      });
    });
    return fetched;
  }

  Future<HistoricalRateSnapshot?> findCached(String requestedDate) async {
    final rows =
        await (database.select(database.exchangeRates)..where(
              (row) =>
                  row.requestedDate.equals(requestedDate) &
                  row.baseCurrencyCode.equals('EUR'),
            ))
            .get();
    if (rows.isEmpty) return null;
    final sourceDates = rows.map((row) => row.sourceDate).toSet();
    final rates = {
      for (final row in rows) row.quoteCurrencyCode: row.scaledRate,
    };
    if (sourceDates.length != 1 ||
        !rates.keys.toSet().containsAll(
          ExchangeRateRules.convertibleCurrencyCodes,
        )) {
      return null;
    }
    return HistoricalRateSnapshot(
      requestedDate: requestedDate,
      sourceDate: sourceDates.single,
      eurRates: rates,
    );
  }

  int convertMinorUnits({
    required int amountMinor,
    required String sourceCurrencyCode,
    required String targetCurrencyCode,
    required HistoricalRateSnapshot snapshot,
  }) {
    return ExchangeRateRules.convertMinorUnits(
      amountMinor: amountMinor,
      sourceCurrencyCode: sourceCurrencyCode,
      targetCurrencyCode: targetCurrencyCode,
      eurRates: snapshot.eurRates,
    );
  }

  void _validateComplete(HistoricalRateSnapshot snapshot) {
    final missing = ExchangeRateRules.convertibleCurrencyCodes.difference(
      snapshot.eurRates.keys.toSet(),
    );
    if (missing.isNotEmpty ||
        snapshot.eurRates.values.any((rate) => rate <= 0)) {
      throw StateError('汇率数据不完整：缺少 ${missing.join(', ')}');
    }
  }
}
