import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jizhangben/core/database/database_providers.dart';
import 'package:jizhangben/core/logging/app_logging.dart';
import 'package:jizhangben/features/categories/data/local_category_repository.dart';
import 'package:jizhangben/features/currencies/domain/currency_definition.dart';
import 'package:jizhangben/features/expenses/data/local_expense_repository.dart';
import 'package:jizhangben/features/expenses/presentation/expense_editor_panel.dart';

final filteredExpenseItemsProvider = StreamProvider.autoDispose
    .family<List<ExpenseListItem>, ExpenseFilter>((ref, filter) {
      return ref
          .watch(localExpenseRepositoryProvider)
          .watchFilteredDetailed(filter);
    });

class ExpensesPage extends ConsumerStatefulWidget {
  const ExpensesPage({this.useMobileLayout = false, super.key});

  final bool useMobileLayout;

  @override
  ConsumerState<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends ConsumerState<ExpensesPage> {
  var _showEditor = false;
  ExpenseListItem? _editingItem;
  var _filter = const ExpenseFilter();

  void _openNew() {
    setState(() {
      _editingItem = null;
      _showEditor = true;
    });
  }

  void _openEdit(ExpenseListItem item) {
    setState(() {
      _editingItem = item;
      _showEditor = true;
    });
  }

  void _closeEditor() {
    setState(() {
      _editingItem = null;
      _showEditor = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(filteredExpenseItemsProvider(_filter));
    final useMobileLayout = widget.useMobileLayout;
    return Scaffold(
      appBar: AppBar(
        title: const Text('花销记录'),
        actions: useMobileLayout
            ? null
            : [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: FilledButton.icon(
                    onPressed: _openNew,
                    icon: const Icon(Icons.add),
                    label: const Text('记一笔'),
                  ),
                ),
              ],
      ),
      floatingActionButton: useMobileLayout && !_showEditor
          ? FloatingActionButton.extended(
              onPressed: _openNew,
              icon: const Icon(Icons.add),
              label: const Text('记一笔'),
            )
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final useSidePanel = constraints.maxWidth >= 920;
          final list = Column(
            children: [
              _ExpenseFilterBar(
                filter: _filter,
                onOpen: _openFilter,
                onClear: () => setState(() => _filter = const ExpenseFilter()),
              ),
              Expanded(
                child: _ExpenseList(
                  expenses: expenses,
                  onAdd: _openNew,
                  onEdit: _openEdit,
                  onDelete: _confirmDelete,
                ),
              ),
            ],
          );
          if (!_showEditor) return list;

          final editor = ExpenseEditorPanel(
            key: ValueKey(_editingItem?.expense.id ?? 'new'),
            initialItem: _editingItem,
            onCancel: _closeEditor,
            onSaved: (wasEditing) {
              _closeEditor();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(wasEditing ? '花销已更新' : '花销已保存')),
              );
            },
          );
          if (!useSidePanel) return editor;

          return Row(
            children: [
              Expanded(child: list),
              const VerticalDivider(width: 1),
              SizedBox(width: 460, child: editor),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(ExpenseListItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除这笔花销？'),
        content: Text(
          '${item.parentCategoryName} / ${item.categoryName}\n删除后无法撤销。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(localExpenseRepositoryProvider).delete(item.expense.id);
      if (_editingItem?.expense.id == item.expense.id) _closeEditor();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('花销已删除')));
    } catch (error, stackTrace) {
      AppLogging.reportError(
        source: 'expenses.delete',
        safeMessage: 'Deleting an expense failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _openFilter() async {
    try {
      final tree = await ref.read(localCategoryRepositoryProvider).getTree();
      if (!mounted) return;
      final result = await showDialog<ExpenseFilter>(
        context: context,
        builder: (context) =>
            _ExpenseFilterDialog(initialFilter: _filter, categories: tree),
      );
      if (result != null && mounted) setState(() => _filter = result);
    } catch (error, stackTrace) {
      AppLogging.reportError(
        source: 'expenses.filter',
        safeMessage: 'Opening the expense filter failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}

class _ExpenseFilterBar extends StatelessWidget {
  const _ExpenseFilterBar({
    required this.filter,
    required this.onOpen,
    required this.onClear,
  });

  final ExpenseFilter filter;
  final VoidCallback onOpen;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final labels = <String>[
      if (filter.startLocalInclusive != null &&
          filter.endLocalExclusive != null)
        '${_formatDate(filter.startLocalInclusive!)} 至 ${_formatDate(filter.endLocalExclusive!.subtract(const Duration(days: 1)))}',
      if (filter.currencyCode != null) filter.currencyCode!,
      if (filter.parentCategoryId != null) '已选一级分类',
      if (filter.categoryId != null) '已选二级分类',
      filter.descending ? '时间：新到旧' : '时间：旧到新',
    ];
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Row(
          children: [
            OutlinedButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.filter_list),
              label: const Text('筛选与排序'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final label in labels) ...[
                      Chip(
                        label: Text(label),
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
            ),
            if (!filter.isEmpty)
              TextButton(onPressed: onClear, child: const Text('清除')),
          ],
        ),
      ),
    );
  }
}

class _ExpenseFilterDialog extends StatefulWidget {
  const _ExpenseFilterDialog({
    required this.initialFilter,
    required this.categories,
  });

  final ExpenseFilter initialFilter;
  final List<CategoryTreeNode> categories;

  @override
  State<_ExpenseFilterDialog> createState() => _ExpenseFilterDialogState();
}

class _ExpenseFilterDialogState extends State<_ExpenseFilterDialog> {
  DateTimeRange? _dateRange;
  String? _currencyCode;
  String? _parentCategoryId;
  String? _categoryId;
  late bool _descending;

  @override
  void initState() {
    super.initState();
    final filter = widget.initialFilter;
    if (filter.startLocalInclusive != null &&
        filter.endLocalExclusive != null) {
      _dateRange = DateTimeRange(
        start: filter.startLocalInclusive!,
        end: filter.endLocalExclusive!.subtract(const Duration(days: 1)),
      );
    }
    _currencyCode = filter.currencyCode;
    _parentCategoryId = filter.parentCategoryId;
    _categoryId = filter.categoryId;
    _descending = filter.descending;
  }

  @override
  Widget build(BuildContext context) {
    final children = widget.categories
        .where((node) => node.parent.id == _parentCategoryId)
        .expand((node) => node.children);
    return AlertDialog(
      title: const Text('筛选与排序'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('日期范围'),
                subtitle: Text(
                  _dateRange == null
                      ? '全部日期'
                      : '${_formatDate(_dateRange!.start)} 至 ${_formatDate(_dateRange!.end)}',
                ),
                trailing: Wrap(
                  children: [
                    if (_dateRange != null)
                      IconButton(
                        onPressed: () => setState(() => _dateRange = null),
                        tooltip: '清除日期',
                        icon: const Icon(Icons.clear),
                      ),
                    IconButton(
                      onPressed: _pickDateRange,
                      tooltip: '选择日期',
                      icon: const Icon(Icons.date_range),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _currencyCode,
                decoration: const InputDecoration(
                  labelText: '货币',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('全部货币'),
                  ),
                  for (final currency in SupportedCurrencies.values)
                    DropdownMenuItem<String?>(
                      value: currency.code,
                      child: Text('${currency.name}（${currency.code}）'),
                    ),
                ],
                onChanged: (value) => setState(() => _currencyCode = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                initialValue: _parentCategoryId,
                decoration: const InputDecoration(
                  labelText: '一级分类',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('全部一级分类'),
                  ),
                  for (final node in widget.categories)
                    DropdownMenuItem<String?>(
                      value: node.parent.id,
                      child: Text(node.parent.name),
                    ),
                ],
                onChanged: (value) => setState(() {
                  _parentCategoryId = value;
                  _categoryId = null;
                }),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                key: ValueKey(_parentCategoryId),
                initialValue: _categoryId,
                decoration: const InputDecoration(
                  labelText: '二级分类',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('全部二级分类'),
                  ),
                  for (final child in children)
                    DropdownMenuItem<String?>(
                      value: child.id,
                      child: Text(child.name),
                    ),
                ],
                onChanged: _parentCategoryId == null
                    ? null
                    : (value) => setState(() => _categoryId = value),
              ),
              const SizedBox(height: 16),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: true,
                    label: Text('时间：新到旧'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text('时间：旧到新'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                ],
                selected: {_descending},
                onSelectionChanged: (selection) =>
                    setState(() => _descending = selection.single),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, const ExpenseFilter()),
          child: const Text('重置'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _apply, child: const Text('应用')),
      ],
    );
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1970),
      lastDate: now.add(const Duration(days: 366)),
      initialDateRange: _dateRange,
    );
    if (selected != null) setState(() => _dateRange = selected);
  }

  void _apply() {
    Navigator.pop(
      context,
      ExpenseFilter(
        startLocalInclusive: _dateRange?.start,
        endLocalExclusive: _dateRange?.end.add(const Duration(days: 1)),
        currencyCode: _currencyCode,
        parentCategoryId: _parentCategoryId,
        categoryId: _categoryId,
        descending: _descending,
      ),
    );
  }
}

class _ExpenseList extends StatelessWidget {
  const _ExpenseList({
    required this.expenses,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final AsyncValue<List<ExpenseListItem>> expenses;
  final VoidCallback onAdd;
  final ValueChanged<ExpenseListItem> onEdit;
  final ValueChanged<ExpenseListItem> onDelete;

  @override
  Widget build(BuildContext context) {
    return expenses.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('花销读取失败：$error')),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.receipt_long_outlined, size: 64),
                const SizedBox(height: 16),
                Text(
                  '还没有花销记录',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text('记录第一笔花销，开始了解钱花在了哪里。'),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: const Text('记一笔'),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = items[index];
            final currency = SupportedCurrencies.require(
              item.expense.currencyCode,
            );
            final amount = MoneyMinorUnits.format(
              item.expense.amountMinor,
              currency,
            );
            final occurred = item.occurrence.localWallClock;
            return Card(
              child: ListTile(
                onTap: () => onEdit(item),
                leading: CircleAvatar(
                  child: Text(item.parentCategoryName.characters.first),
                ),
                title: Text('${currency.symbol}$amount ${currency.code}'),
                subtitle: Text(
                  '${item.parentCategoryName} / ${item.categoryName}  ·  ${_formatDateTime(occurred)}'
                  '${item.expense.note == null ? '' : '\n${item.expense.note}'}',
                ),
                isThreeLine: item.expense.note != null,
                trailing: PopupMenuButton<String>(
                  tooltip: '更多操作',
                  onSelected: (value) =>
                      value == 'edit' ? onEdit(item) : onDelete(item),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('编辑')),
                    PopupMenuItem(value: 'delete', child: Text('删除')),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

String _formatDateTime(DateTime value) {
  String two(int number) => number.toString().padLeft(2, '0');
  return '${value.year}-${two(value.month)}-${two(value.day)} ${two(value.hour)}:${two(value.minute)}';
}

String _formatDate(DateTime value) {
  String two(int number) => number.toString().padLeft(2, '0');
  return '${value.year}-${two(value.month)}-${two(value.day)}';
}
