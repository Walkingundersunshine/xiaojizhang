import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jizhangben/core/logging/app_logging.dart';
import 'package:logging/logging.dart';

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('jizhang-log-test-');
  });

  tearDown(() async {
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  test('JSONL 日志不保存异常正文并脱敏 Windows 和 macOS 路径', () async {
    final store = LocalLogStore(
      directory: directory,
      clock: () => DateTime.utc(2026, 7, 30, 1, 2, 3),
    );
    await store.append(
      LogRecord(
        Level.SEVERE,
        'Cannot open "C:\\Users\\Alice\\Private Folder\\secret.jizhang"',
        'settings.restore',
        const FileSystemException(
          'private failure message',
          'C:\\Users\\Alice\\Private Folder\\secret.jizhang',
        ),
        StackTrace.fromString(
          'at file:///C:/Users/Alice/project/main.dart:10\n'
          'at /Users/bob/Documents/private.dart:20',
        ),
      ),
    );

    final exported = await store.exportJsonLines();
    final entry = jsonDecode(exported.trim()) as Map<String, Object?>;
    expect(entry['timestamp_utc'], '2026-07-30T01:02:03.000Z');
    expect(entry['level'], 'SEVERE');
    expect(entry['source'], 'settings.restore');
    expect(entry['error_type'], 'FileSystemException');
    expect(exported, isNot(contains('Alice')));
    expect(exported, isNot(contains('bob')));
    expect(exported, isNot(contains('secret.jizhang')));
    expect(exported, isNot(contains('private failure message')));
    expect(exported, contains('<path>'));
  });

  test('日志超过上限后轮换且只保留指定文件数', () async {
    var tick = 0;
    final store = LocalLogStore(
      directory: directory,
      maximumFileBytes: 260,
      maximumFiles: 3,
      clock: () => DateTime.utc(2026, 7, 30).add(Duration(seconds: tick++)),
    );

    for (var index = 0; index < 12; index++) {
      await store.append(
        LogRecord(
          Level.WARNING,
          'Controlled message $index ${'x' * 60}',
          'rotation.test',
        ),
      );
    }

    final files = await directory
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.jsonl'))
        .toList();
    expect(files, hasLength(3));
    final exported = await store.exportJsonLines();
    final entries = const LineSplitter()
        .convert(exported)
        .map((line) => jsonDecode(line) as Map<String, Object?>)
        .toList();
    expect(entries.length, lessThan(12));
    expect(entries, isNotEmpty);
    final timestamps = entries
        .map((entry) => DateTime.parse(entry['timestamp_utc']! as String))
        .toList();
    expect([...timestamps]..sort(), timestamps);
    expect(entries.last['message'], contains('Controlled message 11'));
  });

  test('日志管理器只记录受控消息和错误类型', () async {
    final manager = AppLogManager(LocalLogStore(directory: directory));
    manager.start();
    manager.reportError(
      source: 'test.operation',
      safeMessage: 'Controlled diagnostic message',
      error: StateError('用户备注不应进入日志'),
      stackTrace: StackTrace.current,
    );
    await manager.flush();
    await manager.dispose();

    final exported = await manager.exportJsonLines();
    expect(exported, contains('Controlled diagnostic message'));
    expect(exported, contains('StateError'));
    expect(exported, isNot(contains('用户备注不应进入日志')));
  });
}
