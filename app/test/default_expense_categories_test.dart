import 'package:flutter_test/flutter_test.dart';
import 'package:jizhangben/features/categories/domain/default_expense_categories.dart';

void main() {
  test('默认分类严格保持两级且标识不重复', () {
    final ids = <String>{};
    var childCount = 0;

    for (final group in DefaultExpenseCategories.groups) {
      expect(ids.add(group.id), isTrue);
      expect(group.children, isNotEmpty);
      for (final child in group.children) {
        childCount++;
        expect(child.id.startsWith('${group.id}.'), isTrue);
        expect(ids.add(child.id), isTrue);
      }
    }

    expect(DefaultExpenseCategories.groups, hasLength(13));
    expect(childCount, 82);
  });
}
