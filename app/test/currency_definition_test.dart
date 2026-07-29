import 'package:flutter_test/flutter_test.dart';
import 'package:jizhangben/features/currencies/domain/currency_definition.dart';

void main() {
  group('MoneyMinorUnits', () {
    test('按货币小数位精确解析和格式化', () {
      final cny = SupportedCurrencies.require('cny');
      final jpy = SupportedCurrencies.require('JPY');

      expect(MoneyMinorUnits.parse('12.34', cny), 1234);
      expect(MoneyMinorUnits.format(1234, cny), '12.34');
      expect(MoneyMinorUnits.parse('500', jpy), 500);
      expect(MoneyMinorUnits.format(500, jpy), '500');
    });

    test('拒绝零金额和超过货币精度的输入', () {
      final cny = SupportedCurrencies.require('CNY');

      expect(() => MoneyMinorUnits.parse('0', cny), throwsFormatException);
      expect(() => MoneyMinorUnits.parse('1.234', cny), throwsFormatException);
    });
  });
}
