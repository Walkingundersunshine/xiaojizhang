import 'package:flutter_test/flutter_test.dart';
import 'package:jizhangben/features/expenses/domain/expense_occurrence.dart';

void main() {
  test('使用保存的时区偏移还原记账时看到的当地时间', () {
    final occurrence = ExpenseOccurrence.fromStored(
      utcMilliseconds: DateTime.utc(2026, 7, 29, 15, 30).millisecondsSinceEpoch,
      timezoneOffsetMinutes: 9 * 60,
    );

    expect(occurrence.localWallClock.year, 2026);
    expect(occurrence.localWallClock.month, 7);
    expect(occurrence.localWallClock.day, 30);
    expect(occurrence.localWallClock.hour, 0);
    expect(occurrence.localWallClock.minute, 30);
  });

  test('拒绝超出全球实际范围的时区偏移', () {
    expect(
      () => ExpenseOccurrence.fromStored(
        utcMilliseconds: 0,
        timezoneOffsetMinutes: 15 * 60,
      ),
      throwsArgumentError,
    );
  });
}
