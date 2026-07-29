import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Returns the stable application-support directory used before the product
/// was renamed to 晓记账. Keeping this path prevents existing local accounts,
/// backups, and logs from appearing to disappear after the visible rename.
Future<Directory> getStableApplicationSupportDirectory() async {
  final platformDirectory = await getApplicationSupportDirectory();
  return resolveStableApplicationSupportDirectory(
    platformDirectory,
    isWindows: Platform.isWindows,
  );
}

Directory resolveStableApplicationSupportDirectory(
  Directory platformDirectory, {
  required bool isWindows,
}) {
  if (!isWindows) return platformDirectory;
  return Directory(p.join(platformDirectory.parent.path, '记账本'));
}
