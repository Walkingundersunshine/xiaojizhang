import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jizhangben/core/database/app_database.dart';
import 'package:jizhangben/features/sync/data/local_paired_device_repository.dart';
import 'package:jizhangben/features/sync/data/tls_device_identity.dart';

void main() {
  late TlsDeviceIdentity firstIdentity;
  late TlsDeviceIdentity secondIdentity;
  late AppDatabase database;
  late LocalPairedDeviceRepository repository;
  final pairedAt = DateTime.utc(2026, 8, 1, 8);

  setUpAll(() async {
    final identities = await Future.wait([
      const TlsDeviceIdentityGenerator().generate(
        deviceId: 'paired-device-first',
        validityDays: 1,
      ),
      const TlsDeviceIdentityGenerator().generate(
        deviceId: 'paired-device-second',
        validityDays: 1,
      ),
    ]);
    firstIdentity = identities[0];
    secondIdentity = identities[1];
  });

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = LocalPairedDeviceRepository(database);
  });

  tearDown(() => database.close());

  test('保存公开证书并生成可供 mTLS 使用的活动信任列表', () async {
    final device = await repository.trust(
      deviceId: 'android-device-001',
      displayName: '我的手机',
      certificatePem: firstIdentity.certificatePem,
      now: pairedAt,
    );

    expect(device.certificateSha256, firstIdentity.certificateSha256);
    expect(device.pairedAtUtcMilliseconds, pairedAt.millisecondsSinceEpoch);
    expect(device.lastSyncAtUtcMilliseconds, isNull);
    expect(device.isRevoked, isFalse);
    expect(await repository.listActive(), [device]);
    expect(await repository.trustedCertificatesPem(), [
      firstIdentity.certificatePem,
    ]);
  });

  test('记录成功同步时间且拒绝更新已移除设备', () async {
    await repository.trust(
      deviceId: 'android-device-001',
      displayName: '我的手机',
      certificatePem: firstIdentity.certificatePem,
      now: pairedAt,
    );
    final syncedAt = DateTime.utc(2026, 8, 1, 9, 30);
    await repository.recordSuccessfulSync('android-device-001', syncedAt);
    expect(
      (await repository.find('android-device-001'))!.lastSyncAtUtcMilliseconds,
      syncedAt.millisecondsSinceEpoch,
    );

    await repository.revoke('android-device-001', DateTime.utc(2026, 8, 1, 10));
    await expectLater(
      repository.recordSuccessfulSync('android-device-001', syncedAt),
      throwsA(isA<PairedDeviceTrustException>()),
    );
  });

  test('移除后立即排除信任证书并保留撤销记录', () async {
    await repository.trust(
      deviceId: 'android-device-001',
      displayName: '我的手机',
      certificatePem: firstIdentity.certificatePem,
      now: pairedAt,
    );
    final revokedAt = DateTime.utc(2026, 8, 1, 10);

    await repository.revoke('android-device-001', revokedAt);

    expect(await repository.listActive(), isEmpty);
    expect(await repository.trustedCertificatesPem(), isEmpty);
    final stored = await repository.find('android-device-001');
    expect(stored!.isRevoked, isTrue);
    expect(stored.revokedAtUtcMilliseconds, revokedAt.millisecondsSinceEpoch);
  });

  test('同一证书不能属于另一设备且设备标识不能静默更换证书', () async {
    await repository.trust(
      deviceId: 'android-device-001',
      displayName: '我的手机',
      certificatePem: firstIdentity.certificatePem,
      now: pairedAt,
    );

    await expectLater(
      repository.trust(
        deviceId: 'android-device-002',
        displayName: '另一手机',
        certificatePem: firstIdentity.certificatePem,
        now: pairedAt,
      ),
      throwsA(isA<PairedDeviceTrustException>()),
    );
    await expectLater(
      repository.trust(
        deviceId: 'android-device-001',
        displayName: '我的手机',
        certificatePem: secondIdentity.certificatePem,
        now: pairedAt,
      ),
      throwsA(isA<PairedDeviceTrustException>()),
    );
  });

  test('重新配对已移除设备时恢复同一证书并清空旧同步时间', () async {
    await repository.trust(
      deviceId: 'android-device-001',
      displayName: '旧名称',
      certificatePem: firstIdentity.certificatePem,
      now: pairedAt,
    );
    await repository.recordSuccessfulSync(
      'android-device-001',
      DateTime.utc(2026, 8, 1, 9),
    );
    await repository.revoke('android-device-001', DateTime.utc(2026, 8, 1, 10));
    final repairedAt = DateTime.utc(2026, 8, 1, 11);

    final repaired = await repository.trust(
      deviceId: 'android-device-001',
      displayName: '新名称',
      certificatePem: firstIdentity.certificatePem,
      now: repairedAt,
    );

    expect(repaired.displayName, '新名称');
    expect(repaired.isRevoked, isFalse);
    expect(repaired.revokedAtUtcMilliseconds, isNull);
    expect(repaired.lastSyncAtUtcMilliseconds, isNull);
    expect(repaired.pairedAtUtcMilliseconds, repairedAt.millisecondsSinceEpoch);
  });

  test('拒绝无效设备字段和非证书内容', () async {
    await expectLater(
      repository.trust(
        deviceId: 'bad',
        displayName: '手机',
        certificatePem: firstIdentity.certificatePem,
        now: pairedAt,
      ),
      throwsA(isA<PairedDeviceTrustException>()),
    );
    await expectLater(
      repository.trust(
        deviceId: 'android-device-001',
        displayName: '手机',
        certificatePem: 'not-a-certificate',
        now: pairedAt,
      ),
      throwsA(isA<PairedDeviceTrustException>()),
    );
  });
}
