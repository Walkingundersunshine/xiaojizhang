import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jizhangben/core/database/database_providers.dart';
import 'package:jizhangben/core/logging/app_logging.dart';
import 'package:jizhangben/features/categories/data/local_category_repository.dart';
import 'package:jizhangben/features/currencies/domain/currency_definition.dart';
import 'package:jizhangben/features/expenses/data/local_expense_repository.dart';
import 'package:jizhangben/features/expenses/domain/expense_occurrence.dart';

final activeCategoryTreeProvider =
    StreamProvider.autoDispose<List<CategoryTreeNode>>((ref) {
      return ref
          .watch(localCategoryRepositoryProvider)
          .watchTree(includeInactive: false);
    });

class ExpenseEditorPanel extends ConsumerStatefulWidget {
  const ExpenseEditorPanel({
    super.key,
    required this.initialItem,
    required this.onCancel,
    required this.onSaved,
  });

  final ExpenseListItem? initialItem;
  final VoidCallback onCancel;
  final ValueChanged<bool> onSaved;

  @override
  ConsumerState<ExpenseEditorPanel> createState() => _ExpenseEditorPanelState();
}

class _ExpenseEditorPanelState extends ConsumerState<ExpenseEditorPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late String _currencyCode;
  late DateTime _occurredLocal;
  String? _parentCategoryId;
  String? _categoryId;
  String? _errorMessage;
  var _saving = false;

  bool get _isEditing => widget.initialItem != null;

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _currencyCode = item?.expense.currencyCode ?? 'CNY';
    final currency = SupportedCurrencies.require(_currencyCode);
    _amountController = TextEditingController(
      text: item == null
          ? ''
          : MoneyMinorUnits.format(item.expense.amountMinor, currency),
    );
    _noteController = TextEditingController(text: item?.expense.note ?? '');
    _occurredLocal = item?.occurrence.localWallClock ?? DateTime.now();
    _parentCategoryId = item?.parentCategoryId;
    _categoryId = item?.expense.categoryId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(activeCategoryTreeProvider);
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          ListTile(
            title: Text(
              _isEditing ? '编辑花销' : '记一笔',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            trailing: IconButton(
              onPressed: widget.onCancel,
              tooltip: '关闭',
              icon: const Icon(Icons.close),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: categories.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text('分类读取失败：$error')),
              data: (tree) => Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    TextFormField(
                      controller: _amountController,
                      autofocus: !_isEditing,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      decoration: const InputDecoration(
                        labelText: '金额',
                        hintText: '0.00',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        try {
                          MoneyMinorUnits.parse(
                            value ?? '',
                            SupportedCurrencies.require(_currencyCode),
                          );
                          return null;
                        } on FormatException catch (error) {
                          return error.message;
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _currencyCode,
                      decoration: const InputDecoration(
                        labelText: '货币',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        for (final currency in SupportedCurrencies.values)
                          DropdownMenuItem(
                            value: currency.code,
                            child: Text(
                              '${currency.name}（${currency.code} ${currency.symbol}）',
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _currencyCode = value);
                        _formKey.currentState?.validate();
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _parentCategoryId,
                      decoration: const InputDecoration(
                        labelText: '一级分类',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        for (final node in tree)
                          DropdownMenuItem(
                            value: node.parent.id,
                            child: Text(node.parent.name),
                          ),
                      ],
                      validator: (value) => value == null ? '请选择一级分类' : null,
                      onChanged: (value) => setState(() {
                        _parentCategoryId = value;
                        _categoryId = null;
                      }),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      key: ValueKey(_parentCategoryId),
                      initialValue: _categoryId,
                      decoration: const InputDecoration(
                        labelText: '二级分类',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        for (final node in tree.where(
                          (node) => node.parent.id == _parentCategoryId,
                        ))
                          for (final child in node.children)
                            DropdownMenuItem(
                              value: child.id,
                              child: Text(child.name),
                            ),
                      ],
                      validator: (value) => value == null ? '请选择二级分类' : null,
                      onChanged: _parentCategoryId == null
                          ? null
                          : (value) => setState(() => _categoryId = value),
                    ),
                    const SizedBox(height: 16),
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '发生时间',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(_formatDateTime(_occurredLocal)),
                          ),
                          TextButton(
                            onPressed: _pickDate,
                            child: const Text('日期'),
                          ),
                          TextButton(
                            onPressed: _pickTime,
                            child: const Text('时间'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _noteController,
                      maxLength: 500,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: '备注（可选）',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _saving ? null : widget.onCancel,
                          child: const Text('取消'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: _saving ? null : _save,
                          icon: _saving
                              ? const SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(_isEditing ? '保存修改' : '保存'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _occurredLocal,
      firstDate: DateTime(1970),
      lastDate: DateTime.now().add(const Duration(days: 366)),
    );
    if (value == null) return;
    setState(() {
      _occurredLocal = DateTime(
        value.year,
        value.month,
        value.day,
        _occurredLocal.hour,
        _occurredLocal.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final value = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_occurredLocal),
    );
    if (value == null) return;
    setState(() {
      _occurredLocal = DateTime(
        _occurredLocal.year,
        _occurredLocal.month,
        _occurredLocal.day,
        value.hour,
        value.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _categoryId == null) return;
    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    try {
      final currency = SupportedCurrencies.require(_currencyCode);
      final draft = ExpenseDraft(
        amountMinor: MoneyMinorUnits.parse(_amountController.text, currency),
        currencyCode: currency.code,
        categoryId: _categoryId!,
        occurrence: ExpenseOccurrence.fromLocal(_occurredLocal),
        note: _noteController.text,
      );
      final repository = ref.read(localExpenseRepositoryProvider);
      if (_isEditing) {
        await repository.update(widget.initialItem!.expense.id, draft);
      } else {
        await repository.create(draft);
      }
      if (!mounted) return;
      widget.onSaved(_isEditing);
    } catch (error, stackTrace) {
      AppLogging.reportError(
        source: 'expenses.save',
        safeMessage: 'Saving an expense failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

String _formatDateTime(DateTime value) {
  String two(int number) => number.toString().padLeft(2, '0');
  return '${value.year}-${two(value.month)}-${two(value.day)} ${two(value.hour)}:${two(value.minute)}';
}
