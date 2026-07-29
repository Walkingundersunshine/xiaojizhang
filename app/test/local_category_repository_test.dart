import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jizhangben/core/database/app_database.dart';
import 'package:jizhangben/features/categories/data/local_category_repository.dart';
import 'package:jizhangben/features/expenses/data/local_expense_repository.dart';
import 'package:jizhangben/features/expenses/domain/expense_occurrence.dart';

void main() {
  late AppDatabase database;
  late LocalCategoryRepository categories;
  late LocalExpenseRepository expenses;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    categories = LocalCategoryRepository(database);
    expenses = LocalExpenseRepository(database);
  });

  tearDown(() => database.close());

  test('新增一级和二级分类并拒绝第三级', () async {
    final parent = await categories.createTopLevel('个人项目');
    final child = await categories.createChild(
      parentId: parent.id,
      name: '素材购买',
    );

    expect(parent.parentId, isNull);
    expect(parent.isSystem, isFalse);
    expect(child.parentId, parent.id);
    expect(child.isSystem, isFalse);
    expect(child.id, matches(RegExp(r'^[0-9a-f-]{36}$')));
    expect(
      () => categories.createChild(parentId: child.id, name: '第三级'),
      throwsArgumentError,
    );
  });

  test('支持重命名并阻止同一级重复名称', () async {
    final category = await categories.createTopLevel('自定义大类');
    final renamed = await categories.rename(id: category.id, name: '  我的分类  ');

    expect(renamed.name, '我的分类');
    expect(() => categories.createTopLevel('我的分类'), throwsArgumentError);
  });

  test('停用一级分类时停用其二级分类', () async {
    final parent = await categories.createTopLevel('待停用');
    final child = await categories.createChild(
      parentId: parent.id,
      name: '子分类',
    );

    await categories.setActive(id: parent.id, isActive: false);

    final all = await database.select(database.categories).get();
    expect(all.singleWhere((item) => item.id == parent.id).isActive, isFalse);
    expect(all.singleWhere((item) => item.id == child.id).isActive, isFalse);
    expect(
      () => categories.setActive(id: child.id, isActive: true),
      throwsStateError,
    );
  });

  test('停用分类不会破坏已存在的历史账目', () async {
    final parent = await categories.createTopLevel('历史测试');
    final child = await categories.createChild(
      parentId: parent.id,
      name: '旧分类',
    );
    final expenseId = await expenses.create(
      ExpenseDraft(
        amountMinor: 100,
        currencyCode: 'CNY',
        categoryId: child.id,
        occurrence: ExpenseOccurrence.fromStored(
          utcMilliseconds: DateTime.utc(2026, 7, 29).millisecondsSinceEpoch,
          timezoneOffsetMinutes: 480,
        ),
      ),
    );

    await categories.setActive(id: child.id, isActive: false);

    expect((await expenses.findById(expenseId))!.categoryId, child.id);
    expect(
      () => expenses.create(
        ExpenseDraft(
          amountMinor: 200,
          currencyCode: 'CNY',
          categoryId: child.id,
          occurrence: ExpenseOccurrence.fromStored(
            utcMilliseconds: DateTime.utc(2026, 7, 30).millisecondsSinceEpoch,
            timezoneOffsetMinutes: 480,
          ),
        ),
      ),
      throwsArgumentError,
    );
  });

  test('同一级分类可以完整重新排序', () async {
    final custom = await categories.createTopLevel('置顶分类');
    final topLevel =
        (await database.select(database.categories).get())
            .where((category) => category.parentId == null)
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final ordered = [
      custom.id,
      ...topLevel
          .where((category) => category.id != custom.id)
          .map((category) => category.id),
    ];

    await categories.reorder(parentId: null, orderedIds: ordered);

    final reordered =
        (await database.select(database.categories).get())
            .where((category) => category.parentId == null)
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    expect(reordered.first.id, custom.id);
  });
}
