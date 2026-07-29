import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:jizhangben/features/data_management/data/data_management_service.dart';
import 'package:path/path.dart' as p;

final class SelectedBackup {
  const SelectedBackup({
    required this.path,
    required this.source,
    required this.preview,
  });

  final String path;
  final String source;
  final BackupPreview preview;
}

final class DataManagementFileController {
  const DataManagementFileController(this.service);

  static const _csvType = XTypeGroup(label: 'CSV', extensions: ['csv']);
  static const _backupType = XTypeGroup(
    label: '晓记账备份',
    extensions: ['jizhang'],
  );

  final DataManagementService service;

  Future<String?> exportCsv() async {
    final source = await service.createCsv();
    return _saveText(
      source: source,
      suggestedName: 'expenses-${_fileTimestamp(DateTime.now())}.csv',
      extension: 'csv',
      mimeType: 'text/csv',
      acceptedType: _csvType,
    );
  }

  Future<String?> createBackup() async {
    final source = await service.createBackupJson();
    return _saveText(
      source: source,
      suggestedName:
          'xiaojizhang-backup-${_fileTimestamp(DateTime.now())}.jizhang',
      extension: 'jizhang',
      mimeType: 'application/json',
      acceptedType: _backupType,
    );
  }

  Future<SelectedBackup?> selectBackup() async {
    final file = await openFile(acceptedTypeGroups: const [_backupType]);
    if (file == null) return null;
    if (await file.length() > DataManagementService.maximumBackupBytes) {
      throw const BackupFormatException('文件超过 100 MB 上限');
    }
    final source = await file.readAsString();
    return SelectedBackup(
      path: file.path,
      source: source,
      preview: service.inspectBackupJson(source),
    );
  }

  Future<RestoreResult> restore(SelectedBackup backup) {
    return service.restoreFromJson(backup.source);
  }

  Future<String?> _saveText({
    required String source,
    required String suggestedName,
    required String extension,
    required String mimeType,
    required XTypeGroup acceptedType,
  }) async {
    final location = await getSaveLocation(
      suggestedName: suggestedName,
      acceptedTypeGroups: [acceptedType],
    );
    if (location == null) return null;
    final path = location.path.toLowerCase().endsWith('.$extension')
        ? location.path
        : '${location.path}.$extension';
    final file = XFile.fromData(
      Uint8List.fromList(utf8.encode(source)),
      mimeType: mimeType,
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
