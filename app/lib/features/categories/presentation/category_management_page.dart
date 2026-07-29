import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jizhangben/core/database/app_database.dart';
import 'package:jizhangben/core/database/database_providers.dart';
import 'package:jizhangben/core/logging/app_logging.dart';
import 'package:jizhangben/features/categories/data/local_category_repository.dart';

final categoryTreeProvider = StreamProvider.autoDispose<List<CategoryTreeNode>>(
  (ref) {
    return ref.watch(localCategoryRepositoryProvider).watchTree();
  },
);

class CategoryManagementPage extends ConsumerWidget {
  const CategoryManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tree = ref.watch(categoryTreeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('分类管理'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton.icon(
              onPressed: () => _addTopLevel(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('新增一级分类'),
            ),
          ),
        ],
      ),
      body: tree.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ErrorState(error: error),
        data: (nodes) => nodes.isEmpty
            ? const Center(child: Text('还没有分类，请先新增一级分类。'))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                itemCount: nodes.length,
                itemBuilder: (context, index) => _CategoryGroupCard(
                  node: nodes[index],
                  canMoveUp: index > 0,
                  canMoveDown: index < nodes.length - 1,
                  onMoveUp: () => _moveTopLevel(context, ref, nodes, index, -1),
                  onMoveDown: () =>
                      _moveTopLevel(context, ref, nodes, index, 1),
                ),
              ),
      ),
    );
  }

  Future<void> _addTopLevel(BuildContext context, WidgetRef ref) async {
    final name = await _showNameDialog(context, title: '新增一级分类');
    if (name == null || !context.mounted) return;
    await _runAction(
      context,
      () => ref.read(localCategoryRepositoryProvider).createTopLevel(name),
    );
  }

  Future<void> _moveTopLevel(
    BuildContext context,
    WidgetRef ref,
    List<CategoryTreeNode> nodes,
    int index,
    int offset,
  ) async {
    final ordered = nodes.map((node) => node.parent.id).toList();
    final item = ordered.removeAt(index);
    ordered.insert(index + offset, item);
    await _runAction(
      context,
      () => ref
          .read(localCategoryRepositoryProvider)
          .reorder(parentId: null, orderedIds: ordered),
    );
  }
}

