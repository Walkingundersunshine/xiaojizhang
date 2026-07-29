final class ExpenseOccurrence {
  ExpenseOccurrence._({required this.utc, required this.timezoneOffsetMinutes});

  factory ExpenseOccurrence.fromLocal(DateTime localDateTime) {
    return ExpenseOccurrence._(
      utc: localDateTime.toUtc(),
      timezoneOffsetMinutes: localDateTime.timeZoneOffset.inMinutes,
    );
  }

  factory ExpenseOccurrence.fromStored({
    required int utcMilliseconds,
    required int timezoneOffsetMinutes,
  }) {
    if (timezoneOffsetMinutes < -840 || timezoneOffsetMinutes > 840) {
      throw ArgumentError.value(
        timezoneOffsetMinutes,
        'timezoneOffsetMinutes',
        '时区偏移必须在 -14 至 +14 小时内',
      );
    }
    return ExpenseOccurrence._(
      utc: DateTime.fromMillisecondsSinceEpoch(utcMilliseconds, isUtc: true),
      timezoneOffsetMinutes: timezoneOffsetMinutes,
    );
  }

  final DateTime utc;
  final int timezoneOffsetMinutes;

  int get utcMilliseconds => utc.millisecondsSinceEpoch;

  /// Returns the calendar components the user saw when the expense occurred.
  /// The returned object is a wall-clock value and must not be converted again.
  DateTime get localWallClock {
    final shifted = utc.add(Duration(minutes: timezoneOffsetMinutes));
    return DateTime(
      shifted.year,
      shifted.month,
      shifted.day,
      shifted.hour,
      shifted.minute,
      shifted.second,
      shifted.millisecond,
      shifted.microsecond,
    );
  }
}
