import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:jizhangben/core/storage/app_storage_paths.dart';
import 'package:path/path.dart' as p;

typedef LogDirectoryProvider = Future<Directory> Function();
typedef LogClock = DateTime Function();

final class LocalLogStore {
  LocalLogStore({
    required this.directory,
    this.maximumFileBytes = 1024 * 1024,
    this.maximumFiles = 5,
    LogClock? clock,
  }) : _clock = clock ?? (() => DateTime.now().toUtc()) {
    if (maximumFileBytes <= 0) {
      throw ArgumentError.value(maximumFileBytes, 'maximumFileBytes');
    }
    if (maximumFiles <= 0) {
      throw ArgumentError.value(maximumFiles, 'maximumFiles');
    }
  }

  final Directory directory;
  final int maximumFileBytes;
  final int maximumFiles;
  final LogClock _clock;
  Future<void> _tail = Future<void>.value();

  Future<void> append(LogRecord record) {
    final operation = _tail.then((_) => _append(record));
    _tail = operation.catchError((Object _, StackTrace _) {});
    return operation;
  }

  Future<void> flush() => _tail;

  Future<String> exportJsonLines() async {
    await flush();
    final buffer = StringBuffer();
    for (var index = maximumFiles - 1; index >= 0; index--) {
      final file = _file(index);
      if (!await file.exists()) continue;
      final content = await file.readAsString();
      if (content.isEmpty) continue;
      buffer.write(content);
      if (!content.endsWith('\n')) buffer.write('\n');
    }
    return buffer.toString();
  }

  Future<void> _append(LogRecord record) async {
    await directory.create(recursive: true);
    final entry = <String, Object?>{
      'timestamp_utc': _clock().toIso8601String(),
      'level': record.level.name,
      'source': _limit(_sanitize(record.loggerName), 120),
      'message': _limit(_sanitize(record.message.toString()), 1000),
      if (record.error != null)
        'error_type': record.error.runtimeType.toString(),
      if (record.stackTrace != null)
        'stack_trace': _limit(_sanitize(record.stackTrace.toString()), 16000),
    };
    final bytes = utf8.encode('${jsonEncode(entry)}\n');
    final active = _file(0);
    if (await active.exists() &&
        await active.length() > 0 &&
        await active.length() + bytes.length > maximumFileBytes) {
      await _rotate();
    }
    await active.writeAsBytes(bytes, mode: FileMode.append, flush: true);
  }

  Future<void> _rotate() async {
    for (var index = maximumFiles - 1; index >= 1; index--) {
      final destination = _file(index);
      final source = _file(index - 1);
      if (await destination.exists()) await destination.delete();
      if (await source.exists()) await source.rename(destination.path);
    }
  }

  File _file(int index) => File(p.join(directory.path, 'jizhang-$index.jsonl'));
}

final class AppLogManager {
  AppLogManager(this.store);

  final LocalLogStore store;
  StreamSubscription<LogRecord>? _subscription;

  void start() {
    if (_subscription != null) return;
    Logger.root.level = Level.ALL;
    _subscription = Logger.root.onRecord.listen((record) {
      unawaited(store.append(record).catchError((Object _, StackTrace _) {}));
    });
    Logger('app.lifecycle').info('Application logging initialized');
  }

  void reportError({
    required String source,
    required String safeMessage,
    required Object error,
    StackTrace? stackTrace,
  }) {
    Logger(source).severe(safeMessage, error, stackTrace);
  }

  Future<String> exportJsonLines() => store.exportJsonLines();

  Future<void> flush() => store.flush();

  Future<void> dispose() async {
    await flush();
    await _subscription?.cancel();
    _subscription = null;
  }
}

abstract final class AppLogging {
  static AppLogManager? _manager;

  static AppLogManager? get manager => _manager;

  static Future<void> initialize({
    LogDirectoryProvider? directoryProvider,
  }) async {
    if (_manager != null) return;
    final directory = await (directoryProvider ?? _defaultLogDirectory)();
    final manager = AppLogManager(LocalLogStore(directory: directory));
    manager.start();
    _manager = manager;
  }

  static void reportError({
    required String source,
    required String safeMessage,
    required Object error,
    StackTrace? stackTrace,
  }) {
    _manager?.reportError(
      source: source,
      safeMessage: safeMessage,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static Future<Directory> _defaultLogDirectory() async {
    final support = await getStableApplicationSupportDirectory();
    return Directory(p.join(support.path, 'logs'));
  }
}

String _sanitize(String source) {
  var result = source;
  result = result.replaceAll(
    RegExp(r'file:(?:/{2,3})[^\s)]+', caseSensitive: false),
    '<path>',
  );
  result = result.replaceAll(
    RegExp(r'"[a-z]:[\\/][^"]+"', caseSensitive: false),
    '"<path>"',
  );
  result = result.replaceAll(
    RegExp(r'\b[a-z]:[\\/][^\s,;)]+', caseSensitive: false),
    '<path>',
  );
  result = result.replaceAll(
    RegExp(r'/(?:Users|home)/[^/\s]+(?:/[^\s,;)]*)?'),
    '<path>',
  );
  return result;
}

String _limit(String value, int maximumLength) {
  if (value.length <= maximumLength) return value;
  return '${value.substring(0, maximumLength)}…';
}
