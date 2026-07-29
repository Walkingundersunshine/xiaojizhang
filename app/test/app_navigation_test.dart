import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jizhangben/app/app.dart';
import 'package:jizhangben/core/database/app_database.dart';
import 'package:jizhangben/core/database/database_providers.dart';

void main() {
  testWidgets('手机宽度使用五项底部导航并显示记一笔悬浮按钮', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final database = AppDatabase(NativeDatabase.memory());
    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) {
              ref.onDispose(database.close);
              return database;
            }),
          ],
          child: const JizhangbenApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      for (final label in ['花销', '统计', '分类', '同步', '设置']) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.widgetWithText(FloatingActionButton, '记一笔'), findsOneWidget);

      await tester.tap(find.text('同步'));
      await tester.pumpAndSettle();
      expect(find.text('局域网双向同步'), findsOneWidget);
      expect(find.text('扫描电脑二维码'), findsOneWidget);
      expect(find.text('手动输入配对信息'), findsOneWidget);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    }
  });

  testWidgets('左侧导航可以切换统计页面', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) {
              ref.onDispose(database.close);
              return database;
            }),
          ],
          child: const JizhangbenApp(),
        ),
      );

      await tester.tap(find.byIcon(Icons.donut_large_outlined));
      await tester.pumpAndSettle();

      expect(find.text('本月没有花销记录。'), findsOneWidget);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    }
  });

  testWidgets('分类管理页面读取默认分类', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) {
              ref.onDispose(database.close);
              return database;
            }),
          ],
          child: const JizhangbenApp(),
        ),
      );

      await tester.tap(find.byIcon(Icons.category_outlined));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('新增一级分类'), findsOneWidget);
      expect(find.text('餐饮'), findsOneWidget);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    }
  });

  testWidgets('记一笔按钮打开响应式录入面板', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) {
              ref.onDispose(database.close);
              return database;
            }),
          ],
          child: const JizhangbenApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.widgetWithText(FilledButton, '记一笔').first);
      await tester.pumpAndSettle();

      expect(find.text('金额'), findsOneWidget);
      expect(find.text('货币'), findsOneWidget);
      expect(find.text('一级分类'), findsOneWidget);
      expect(find.text('二级分类'), findsOneWidget);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    }
  });

  testWidgets('花销页面可以打开筛选与排序窗口', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) {
              ref.onDispose(database.close);
              return database;
            }),
          ],
          child: const JizhangbenApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.widgetWithText(OutlinedButton, '筛选与排序'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('日期范围'), findsOneWidget);
      expect(find.text('全部货币'), findsOneWidget);
      expect(find.text('全部一级分类'), findsOneWidget);
      expect(find.text('全部二级分类'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '应用'), findsOneWidget);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    }
  });

  testWidgets('设置页面显示默认本位币', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) {
              ref.onDispose(database.close);
              return database;
            }),
          ],
          child: const JizhangbenApp(),
        ),
      );

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('本位币'), findsOneWidget);
      expect(find.textContaining('人民币（CNY'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, '导出 CSV'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, '创建完整备份'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '恢复备份'), findsOneWidget);
      expect(find.text('导出诊断日志'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('开源许可证'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -160));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, '开源许可证'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Released under GNU GPL v3.0'),
        findsOneWidget,
      );
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    }
  });
}
