import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jizhangben/core/storage/app_storage_paths.dart';
import 'package:path/path.dart' as p;

void main() {
  test('Windows 显示名称更改后继续使用旧数据目录', () {
    final platformDirectory = Directory(
      p.join(
        'C:\\',
        'Users',
        'Test',
        'AppData',
        'Roaming',
        'com.jizhangben',
        '晓记账',
      ),
    );

    final stable = resolveStableApplicationSupportDirectory(
      platformDirectory,
      isWindows: true,
    );

    expect(
      p.normalize(stable.path),
      p.normalize(
        p.join(
          'C:\\',
          'Users',
          'Test',
          'AppData',
          'Roaming',
          'com.jizhangben',
          '记账本',
        ),
      ),
    );
  });

  test('macOS 等非 Windows 平台保持系统按 Bundle ID 分配的目录', () {
    final platformDirectory = Directory(
      p.join(
        '/',
        'Users',
        'test',
        'Library',
        'Application Support',
        'com.jizhangben.jizhangben',
      ),
    );

    final stable = resolveStableApplicationSupportDirectory(
      platformDirectory,
      isWindows: false,
    );

    expect(stable.path, platformDirectory.path);
  });
}
