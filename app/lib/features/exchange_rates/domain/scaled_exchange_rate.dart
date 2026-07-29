import 'package:jizhangben/features/currencies/domain/currency_definition.dart';

abstract final class ExchangeRateRules {
  static const scale = 1000000000000;
  static final BigInt _maxSqliteInteger = BigInt.from(9223372036854775807);

  static const convertibleCurrencyCodes = <String>{
    'EUR',
    'CNY',
    'USD',
    'GBP',
    'JPY',
    'HKD',
    'SGD',
    'AUD',
    'CAD',
    'KRW',
  };

  static const nonConvertibleCurrencyCodes = <String>{'MOP', 'TWD'};

  static bool isConvertible(String currencyCode) {
    return convertibleCurrencyCodes.contains(currencyCode.toUpperCase());
  }

  static int parseScaledRate(String decimal) {
    final normalized = decimal.trim();
    final match = RegExp(
      r'^(\d+)(?:\.(\d+))?(?:[eE]([+-]?\d+))?$',
    ).firstMatch(normalized);
    if (match == null) {
      throw FormatException('无效汇率：$decimal');
    }

    final fraction = match.group(2) ?? '';
    final exponent = int.tryParse(match.group(3) ?? '0');
    if (exponent == null) {
      throw FormatException('无效汇率指数：$decimal');
    }
    final digits = BigInt.parse('${match.group(1)}$fraction');
    final power = 12 + exponent - fraction.length;
    final BigInt scaled;
    if (power >= 0) {
      scaled = digits * BigInt.from(10).pow(power);
    } else {
      final divisor = BigInt.from(10).pow(-power);
      scaled = (digits + divisor ~/ BigInt.two) ~/ divisor;
    }

    if (scaled <= BigInt.zero || scaled > _maxSqliteInteger) {
      throw FormatException('汇率超出可保存范围：$decimal');
    }
    return scaled.toInt();
  }

  static int convertMinorUnits({
    required int amountMinor,
    required String sourceCurrencyCode,
    required String targetCurrencyCode,
    required Map<String, int> eurRates,
  }) {
    if (amountMinor < 0) {
      throw ArgumentError.value(amountMinor, 'amountMinor', '金额不能为负数');
    }
    final source = sourceCurrencyCode.toUpperCase();
    final target = targetCurrencyCode.toUpperCase();
    if (source == target) return amountMinor;
    if (!isConvertible(source) || !isConvertible(target)) {
      throw ArgumentError('MOP 和 TWD 不支持跨币种换算');
    }

    final sourceRate = eurRates[source];
    final targetRate = eurRates[target];
    if (sourceRate == null ||
        targetRate == null ||
        sourceRate <= 0 ||
        targetRate <= 0) {
      throw StateError('缺少 $source 或 $target 的有效汇率');
    }
    final sourceDigits = SupportedCurrencies.require(source).minorUnitDigits;
    final targetDigits = SupportedCurrencies.require(target).minorUnitDigits;
    final numerator =
        BigInt.from(amountMinor) *
        BigInt.from(targetRate) *
        BigInt.from(10).pow(targetDigits);
    final denominator =
        BigInt.from(sourceRate) * BigInt.from(10).pow(sourceDigits);
    final rounded = (numerator + denominator ~/ BigInt.two) ~/ denominator;
    if (rounded > _maxSqliteInteger) {
      throw StateError('换算结果超出可保存范围');
    }
    return rounded.toInt();
  }
}

final class HistoricalRateSnapshot {
  HistoricalRateSnapshot({
    required this.requestedDate,
    required this.sourceDate,
    required Map<String, int> eurRates,
  }) : eurRates = Map.unmodifiable(eurRates);

  final String requestedDate;
  final String sourceDate;
  final Map<String, int> eurRates;
}

String formatRateDate(DateTime date) {
  String two(int number) => number.toString().padLeft(2, '0');
  return '${date.year}-${two(date.month)}-${two(date.day)}';
}
