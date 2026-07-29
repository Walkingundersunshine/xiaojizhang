import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jizhangben/core/database/database_providers.dart';
import 'package:jizhangben/features/currencies/domain/currency_definition.dart';
import 'package:jizhangben/features/expenses/data/local_expense_repository.dart';
import 'package:jizhangben/features/statistics/data/statistics_service.dart';

typedef MonthKey = ({int year, int month});
typedef StatisticsRequest = ({int year, int month, String baseCurrencyCode});

final monthlyExpenseItemsProvider = StreamProvider.autoDispose
    .family<List<ExpenseListItem>, MonthKey>((ref, month) {
      final start = DateTime(month.year, month.month);
      final end = DateTime(month.year, month.month + 1);
      return ref
          .watch(localExpenseRepositoryProvider)
          .watchDetailedInLocalRange(startInclusive: start, endExclusive: end);
    });

final statisticsSummaryProvider = FutureProvider.autoDispose
    .family<StatisticsSummary, StatisticsRequest>((ref, request) async {
      final expenses = await ref.watch(
        monthlyExpenseItemsProvider((
          year: request.year,
          month: request.month,
        )).future,
      );
      final service = StatisticsService(
        ref.watch(localExchangeRateRepositoryProvider),
      );
      return service.calculate(
        expenses: expenses,
        baseCurrencyCode: request.baseCurrencyCode,
      );
    });

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final baseCurrency = ref.watch(baseCurrencyCodeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('统计'),
        actions: [
          IconButton(
            onPressed: () => setState(
              () => _month = DateTime(_month.year, _month.month - 1),
            ),
            tooltip: '上个月',
            icon: const Icon(Icons.chevron_left),
          ),
          Center(child: Text('${_month.year} 年 ${_month.month} 月')),
          IconButton(
            onPressed: () => setState(
              () => _month = DateTime(_month.year, _month.month + 1),
            ),
            tooltip: '下个月',
            icon: const Icon(Icons.chevron_right),
          ),
          TextButton(
            onPressed: () {
              final now = DateTime.now();
              setState(() => _month = DateTime(now.year, now.month));
            },
            child: const Text('本月'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: baseCurrency.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('本位币读取失败：$error')),
        data: (code) => _StatisticsBody(month: _month, baseCurrencyCode: code),
      ),
    );
  }
}

class _StatisticsBody extends ConsumerWidget {
  const _StatisticsBody({required this.month, required this.baseCurrencyCode});

  final DateTime month;
  final String baseCurrencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = (
      year: month.year,
      month: month.month,
      baseCurrencyCode: baseCurrencyCode,
    );
    final summary = ref.watch(statisticsSummaryProvider(request));
    return summary.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('统计计算失败：$error', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () =>
                  ref.invalidate(statisticsSummaryProvider(request)),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
      data: (value) {
        if (value.expenseCount == 0) {
          return const Center(child: Text('本月没有花销记录。'));
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          children: [
            _SummaryCards(summary: value),
            const SizedBox(height: 24),
            Text('原币金额', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final entry in value.originalTotalsMinor.entries)
                  _OriginalCurrencyCard(entry: entry),
              ],
            ),
            const SizedBox(height: 28),
            Text('一级分类支出', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text('按 ${value.baseCurrencyCode} 折算；MOP、TWD 不计入条形图。'),
            const SizedBox(height: 16),
            if (value.failedRateDates.isNotEmpty)
              _RateFailureCard(
                dates: value.failedRateDates,
                onRetry: () =>
                    ref.invalidate(statisticsSummaryProvider(request)),
              )
            else
              _CategoryBarChart(
                categories: value.categoryStatistics,
                baseCurrencyCode: value.baseCurrencyCode,
              ),
          ],
        );
      },
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.summary});

  final StatisticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final currency = SupportedCurrencies.require(summary.baseCurrencyCode);
    final converted = summary.convertedTotalMinor;
    final rateLabel = summary.failedRateDates.isNotEmpty
        ? '${summary.failedRateDates.length} 天汇率获取失败'
        : summary.rateSourceDates.isEmpty
        ? '本月无需换算'
        : '使用 ${summary.rateSourceDates.length} 个实际汇率日';
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _MetricCard(
          title: '本位币合计',
          value: converted == null
              ? '暂不可用'
              : '${currency.symbol}${MoneyMinorUnits.format(converted, currency)}',
          subtitle: summary.baseCurrencyCode,
          icon: Icons.account_balance_wallet_outlined,
        ),
        _MetricCard(
          title: '花销笔数',
          value: '${summary.expenseCount}',
          subtitle: '本月记录',
          icon: Icons.receipt_long_outlined,
        ),
        _MetricCard(
          title: '汇率状态',
          value: rateLabel,
          subtitle: 'Frankfurter / ECB',
          icon: Icons.currency_exchange,
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon, size: 30),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title),
                    const SizedBox(height: 4),
                    Text(value, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OriginalCurrencyCard extends StatelessWidget {
  const _OriginalCurrencyCard({required this.entry});

  final MapEntry<String, int> entry;

  @override
  Widget build(BuildContext context) {
    final currency = SupportedCurrencies.require(entry.key);
    return Chip(
      label: Text(
        '${currency.symbol}${MoneyMinorUnits.format(entry.value, currency)} ${currency.code}',
      ),
    );
  }
}

class _CategoryBarChart extends StatelessWidget {
  const _CategoryBarChart({
    required this.categories,
    required this.baseCurrencyCode,
  });

  final List<CategoryStatistic> categories;
  final String baseCurrencyCode;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const Text('没有可换算的分类金额。');
    final maximum = categories.first.amountMinor;
    final currency = SupportedCurrencies.require(baseCurrencyCode);
    return Column(
      children: [
        for (final category in categories)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(category.categoryName)),
                    Text(
                      '${currency.symbol}${MoneyMinorUnits.format(category.amountMinor, currency)}',
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: category.amountMinor / maximum,
                      child: ColoredBox(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _RateFailureCard extends StatelessWidget {
  const _RateFailureCard({required this.dates, required this.onRetry});

  final Set<String> dates;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final sorted = dates.toList()..sort();
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: ListTile(
        leading: const Icon(Icons.cloud_off_outlined),
        title: const Text('部分日期汇率不可用，未显示不完整总额'),
        subtitle: Text(sorted.join('、')),
        trailing: TextButton(onPressed: onRetry, child: const Text('重试')),
      ),
    );
  }
}
