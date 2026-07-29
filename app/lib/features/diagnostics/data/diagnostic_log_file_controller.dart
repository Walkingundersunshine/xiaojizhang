import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:jizhangben/core/logging/app_logging.dart';
import 'package:path/path.dart' as p;

final class DiagnosticLogFileController {
  const DiagnosticLogFileController(this.manager);

  static const _jsonLinesType = XTypeGroup(
    label: 'JSON Lines 诊断日志',
    extensions: ['jsonl'],
  );

  final AppLogManager manager;

  Future<String?> export() async {
    final source = await manager.exportJsonLines();
    final location = await getSaveLocation(
      suggestedName:
          'xiaojizhang-diagnostics-${_fileTimestamp(DateTime.now())}.jsonl',
      acceptedTypeGroups: const [_jsonLinesType],
    );
    if (location == null) return null;
    final path = location.path.toLowerCase().endsWith('.jsonl')
        ? location.path
        : '${location.path}.jsonl';
    final file = XFile.fromData(
      Uint8List.fromList(utf8.encode(source)),
      mimeType: 'application/x-ndjson',
      name: p.basename(path),
    );
    await file.saveTo(path);
    return path;
  }
}

String _fileTimestamp(DateTime value) {
  String two(int number) => number.toString().padLeft(2, '0');
  return '${value.year}-${two(value.month)}-${two(value.day)}-'
      '${two(value.hour)}${two(value.minute)}${two(value.second)}';
}
