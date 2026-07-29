final class CurrencyDefinition {
  const CurrencyDefinition({
    required this.code,
    required this.name,
    required this.symbol,
    required this.minorUnitDigits,
  });

  final String code;
  final String name;
  final String symbol;
  final int minorUnitDigits;
}

abstract final class SupportedCurrencies {
  static const values = <CurrencyDefinition>[
    CurrencyDefinition(
      code: 'CNY',
      name: '人民币',
      symbol: '¥',
      minorUnitDigits: 2,
    ),
    CurrencyDefinition(
      code: 'USD',
      name: '美元',
      symbol: r'$',
      minorUnitDigits: 2,
    ),
    CurrencyDefinition(
      code: 'EUR',
      name: '欧元',
      symbol: '€',
      minorUnitDigits: 2,
    ),
    CurrencyDefinition(
      code: 'GBP',
      name: '英镑',
      symbol: '£',
      minorUnitDigits: 2,
    ),
    CurrencyDefinition(
      code: 'JPY',
      name: '日元',
      symbol: '¥',
      minorUnitDigits: 0,
    ),
    CurrencyDefinition(
      code: 'HKD',
      name: '港币',
      symbol: r'HK$',
      minorUnitDigits: 2,
    ),
    CurrencyDefinition(
      code: 'MOP',
      name: '澳门元',
      symbol: r'MOP$',
      minorUnitDigits: 2,
    ),
    CurrencyDefinition(
      code: 'TWD',
      name: '新台币',
      symbol: r'NT$',
      minorUnitDigits: 2,
    ),
    CurrencyDefinition(
      code: 'SGD',
      name: '新加坡元',
      symbol: r'S$',
      minorUnitDigits: 2,
    ),
    CurrencyDefinition(
      code: 'AUD',
      name: '澳大利亚元',
      symbol: r'A$',
      minorUnitDigits: 2,
    ),
    CurrencyDefinition(
      code: 'CAD',
      name: '加拿大元',
      symbol: r'C$',
      minorUnitDigits: 2,
    ),
    CurrencyDefinition(
      code: 'KRW',
      name: '韩元',
      symbol: '₩',
      minorUnitDigits: 0,
    ),
  ];

  static final Map<String, CurrencyDefinition> byCode = Map.unmodifiable({
    for (final currency in values) currency.code: currency,
  });

  static CurrencyDefinition require(String code) {
    final normalized = code.trim().toUpperCase();
    final currency = byCode[normalized];
    if (currency == null) {
      throw ArgumentError.value(code, 'code', '不支持的货币代码');
    }
    return currency;
  }
}

abstract final class MoneyMinorUnits {
  static final BigInt _maxSqliteInteger = BigInt.from(9223372036854775807);

  static int parse(String input, CurrencyDefinition currency) {
    final normalized = input.trim();
    final match = RegExp(r'^(\d+)(?:\.(\d+))?$').firstMatch(normalized);
    if (match == null) {
      throw const FormatException('请输入有效的正数金额');
    }

    final fraction = match.group(2) ?? '';
    if (fraction.length > currency.minorUnitDigits) {
      throw FormatException(
        '${currency.code} 最多支持 ${currency.minorUnitDigits} 位小数',
      );
    }

    final factor = BigInt.from(10).pow(currency.minorUnitDigits);
    final whole = BigInt.parse(match.group(1)!);
    final paddedFraction = fraction.padRight(currency.minorUnitDigits, '0');
    final minor =
        whole * factor +
        (paddedFraction.isEmpty ? BigInt.zero : BigInt.parse(paddedFraction));

    if (minor <= BigInt.zero) {
      throw const FormatException('金额必须大于 0');
    }
    if (minor > _maxSqliteInteger) {
      throw const FormatException('金额超出可保存范围');
    }
    return minor.toInt();
  }

  static String format(int amountMinor, CurrencyDefinition currency) {
    if (amountMinor < 0) {
      throw ArgumentError.value(amountMinor, 'amountMinor', '金额不能为负数');
    }
    if (currency.minorUnitDigits == 0) {
      return amountMinor.toString();
    }

    final digits = amountMinor.toString().padLeft(
      currency.minorUnitDigits + 1,
      '0',
    );
    final splitAt = digits.length - currency.minorUnitDigits;
    return '${digits.substring(0, splitAt)}.${digits.substring(splitAt)}';
  }
}
