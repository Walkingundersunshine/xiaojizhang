import 'package:drift/drift.dart';
import 'package:jizhangben/core/database/app_database.dart';
import 'package:uuid/uuid.dart';

final class CategoryTreeNode {
  const CategoryTreeNode({required this.parent, required this.children});

  final Category parent;
  final List<Category> children;
}

final class LocalCategoryRepository {
  LocalCategoryRepository(this.database, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final AppDatabase database;
  final Uuid _uuid;

  Future<Category> createTopLevel(String name) =>
      _create(name: name, parentId: null);

  Future<Category> createChild({
    required String parentId,
    required String name,
  }) async {
    final parent = await _requireCategory(parentId);
    if (parent.parentId != null) {
      throw ArgumentError.value(parentId, 'parentId', '分类最多只能有两级');
    }
    if (!parent.isActive) {
      throw ArgumentError.value(parentId, 'parentId', '不能在已停用的一级分类下新增分类');
    }
    return _create(name: name, parentId: parentId);
  }

  Future<Category> rename({required String id, required String name}) async {
    final category = await _requireCategory(id);
    final normalizedName = _normalizeName(name);
    await _ensureNameIsUnique(
      name: normalizedName,
      parentId: category.parentId,
      excludingId: id,
    );

    await (database.update(database.categories)
          ..where((row) => row.id.equals(id)))
        .write(CategoriesCompanion(name: Value(normalizedName)));
    return _requireCategory(id);
  }

  Future<void> setActive({required String id, required bool isActive}) async {
    final category = await _requireCategory(id);
    if (category.isActive == isActive) {
      return;
    }

    if (isActive && category.parentId != null) {
      final parent = await _requireCategory(category.parentId!);
      if (!parent.isActive) {
        throw StateError('请先启用所属的一级分类');
      }
    }

    await database.transaction(() async {
      await (database.update(database.categories)
            ..where((row) => row.id.equals(id)))
          .write(CategoriesCompanion(isActive: Value(isActive)));
      if (!isActive && category.parentId == null) {
        await (database.update(database.categories)
              ..where((row) => row.parentId.equals(id)))
            .write(const CategoriesCompanion(isActive: Value(false)));
      }
    });
  }

  Future<void> reorder({
    required String? parentId,
    required List<String> orderedIds,
  }) async {
    final siblings = await _siblings(parentId);
    final existingIds = siblings.map((category) => category.id).toSet();
    final requestedIds = orderedIds.toSet();
    if (orderedIds.length != requestedIds.length ||
        existingIds.length != requestedIds.length ||
        !existingIds.containsAll(requestedIds)) {
      throw ArgumentError.value(
        orderedIds,
        'orderedIds',
        '排序列表必须包含同一级下的全部分类且不能重复',
      );
    }

    await database.transaction(() async {
      for (var index = 0; index < orderedIds.length; index++) {
        await (database.update(database.categories)
              ..where((row) => row.id.equals(orderedIds[index])))
            .write(CategoriesCompanion(sortOrder: Value(index)));
      }
    });
  }

  Stream<List<CategoryTreeNode>> watchTree({bool includeInactive = true}) {
    return _orderedCategoriesQuery().watch().map(
      (rows) => _buildTree(rows, includeInactive: includeInactive),
    );
  }

  Future<List<CategoryTreeNode>> getTree({bool includeInactive = true}) async {
    final rows = await _orderedCategoriesQuery().get();
    return _buildTree(rows, includeInactive: includeInactive);
  }

  Future<Category> _create({
    required String name,
    required String? parentId,
  }) async {
    final normalizedName = _normalizeName(name);
    await _ensureNameIsUnique(name: normalizedName, parentId: parentId);
    final siblings = await _siblings(parentId);
    final nextSortOrder = siblings.fold<int>(
      0,
      (next, category) =>
          category.sortOrder >= next ? category.sortOrder + 1 : next,
    );
    final id = _uuid.v4();

    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion.insert(
            id: id,
            parentId: Value(parentId),
            name: normalizedName,
            sortOrder: nextSortOrder,
          ),
        );
    return _requireCategory(id);
  }

  String _normalizeName(String name) {
    final normalized = name.trim();
    if (normalized.isEmpty || normalized.length > 40) {
      throw ArgumentError.value(name, 'name', '分类名称必须为 1 至 40 个字符');
    }
    return normalized;
  }

  Future<void> _ensureNameIsUnique({
    required String name,
    required String? parentId,
    String? excludingId,
  }) async {
    final siblings = await _siblings(parentId);
    final normalized = name.toLowerCase();
    final duplicate = siblings.any(
      (category) =>
          category.id != excludingId &&
          category.name.toLowerCase() == normalized,
    );
    if (duplicate) {
      throw ArgumentError.value(name, 'name', '同一级下已经存在同名分类');
    }
  }

  Future<List<Category>> _siblings(String? parentId) {
    final query = database.select(database.categories);
    if (parentId == null) {
      query.where((row) => row.parentId.isNull());
    } else {
      query.where((row) => row.parentId.equals(parentId));
    }
    query.orderBy([(row) => OrderingTerm.asc(row.sortOrder)]);
    return query.get();
  }

  Future<Category> _requireCategory(String id) async {
    final category = await (database.select(
      database.categories,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
    if (category == null) {
      throw ArgumentError.value(id, 'id', '分类不存在');
    }
    return category;
  }

  SimpleSelectStatement<$CategoriesTable, Category> _orderedCategoriesQuery() {
    return database.select(database.categories)..orderBy([
      (row) => OrderingTerm.asc(row.sortOrder),
      (row) => OrderingTerm.asc(row.name),
    ]);
  }

  List<CategoryTreeNode> _buildTree(
    List<Category> rows, {
    required bool includeInactive,
  }) {
    final visible = includeInactive
        ? rows
        : rows.where((category) => category.isActive).toList();
    final parents = visible.where((category) => category.parentId == null);
    return [
      for (final parent in parents)
        CategoryTreeNode(
          parent: parent,
          children: visible
              .where((category) => category.parentId == parent.id)
              .toList(growable: false),
        ),
    ];
  }
}
