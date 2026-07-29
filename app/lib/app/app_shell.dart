import 'package:flutter/material.dart';
import 'package:jizhangben/core/app_metadata.dart';
import 'package:jizhangben/features/categories/presentation/category_management_page.dart';
import 'package:jizhangben/features/expenses/presentation/expenses_page.dart';
import 'package:jizhangben/features/settings/presentation/settings_page.dart';
import 'package:jizhangben/features/statistics/presentation/statistics_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  var _selectedIndex = 0;

  static const _destinations = <NavigationRailDestination>[
    NavigationRailDestination(
      icon: Icon(Icons.receipt_long_outlined),
      selectedIcon: Icon(Icons.receipt_long),
      label: Text('花销记录'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.donut_large_outlined),
      selectedIcon: Icon(Icons.donut_large),
      label: Text('统计'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.category_outlined),
      selectedIcon: Icon(Icons.category),
      label: Text('分类管理'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: Text('设置'),
    ),
  ];

  Widget get _selectedPage => switch (_selectedIndex) {
    0 => const ExpensesPage(),
    1 => const StatisticsPage(),
    2 => const CategoryManagementPage(),
    _ => const SettingsPage(),
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final extended = constraints.maxWidth >= 900;
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                extended: extended,
                minExtendedWidth: 208,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: extended
                      ? Text(
                          AppMetadata.displayName,
                          style: Theme.of(context).textTheme.titleLarge,
                        )
                      : const Icon(Icons.account_balance_wallet_outlined),
                ),
                destinations: _destinations,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) =>
                    setState(() => _selectedIndex = index),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: KeyedSubtree(
                    key: ValueKey(_selectedIndex),
                    child: _selectedPage,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
