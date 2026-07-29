import 'dart:convert';
import 'dart:io';

import 'package:jizhangben/features/exchange_rates/domain/scaled_exchange_rate.dart';

abstract interface class HistoricalExchangeRateSource {
  Future<HistoricalRateSnapshot> fetch(String requestedDate);
}

final class FrankfurterExchangeRateSource
    implements HistoricalExchangeRateSource {
  FrankfurterExchangeRateSource({HttpClient? client})
    : _client = client ?? HttpClient();

  final HttpClient _client;

  @override
  Future<HistoricalRateSnapshot> fetch(String requestedDate) async {
    final quotes = ExchangeRateRules.convertibleCurrencyCodes
        .where((code) => code != 'EUR')
        .join(',');
    final uri = Uri.https('api.frankfurter.dev', '/v1/$requestedDate', {
      'base': 'EUR',
      'symbols': quotes,
    });

    final request = await _client
        .getUrl(uri)
        .timeout(const Duration(seconds: 12));
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    final response = await request.close().timeout(const Duration(seconds: 12));
    final body = await utf8.decoder
        .bind(response)
        .join()
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('汇率网站返回 ${response.statusCode}', uri: uri);
    }
    return parseResponse(requestedDate: requestedDate, body: body);
  }

  HistoricalRateSnapshot parseResponse({
    required String requestedDate,
    required String body,
  }) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('汇率响应不是 JSON 对象');
    }
    if (decoded['base'] != 'EUR') {
      throw const FormatException('汇率响应基准货币不是 EUR');
    }
    final sourceDate = decoded['date'];
    if (sourceDate is! String || !_isValidDate(sourceDate)) {
      throw const FormatException('汇率响应缺少有效日期');
    }
    final requested = DateTime.tryParse(requestedDate);
    final actual = DateTime.tryParse(sourceDate);
    if (requested == null || actual == null || actual.isAfter(requested)) {
      throw const FormatException('汇率实际日期晚于请求日期');
    }

    final rawRates = decoded['rates'];
    if (rawRates is! Map<String, Object?>) {
      throw const FormatException('汇率响应缺少 rates');
    }
    final rates = <String, int>{'EUR': ExchangeRateRules.scale};
    for (final code in ExchangeRateRules.convertibleCurrencyCodes.where(
      (code) => code != 'EUR',
    )) {
      final raw = rawRates[code];
      if (raw is! num || !raw.isFinite || raw <= 0) {
        throw FormatException('汇率响应缺少 $code');
      }
      rates[code] = ExchangeRateRules.parseScaledRate(raw.toString());
    }
    return HistoricalRateSnapshot(
      requestedDate: requestedDate,
      sourceDate: sourceDate,
      eurRates: rates,
    );
  }

  bool _isValidDate(String value) {
    return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value) &&
        DateTime.tryParse(value) != null;
  }

  void close() => _client.close(force: true);
}
