import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jizhangben/core/database/app_database.dart';
import 'package:jizhangben/features/expenses/data/local_expense_repository.dart';
import 'package:jizhangben/features/expenses/domain/expense_occurrence.dart';

void main() {
  late AppDatabase database;
  late LocalExpenseRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = LocalExpenseRepository(database);
  });

  tearDown(() => database.close());

  test('首次打开数据库时写入完整默认二级分类', () async {
    final categories = await database.select(database.categories).get();

    expect(categories, hasLength(95));
    expect(
      categories.where((category) => category.parentId == null),
      hasLength(13),
    );
    expect(
      categories.where((category) => category.parentId != null),
      hasLength(82),
    );
  });

  test('创建、修改和删除一笔精确金额花销', () async {
    final occurrence = ExpenseOccurrence.fromStored(
      utcMilliseconds: DateTime.utc(2026, 7, 29, 4, 30).millisecondsSinceEpoch,
      timezoneOffsetMinutes: 8 * 60,
    );

    final id = await repository.create(
      ExpenseDraft(
        amountMinor: 1234,
        currencyCode: 'cny',
        categoryId: 'food.lunch',
        occurrence: occurrence,
        note: '  工作午餐  ',
      ),
    );

    final created = await repository.findById(id);
    expect(created, isNotNull);
    expect(created!.amountMinor, 1234);
    expect(created.currencyCode, 'CNY');
    expect(created.categoryId, 'food.lunch');
    expect(created.note, '工作午餐');
    expect(created.occurredTimezoneOffsetMinutes, 480);

    await repository.update(
      id,
      ExpenseDraft(
        amountMinor: 1500,
        currencyCode: 'CNY',
        categoryId: 'food.dinner',
        occurrence: occurrence,
      ),
    );
    expect((await repository.findById(id))!.amountMinor, 1500);

    await repository.delete(id);
    expect(await repository.findById(id), isNull);
  });

  test('拒绝把花销直接归入一级分类', () async {
    final occurrence = ExpenseOccurrence.fromStored(
      utcMilliseconds: DateTime.utc(2026, 7, 29).millisecondsSinceEpoch,
      timezoneOffsetMinutes: 0,
    );

    expect(
      () => repository.create(
        ExpenseDraft(
          amountMinor: 100,
          currencyCode: 'CNY',
          categoryId: 'food',
          occurrence: occurrence,
        ),
      ),
      throwsArgumentError,
    );
  });

  test('日期范围按照每笔花销保存的当地日期筛选', () async {
    Future<int> createAt({required DateTime utc, required int offsetMinutes}) {
      return repository.create(
        ExpenseDraft(
          amountMinor: 100,
          currencyCode: 'CNY',
          categoryId: 'food.lunch',
          occurrence: ExpenseOccurrence.fromStored(
            utcMilliseconds: utc.millisecondsSinceEpoch,
            timezoneOffsetMinutes: offsetMinutes,
          ),
        ),
      );
    }

    final earlyLocal29 = await createAt(
      utc: DateTime.utc(2026, 7, 28, 16, 30),
      offsetMinutes: 8 * 60,
    );
    final lateLocal29 = await createAt(
      utc: DateTime.utc(2026, 7, 30, 7, 30),
      offsetMinutes: -8 * 60,
    );
    await createAt(
      utc: DateTime.utc(2026, 7, 29, 16, 30),
      offsetMinutes: 8 * 60,
    );

    final results = await repository
        .watchFilteredDetailed(
          ExpenseFilter(
            startLocalInclusive: DateTime(2026, 7, 29),
            endLocalExclusive: DateTime(2026, 7, 30),
          ),
        )
        .first;

    expect(results.map((item) => item.expense.id), [lateLocal29, earlyLocal29]);
  });

  test('可按货币和两级分类筛选，并切换时间排序', () async {
    Future<int> create({
      required DateTime utc,
      required String currency,
      required String category,
    }) {
      return repository.create(
        ExpenseDraft(
          amountMinor: 100,
          currencyCode: currency,
          categoryId: category,
          occurrence: ExpenseOccurrence.fromStored(
            utcMilliseconds: utc.millisecondsSinceEpoch,
            timezoneOffsetMinutes: 0,
          ),
        ),
      );
    }

    final lunch = await create(
      utc: DateTime.utc(2026, 7, 29, 10),
      currency: 'CNY',
      category: 'food.lunch',
    );
    final dinner = await create(
      utc: DateTime.utc(2026, 7, 29, 11),
      currency: 'USD',
      category: 'food.dinner',
    );
    final taxi = await create(
      utc: DateTime.utc(2026, 7, 29, 12),
      currency: 'CNY',
      category: 'transport.taxi',
    );

    final cny = await repository
        .watchFilteredDetailed(const ExpenseFilter(currencyCode: 'cny'))
        .first;
    expect(cny.map((item) => item.expense.id), [taxi, lunch]);

    final food = await repository
        .watchFilteredDetailed(const ExpenseFilter(parentCategoryId: 'food'))
        .first;
    expect(food.map((item) => item.expense.id), [dinner, lunch]);

    final onlyLunch = await repository
        .watchFilteredDetailed(const ExpenseFilter(categoryId: 'food.lunch'))
        .first;
    expect(onlyLunch.map((item) => item.expense.id), [lunch]);

    final ascending = await repository
        .watchFilteredDetailed(const ExpenseFilter(descending: false))
        .first;
    expect(ascending.map((item) => item.expense.id), [lunch, dinner, taxi]);
  });
}
