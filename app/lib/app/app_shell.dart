import 'package:flutter/material.dart';
import 'package:jizhangben/core/app_metadata.dart';
import 'package:jizhangben/features/categories/presentation/category_management_page.dart';
import 'package:jizhangben/features/expenses/presentation/expenses_page.dart';
import 'package:jizhangben/features/settings/presentation/settings_page.dart';
import 'package:jizhangben/features/statistics/presentation/statistics_page.dart';
import 'package:jizhangben/features/sync/presentation/sync_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  var _selectedIndex = 0;

  static const _railDestinations = <NavigationRailDestination>[
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
      icon: Icon(Icons.sync_outlined),
      selectedIcon: Icon(Icons.sync),
      label: Text('同步'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: Text('设置'),
    ),
  ];

  static const _barDestinations = <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.receipt_long_outlined),
      selectedIcon: Icon(Icons.receipt_long),
      label: '花销',
    ),
    NavigationDestination(
      icon: Icon(Icons.donut_large_outlined),
      selectedIcon: Icon(Icons.donut_large),
      label: '统计',
    ),
    NavigationDestination(
      icon: Icon(Icons.category_outlined),
      selectedIcon: Icon(Icons.category),
      label: '分类',
    ),
    NavigationDestination(
      icon: Icon(Icons.sync_outlined),
      selectedIcon: Icon(Icons.sync),
      label: '同步',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: '设置',
    ),
  ];

  Widget _selectedPage({required bool useBottomNavigation}) =>
      switch (_selectedIndex) {
        0 => ExpensesPage(useMobileLayout: useBottomNavigation),
        1 => const StatisticsPage(),
        2 => const CategoryManagementPage(),
        3 => const SyncPage(),
        _ => const SettingsPage(),
      };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useBottomNavigation = constraints.maxWidth < 720;
        if (useBottomNavigation) {
          return Scaffold(
            body: _animatedSelectedPage(useBottomNavigation: true),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              destinations: _barDestinations,
              onDestinationSelected: _selectDestination,
            ),
          );
        }

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
                destinations: _railDestinations,
                selectedIndex: _selectedIndex,
                onDestinationSelected: _selectDestination,
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: _animatedSelectedPage(useBottomNavigation: false),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _animatedSelectedPage({required bool useBottomNavigation}) =>
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: _selectedPage(useBottomNavigation: useBottomNavigation),
        ),
      );

  void _selectDestination(int index) {
    setState(() => _selectedIndex = index);
  }
}
