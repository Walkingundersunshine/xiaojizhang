import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:jizhangben/core/database/app_database.dart';
import 'package:jizhangben/features/sync/data/tls_device_identity.dart';

final class PairedDeviceTrustException implements Exception {
  const PairedDeviceTrustException(this.message);

  final String message;

  @override
  String toString() => '已配对设备无效：$message';
}

final class LocalPairedDeviceRepository {
  const LocalPairedDeviceRepository(this.database);

  final AppDatabase database;

  Future<PairedDevice> trust({
    required String deviceId,
    required String displayName,
    required String certificatePem,
    required DateTime now,
  }) async {
    final normalizedId = deviceId.trim();
    final normalizedName = displayName.trim();
    _validateDeviceId(normalizedId);
    _validateDisplayName(normalizedName);
    _validateCertificate(certificatePem);
    final fingerprint = certificateFingerprint(certificatePem);
    final timestamp = now.toUtc().millisecondsSinceEpoch;

    return database.transaction(() async {
      final duplicate =
          await (database.select(database.pairedDevices)..where(
                (row) =>
                    row.certificateSha256.equals(fingerprint) &
                    row.deviceId.equals(normalizedId).not(),
              ))
              .getSingleOrNull();
      if (duplicate != null) {
        throw const PairedDeviceTrustException('同一证书已经属于另一台设备');
      }

      final existing = await find(normalizedId);
      if (existing != null && existing.certificateSha256 != fingerprint) {
        throw const PairedDeviceTrustException('设备标识对应的证书已经变化，必须使用新设备标识重新配对');
      }
      await database
          .into(database.pairedDevices)
          .insertOnConflictUpdate(
            PairedDevicesCompanion.insert(
              deviceId: normalizedId,
              displayName: normalizedName,
              certificatePem: certificatePem,
              certificateSha256: fingerprint,
              pairedAtUtcMilliseconds: existing == null || existing.isRevoked
                  ? timestamp
                  : existing.pairedAtUtcMilliseconds,
              lastSyncAtUtcMilliseconds: existing == null || existing.isRevoked
                  ? const Value(null)
                  : Value(existing.lastSyncAtUtcMilliseconds),
              isRevoked: const Value(false),
              revokedAtUtcMilliseconds: const Value(null),
            ),
          );
      return (database.select(
        database.pairedDevices,
      )..where((row) => row.deviceId.equals(normalizedId))).getSingle();
    });
  }

  Future<PairedDevice?> find(String deviceId) {
    return (database.select(
      database.pairedDevices,
    )..where((row) => row.deviceId.equals(deviceId))).getSingleOrNull();
  }

  Future<List<PairedDevice>> listActive() {
    return (database.select(database.pairedDevices)
          ..where((row) => row.isRevoked.equals(false))
          ..orderBy([
            (row) => OrderingTerm.asc(row.displayName),
            (row) => OrderingTerm.asc(row.deviceId),
          ]))
        .get();
  }

  Stream<List<PairedDevice>> watchAll() {
    return (database.select(database.pairedDevices)..orderBy([
          (row) => OrderingTerm.asc(row.isRevoked),
          (row) => OrderingTerm.asc(row.displayName),
          (row) => OrderingTerm.asc(row.deviceId),
        ]))
        .watch();
  }

  Future<List<String>> trustedCertificatesPem() async {
    return [for (final device in await listActive()) device.certificatePem];
  }

  Future<void> recordSuccessfulSync(
    String deviceId,
    DateTime occurredAt,
  ) async {
    final updated =
        await (database.update(database.pairedDevices)..where(
              (row) =>
                  row.deviceId.equals(deviceId) & row.isRevoked.equals(false),
            ))
            .write(
              PairedDevicesCompanion(
                lastSyncAtUtcMilliseconds: Value(
                  occurredAt.toUtc().millisecondsSinceEpoch,
                ),
              ),
            );
    if (updated != 1) {
      throw const PairedDeviceTrustException('设备不存在或已经移除');
    }
  }

  Future<void> revoke(String deviceId, DateTime revokedAt) async {
    final updated =
        await (database.update(database.pairedDevices)..where(
              (row) =>
                  row.deviceId.equals(deviceId) & row.isRevoked.equals(false),
            ))
            .write(
              PairedDevicesCompanion(
                isRevoked: const Value(true),
                revokedAtUtcMilliseconds: Value(
                  revokedAt.toUtc().millisecondsSinceEpoch,
                ),
              ),
            );
    if (updated != 1) {
      throw const PairedDeviceTrustException('设备不存在或已经移除');
    }
  }
}

void _validateDeviceId(String value) {
  if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9._-]{7,99}$').hasMatch(value)) {
    throw const PairedDeviceTrustException('设备标识格式错误');
  }
}

void _validateDisplayName(String value) {
  if (value.isEmpty ||
      value.length > 60 ||
      utf8.encode(value).length > 120 ||
      RegExp(r'[\x00-\x1f\x7f]').hasMatch(value)) {
    throw const PairedDeviceTrustException('设备名称格式错误');
  }
}

void _validateCertificate(String value) {
  if (utf8.encode(value).length > 16384) {
    throw const PairedDeviceTrustException('设备证书过长');
  }
  try {
    certificateFingerprint(value);
    SecurityContext(
      withTrustedRoots: false,
    ).setTrustedCertificatesBytes(utf8.encode(value));
  } on Exception {
    throw const PairedDeviceTrustException('设备证书格式错误');
  }
}