class _CategoryGroupCard extends ConsumerWidget {
  const _CategoryGroupCard({
    required this.node,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  final CategoryTreeNode node;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parent = node.parent;
    return Card(
      key: ValueKey(parent.id),
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(
          parent.isActive ? Icons.folder_outlined : Icons.folder_off_outlined,
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                parent.name,
                style: parent.isActive
                    ? null
                    : const TextStyle(decoration: TextDecoration.lineThrough),
              ),
            ),
            if (parent.isSystem) ...[
              const SizedBox(width: 8),
              const Chip(
                label: Text('系统'),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ],
        ),
        subtitle: Text(
          '${node.children.length} 个二级分类${parent.isActive ? '' : ' · 已停用'}',
        ),
        trailing: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            IconButton(
              onPressed: canMoveUp ? onMoveUp : null,
              tooltip: '上移',
              icon: const Icon(Icons.arrow_upward),
            ),
            IconButton(
              onPressed: canMoveDown ? onMoveDown : null,
              tooltip: '下移',
              icon: const Icon(Icons.arrow_downward),
            ),
            IconButton(
              onPressed: () => _rename(context, ref, parent.id, parent.name),
              tooltip: '重命名',
              icon: const Icon(Icons.edit_outlined),
            ),
            Switch(
              value: parent.isActive,
              onChanged: (value) => _setParentActive(context, ref, value),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          for (var index = 0; index < node.children.length; index++)
            _ChildCategoryTile(
              category: node.children[index],
              canMoveUp: index > 0,
              canMoveDown: index < node.children.length - 1,
              onMoveUp: () => _moveChild(context, ref, index, -1),
              onMoveDown: () => _moveChild(context, ref, index, 1),
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: parent.isActive ? () => _addChild(context, ref) : null,
              icon: const Icon(Icons.add),
              label: const Text('新增二级分类'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addChild(BuildContext context, WidgetRef ref) async {
    final name = await _showNameDialog(context, title: '新增二级分类');
    if (name == null || !context.mounted) return;
    await _runAction(
      context,
      () => ref
          .read(localCategoryRepositoryProvider)
          .createChild(parentId: node.parent.id, name: name),
    );
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    String id,
    String currentName,
  ) async {
    final name = await _showNameDialog(
      context,
      title: '重命名一级分类',
      initialValue: currentName,
    );
    if (name == null || !context.mounted) return;
    await _runAction(
      context,
      () =>
          ref.read(localCategoryRepositoryProvider).rename(id: id, name: name),
    );
  }

  Future<void> _setParentActive(
    BuildContext context,
    WidgetRef ref,
    bool isActive,
  ) async {
    if (!isActive) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('停用一级分类？'),
          content: const Text('该分类下的全部二级分类也会停用。历史账目不会被删除。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('停用'),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
    }
    await _runAction(
      context,
      () => ref
          .read(localCategoryRepositoryProvider)
          .setActive(id: node.parent.id, isActive: isActive),
    );
  }

  Future<void> _moveChild(
    BuildContext context,
    WidgetRef ref,
    int index,
    int offset,
  ) async {
    final ordered = node.children.map((category) => category.id).toList();
    final item = ordered.removeAt(index);
    ordered.insert(index + offset, item);
    await _runAction(
      context,
      () => ref
          .read(localCategoryRepositoryProvider)
          .reorder(parentId: node.parent.id, orderedIds: ordered),
    );
  }
}

class _ChildCategoryTile extends ConsumerWidget {
  const _ChildCategoryTile({
    required this.category,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  final Category category;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      dense: true,
      leading: Icon(
        category.isActive ? Icons.subdirectory_arrow_right : Icons.block,
        size: 20,
      ),
      title: Text(
        category.name,
        style: category.isActive
            ? null
            : const TextStyle(decoration: TextDecoration.lineThrough),
      ),
      trailing: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          IconButton(
            onPressed: canMoveUp ? onMoveUp : null,
            tooltip: '上移',
            icon: const Icon(Icons.arrow_upward),
          ),
          IconButton(
            onPressed: canMoveDown ? onMoveDown : null,
            tooltip: '下移',
            icon: const Icon(Icons.arrow_downward),
          ),
          IconButton(
            tooltip: '重命名',
            onPressed: () => _rename(context, ref),
            icon: const Icon(Icons.edit_outlined),
          ),
          Switch(
            value: category.isActive,
            onChanged: (value) => _runAction(
              context,
              () => ref
                  .read(localCategoryRepositoryProvider)
                  .setActive(id: category.id, isActive: value),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final name = await _showNameDialog(
      context,
      title: '重命名二级分类',
      initialValue: category.name,
    );
    if (name == null || !context.mounted) return;
    await _runAction(
      context,
      () => ref
          .read(localCategoryRepositoryProvider)
          .rename(id: category.id, name: name),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text('分类读取失败：$error', textAlign: TextAlign.center),
      ),
    );
  }
}

Future<String?> _showNameDialog(
  BuildContext context, {
  required String title,
  String initialValue = '',
}) async {
  final controller = TextEditingController(text: initialValue);
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: 40,
        decoration: const InputDecoration(
          labelText: '分类名称',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('保存'),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}

Future<void> _runAction(
  BuildContext context,
  Future<Object?> Function() action,
) async {
  try {
    await action();
  } catch (error, stackTrace) {
    AppLogging.reportError(
      source: 'categories.action',
      safeMessage: 'Category operation failed',
      error: error,
      stackTrace: stackTrace,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
  }
}
