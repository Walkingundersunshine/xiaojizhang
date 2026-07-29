import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jizhangben/app/app.dart';
import 'package:jizhangben/core/database/app_database.dart';
import 'package:jizhangben/core/database/database_providers.dart';

void main() {
  testWidgets('显示晓记账工程外壳', (tester) async {
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

      expect(find.text('花销记录'), findsWidgets);
      expect(find.text('还没有花销记录'), findsOneWidget);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    }
  });
}
