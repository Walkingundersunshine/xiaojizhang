import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jizhangben/core/app_metadata.dart';
import 'package:jizhangben/core/database/database_providers.dart';
import 'package:jizhangben/core/logging/app_logging.dart';
import 'package:jizhangben/features/currencies/domain/currency_definition.dart';
import 'package:jizhangben/features/data_management/data/data_management_file_controller.dart';
import 'package:jizhangben/features/exchange_rates/domain/scaled_exchange_rate.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseCurrency = ref.watch(baseCurrencyCodeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('统计与汇率', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('本位币', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  const Text('跨币种统计默认折算到该货币。修改只影响展示，不会改变原始账目。'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 360,
                    child: baseCurrency.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (error, stackTrace) => Text('本位币读取失败：$error'),
                      data: (code) => DropdownButtonFormField<String>(
                        initialValue: code,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (final currency
                              in SupportedCurrencies.values.where(
                                (currency) => ExchangeRateRules.isConvertible(
                                  currency.code,
                                ),
                              ))
                            DropdownMenuItem(
                              value: currency.code,
                              child: Text(
                                '${currency.name}（${currency.code} ${currency.symbol}）',
                              ),
                            ),
                        ],
                        onChanged: (value) => value == null
                            ? null
                            : _setBaseCurrency(context, ref, value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '澳门元（MOP）和新台币（TWD）不在 Frankfurter 数据范围内，继续按原币单独统计。',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('数据管理', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          const _DataManagementCard(),
          const SizedBox(height: 24),
          Text('关于', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppMetadata.displayName} ${AppMetadata.version}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  const Text('本地优先、多货币桌面记账应用。'),
                  const SizedBox(height: 12),
                  const SelectableText('源代码：${AppMetadata.sourceRepository}'),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => showLicensePage(
                      context: context,
                      applicationName: AppMetadata.displayName,
                      applicationVersion: AppMetadata.version,
                      applicationLegalese:
                          'Copyright © 2026 XiaoJizhang contributors\n'
                          'Released under GNU GPL v3.0.',
                    ),
                    icon: const Icon(Icons.balance_outlined),
                    label: const Text('开源许可证'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setBaseCurrency(
    BuildContext context,
    WidgetRef ref,
    String currencyCode,
  ) async {
    try {
      await ref
          .read(localSettingsRepositoryProvider)
          .setBaseCurrencyCode(currencyCode);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('本位币已设为 $currencyCode')));
    } catch (error, stackTrace) {
      AppLogging.reportError(
        source: 'settings.currency',
        safeMessage: 'Changing base currency failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}

class _DataManagementCard extends ConsumerStatefulWidget {
  const _DataManagementCard();

  @override
  ConsumerState<_DataManagementCard> createState() =>
      _DataManagementCardState();
}

class _DataManagementCardState extends ConsumerState<_DataManagementCard> {
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('导出、备份与恢复', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            const Text(
              'CSV 使用英文技术字段，适合程序处理；完整备份使用 .jizhang 文件。恢复会替换当前账本，并先自动保存当前数据。',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  onPressed: _busy ? null : _exportCsv,
                  icon: const Icon(Icons.table_view_outlined),
                  label: const Text('导出 CSV'),
                ),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _createBackup,
                  icon: const Icon(Icons.archive_outlined),
                  label: const Text('创建完整备份'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _busy ? null : _restoreBackup,
                  icon: const Icon(Icons.restore),
                  label: const Text('恢复备份'),
                ),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _exportDiagnosticLogs,
                  icon: const Icon(Icons.bug_report_outlined),
                  label: const Text('导出诊断日志'),
                ),
              ],
            ),
            if (_busy) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _exportCsv() async {
    await _runFileAction(
      action: () => ref.read(dataManagementFileControllerProvider).exportCsv(),
      successMessage: 'CSV 已导出到',
      logSource: 'settings.export_csv',
    );
  }

  Future<void> _createBackup() async {
    await _runFileAction(
      action: () =>
          ref.read(dataManagementFileControllerProvider).createBackup(),
      successMessage: '完整备份已保存到',
      logSource: 'settings.create_backup',
    );
  }

  Future<void> _exportDiagnosticLogs() async {
    await _runFileAction(
      action: () => ref.read(diagnosticLogFileControllerProvider).export(),
      successMessage: '诊断日志已导出到',
      logSource: 'settings.export_diagnostics',
    );
  }

  Future<void> _runFileAction({
    required Future<String?> Function() action,
    required String successMessage,
    required String logSource,
  }) async {
    setState(() => _busy = true);
    try {
      final path = await action();
      if (!mounted || path == null) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$successMessage：$path')));
    } catch (error, stackTrace) {
      AppLogging.reportError(
        source: logSource,
        safeMessage: 'User-requested file operation failed',
        error: error,
        stackTrace: stackTrace,
      );
      _showError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restoreBackup() async {
    setState(() => _busy = true);
    SelectedBackup? selected;
    try {
      selected = await ref
          .read(dataManagementFileControllerProvider)
          .selectBackup();
    } catch (error, stackTrace) {
      AppLogging.reportError(
        source: 'settings.select_backup',
        safeMessage: 'Selecting or validating a backup failed',
        error: error,
        stackTrace: stackTrace,
      );
      _showError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (!mounted || selected == null) return;

    final confirmed = await _confirmRestore(selected);
    if (!mounted || !confirmed) return;
    setState(() => _busy = true);
    try {
      final result = await ref
          .read(dataManagementFileControllerProvider)
          .restore(selected);
      ref.invalidate(baseCurrencyCodeProvider);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('恢复完成'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('已恢复 ${result.preview.expenseCount} 笔花销。'),
              const SizedBox(height: 12),
              const Text('恢复前的账本已自动保存到：'),
              const SizedBox(height: 4),
              SelectableText(result.recoveryBackupPath),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('完成'),
            ),
          ],
        ),
      );
    } catch (error, stackTrace) {
      AppLogging.reportError(
        source: 'settings.restore_backup',
        safeMessage: 'Restoring a validated backup failed',
        error: error,
        stackTrace: stackTrace,
      );
      _showError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirmRestore(SelectedBackup selected) async {
    final preview = selected.preview;
    final createdAt = DateTime.fromMillisecondsSinceEpoch(
      preview.createdAtUtcMilliseconds,
      isUtc: true,
    ).toLocal();
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('用备份替换当前账本？'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('恢复后，当前账本将被完整替换。App 会先自动备份当前数据。'),
                const SizedBox(height: 12),
                Text('备份时间：${_formatDateTime(createdAt)}'),
                Text('花销：${preview.expenseCount} 笔'),
                Text('分类：${preview.categoryCount} 个'),
                Text('汇率缓存：${preview.exchangeRateCount} 条'),
                Text('本位币：${preview.baseCurrencyCode}'),
                const SizedBox(height: 12),
                Text('文件：${selected.path}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('确认替换'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
  }
}

String _formatDateTime(DateTime value) {
  String two(int number) => number.toString().padLeft(2, '0');
  return '${value.year}-${two(value.month)}-${two(value.day)} '
      '${two(value.hour)}:${two(value.minute)}:${two(value.second)}';
}
