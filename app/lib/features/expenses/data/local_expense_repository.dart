import 'package:drift/drift.dart';
import 'package:jizhangben/core/database/app_database.dart';
import 'package:jizhangben/features/currencies/domain/currency_definition.dart';
import 'package:jizhangben/features/expenses/domain/expense_occurrence.dart';

final class ExpenseListItem {
  const ExpenseListItem({
    required this.expense,
    required this.parentCategoryId,
    required this.parentCategoryName,
    required this.categoryName,
  });

  final Expense expense;
  final String parentCategoryId;
  final String parentCategoryName;
  final String categoryName;

  ExpenseOccurrence get occurrence => ExpenseOccurrence.fromStored(
    utcMilliseconds: expense.occurredAtUtcMilliseconds,
    timezoneOffsetMinutes: expense.occurredTimezoneOffsetMinutes,
  );
}

final class ExpenseFilter {
  const ExpenseFilter({
    this.startLocalInclusive,
    this.endLocalExclusive,
    this.currencyCode,
    this.parentCategoryId,
    this.categoryId,
    this.descending = true,
  });

  final DateTime? startLocalInclusive;
  final DateTime? endLocalExclusive;
  final String? currencyCode;
  final String? parentCategoryId;
  final String? categoryId;
  final bool descending;

  bool get isEmpty =>
      startLocalInclusive == null &&
      endLocalExclusive == null &&
      currencyCode == null &&
      parentCategoryId == null &&
      categoryId == null &&
      descending;

  @override
  bool operator ==(Object other) {
    return other is ExpenseFilter &&
        other.startLocalInclusive == startLocalInclusive &&
        other.endLocalExclusive == endLocalExclusive &&
        other.currencyCode == currencyCode &&
        other.parentCategoryId == parentCategoryId &&
        other.categoryId == categoryId &&
        other.descending == descending;
  }

  @override
  int get hashCode => Object.hash(
    startLocalInclusive,
    endLocalExclusive,
    currencyCode,
    parentCategoryId,
    categoryId,
    descending,
  );
}

final class ExpenseDraft {
  const ExpenseDraft({
    required this.amountMinor,
    required this.currencyCode,
    required this.categoryId,
    required this.occurrence,
    this.note,
  });

  final int amountMinor;
  final String currencyCode;
  final String categoryId;
  final ExpenseOccurrence occurrence;
  final String? note;
}

final class LocalExpenseRepository {
  const LocalExpenseRepository(this.database);

  final AppDatabase database;

  Future<int> create(ExpenseDraft draft) async {
    final normalized = await _validateAndNormalize(draft);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    return database
        .into(database.expenses)
        .insert(
          ExpensesCompanion.insert(
            amountMinor: normalized.amountMinor,
            currencyCode: normalized.currencyCode,
            categoryId: normalized.categoryId,
            occurredAtUtcMilliseconds: normalized.occurrence.utcMilliseconds,
            occurredTimezoneOffsetMinutes:
                normalized.occurrence.timezoneOffsetMinutes,
            note: Value(normalized.note),
            createdAtUtcMilliseconds: now,
            updatedAtUtcMilliseconds: now,
          ),
        );
  }

  Future<void> update(int id, ExpenseDraft draft) async {
    final normalized = await _validateAndNormalize(draft);
    final changed =
        await (database.update(
          database.expenses,
        )..where((row) => row.id.equals(id))).write(
          ExpensesCompanion(
            amountMinor: Value(normalized.amountMinor),
            currencyCode: Value(normalized.currencyCode),
            categoryId: Value(normalized.categoryId),
            occurredAtUtcMilliseconds: Value(
              normalized.occurrence.utcMilliseconds,
            ),
            occurredTimezoneOffsetMinutes: Value(
              normalized.occurrence.timezoneOffsetMinutes,
            ),
            note: Value(normalized.note),
            updatedAtUtcMilliseconds: Value(
              DateTime.now().toUtc().millisecondsSinceEpoch,
            ),
          ),
        );
    if (changed == 0) {
      throw StateError('未找到要修改的花销记录');
    }
  }

