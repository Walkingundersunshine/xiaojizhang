// ignore_for_file: avoid_print

import 'package:jizhangben/features/exchange_rates/data/frankfurter_exchange_rate_source.dart';

Future<void> main() async {
  final source = FrankfurterExchangeRateSource();
  try {
    final snapshot = await source.fetch('2026-07-29');
    print(
      'requested=${snapshot.requestedDate} source=${snapshot.sourceDate} rates=${snapshot.eurRates.length}',
    );
    print('EUR/CNY scaled=${snapshot.eurRates['CNY']}');
  } finally {
    source.close();
  }
}