  Future<void> delete(int id) async {
    final deleted = await (database.delete(
      database.expenses,
    )..where((row) => row.id.equals(id))).go();
    if (deleted == 0) {
      throw StateError('未找到要删除的花销记录');
    }
  }

  Future<Expense?> findById(int id) {
    return (database.select(
      database.expenses,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
  }

  Stream<List<Expense>> watchRecent({int limit = 100}) {
    if (limit <= 0) {
      throw ArgumentError.value(limit, 'limit', '数量必须大于 0');
    }
    final query = database.select(database.expenses)
      ..orderBy([
        (row) => OrderingTerm.desc(row.occurredAtUtcMilliseconds),
        (row) => OrderingTerm.desc(row.id),
      ])
      ..limit(limit);
    return query.watch();
  }

  Stream<List<ExpenseListItem>> watchRecentDetailed({int limit = 100}) {
    if (limit <= 0) {
      throw ArgumentError.value(limit, 'limit', '数量必须大于 0');
    }
    final parentCategories = database.categories.createAlias(
      'parent_categories',
    );
    final query =
        database.select(database.expenses).join([
            innerJoin(
              database.categories,
              database.categories.id.equalsExp(database.expenses.categoryId),
            ),
            innerJoin(
              parentCategories,
              parentCategories.id.equalsExp(database.categories.parentId),
            ),
          ])
          ..orderBy([
            OrderingTerm.desc(database.expenses.occurredAtUtcMilliseconds),
            OrderingTerm.desc(database.expenses.id),
          ])
          ..limit(limit);

    return query.watch().map(
      (rows) => [
        for (final row in rows)
          ExpenseListItem(
            expense: row.readTable(database.expenses),
            parentCategoryId: row.readTable(parentCategories).id,
            parentCategoryName: row.readTable(parentCategories).name,
            categoryName: row.readTable(database.categories).name,
          ),
      ],
    );
  }

  Stream<List<ExpenseListItem>> watchDetailedInLocalRange({
    required DateTime startInclusive,
    required DateTime endExclusive,
  }) {
    final startWall = _wallClockMilliseconds(startInclusive);
    final endWall = _wallClockMilliseconds(endExclusive);
    if (endWall <= startWall) {
      throw ArgumentError('结束时间必须晚于开始时间');
    }
    const maximumOffsetMilliseconds = 14 * 60 * 60 * 1000;
    final utcLowerBound = startWall - maximumOffsetMilliseconds;
    final utcUpperBound = endWall + maximumOffsetMilliseconds;
    final parentCategories = database.categories.createAlias(
      'range_parent_categories',
    );
    final query =
        database.select(database.expenses).join([
            innerJoin(
              database.categories,
              database.categories.id.equalsExp(database.expenses.categoryId),
            ),
            innerJoin(
              parentCategories,
              parentCategories.id.equalsExp(database.categories.parentId),
            ),
          ])
          ..where(
            database.expenses.occurredAtUtcMilliseconds.isBiggerOrEqualValue(
                  utcLowerBound,
                ) &
                database.expenses.occurredAtUtcMilliseconds.isSmallerThanValue(
                  utcUpperBound,
                ),
          )
          ..orderBy([
            OrderingTerm.desc(database.expenses.occurredAtUtcMilliseconds),
            OrderingTerm.desc(database.expenses.id),
          ]);

    return query.watch().map((rows) {
      final items = <ExpenseListItem>[];
      for (final row in rows) {
        final item = ExpenseListItem(
          expense: row.readTable(database.expenses),
          parentCategoryId: row.readTable(parentCategories).id,
          parentCategoryName: row.readTable(parentCategories).name,
          categoryName: row.readTable(database.categories).name,
        );
        final localWall = _wallClockMilliseconds(
          item.occurrence.localWallClock,
        );
        if (localWall >= startWall && localWall < endWall) {
          items.add(item);
        }
      }
      return items;
    });
  }

  Stream<List<ExpenseListItem>> watchFilteredDetailed(ExpenseFilter filter) {
    if ((filter.startLocalInclusive == null) !=
        (filter.endLocalExclusive == null)) {
      throw ArgumentError('日期筛选必须同时提供开始和结束日期');
    }
    final parentCategories = database.categories.createAlias(
      'filter_parent_categories',
    );
    final query = database.select(database.expenses).join([
      innerJoin(
        database.categories,
        database.categories.id.equalsExp(database.expenses.categoryId),
      ),
      innerJoin(
        parentCategories,
        parentCategories.id.equalsExp(database.categories.parentId),
      ),
    ]);

    Expression<bool>? condition;
    void addCondition(Expression<bool> next) {
      condition = condition == null ? next : condition! & next;
    }

    int? startWall;
    int? endWall;
    if (filter.startLocalInclusive != null &&
        filter.endLocalExclusive != null) {
      startWall = _wallClockMilliseconds(filter.startLocalInclusive!);
      endWall = _wallClockMilliseconds(filter.endLocalExclusive!);
      if (endWall <= startWall) throw ArgumentError('结束日期必须晚于开始日期');
      const maximumOffsetMilliseconds = 14 * 60 * 60 * 1000;
      addCondition(
        database.expenses.occurredAtUtcMilliseconds.isBiggerOrEqualValue(
              startWall - maximumOffsetMilliseconds,
            ) &
            database.expenses.occurredAtUtcMilliseconds.isSmallerThanValue(
              endWall + maximumOffsetMilliseconds,
            ),
      );
    }
    if (filter.currencyCode != null) {
      addCondition(
        database.expenses.currencyCode.equals(
          filter.currencyCode!.toUpperCase(),
        ),
      );
    }
    if (filter.parentCategoryId != null) {
      addCondition(parentCategories.id.equals(filter.parentCategoryId!));
    }
    if (filter.categoryId != null) {
      addCondition(database.expenses.categoryId.equals(filter.categoryId!));
    }
    if (condition != null) query.where(condition!);
    query.orderBy([
      filter.descending
          ? OrderingTerm.desc(database.expenses.occurredAtUtcMilliseconds)
          : OrderingTerm.asc(database.expenses.occurredAtUtcMilliseconds),
      filter.descending
          ? OrderingTerm.desc(database.expenses.id)
          : OrderingTerm.asc(database.expenses.id),
    ]);

    return query.watch().map((rows) {
      final items = <ExpenseListItem>[];
      for (final row in rows) {
        final item = ExpenseListItem(
          expense: row.readTable(database.expenses),
          parentCategoryId: row.readTable(parentCategories).id,
          parentCategoryName: row.readTable(parentCategories).name,
          categoryName: row.readTable(database.categories).name,
        );
        if (startWall != null && endWall != null) {
          final localWall = _wallClockMilliseconds(
            item.occurrence.localWallClock,
          );
          if (localWall < startWall || localWall >= endWall) continue;
        }
        items.add(item);
      }
      return items;
    });
  }

  Future<ExpenseDraft> _validateAndNormalize(ExpenseDraft draft) async {
    if (draft.amountMinor <= 0) {
      throw ArgumentError.value(draft.amountMinor, 'amountMinor', '金额必须大于 0');
    }

    final currency = SupportedCurrencies.require(draft.currencyCode);
    final note = draft.note?.trim();
    if (note != null && note.length > 500) {
      throw ArgumentError.value(note, 'note', '备注不能超过 500 个字符');
    }

    final category = await (database.select(
      database.categories,
    )..where((row) => row.id.equals(draft.categoryId))).getSingleOrNull();
    if (category == null || category.parentId == null || !category.isActive) {
      throw ArgumentError.value(draft.categoryId, 'categoryId', '必须选择有效的二级分类');
    }

    return ExpenseDraft(
      amountMinor: draft.amountMinor,
      currencyCode: currency.code,
      categoryId: category.id,
      occurrence: draft.occurrence,
      note: note == null || note.isEmpty ? null : note,
    );
  }
}

int _wallClockMilliseconds(DateTime value) {
  return DateTime.utc(
    value.year,
    value.month,
    value.day,
    value.hour,
    value.minute,
    value.second,
    value.millisecond,
    value.microsecond,
  ).millisecondsSinceEpoch;
}
