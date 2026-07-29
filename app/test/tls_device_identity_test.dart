import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jizhangben/features/sync/data/device_identity_secret_store.dart';
import 'package:jizhangben/features/sync/data/tls_device_identity.dart';

void main() {
  late TlsDeviceIdentity identity;

  setUpAll(() async {
    identity = await const TlsDeviceIdentityGenerator().generate(
      deviceId: 'device-test-001',
      validityDays: 365,
    );
  });

  test('生成 RSA 3072 自签名证书并可载入 Flutter TLS 上下文', () {
    expect(identity.certificatePem, contains('BEGIN CERTIFICATE'));
    expect(identity.privateKeyPem, contains('BEGIN PRIVATE KEY'));
    expect(identity.certificateSha256, matches(RegExp(r'^[0-9a-f]{64}$')));
    expect(identity.createSecurityContext(), isA<SecurityContext>());
    final privateKey = CryptoUtils.rsaPrivateKeyFromPem(identity.privateKeyPem);
    expect(privateKey.modulus!.bitLength, 3072);
  });

  test('系统安全存储包装器完整保存、读取和删除 TLS 身份', () async {
    final backend = _MemorySecretBackend();
    final store = DeviceIdentitySecretStore(backend);

    await store.write(identity);
    final restored = await store.read();
    expect(restored, isNotNull);
    expect(restored!.certificateSha256, identity.certificateSha256);
    expect(restored.privateKeyPem, identity.privateKeyPem);

    await store.delete();
    expect(await store.read(), isNull);
  });

  test('安全存储只有半份身份时主动清理并要求重新配对', () async {
    final backend = _MemorySecretBackend()
      ..values['xiaojizhang.sync.tls.certificate.v1'] = 'incomplete';
    final store = DeviceIdentitySecretStore(backend);

    expect(await store.read(), isNull);
    expect(backend.values, isEmpty);
  });

  test('拒绝空证书指纹和不合理有效期', () {
    expect(() => certificateFingerprint(''), throwsFormatException);
    expect(
      () => const TlsDeviceIdentityGenerator().generate(
        deviceId: 'device',
        validityDays: 0,
      ),
      throwsArgumentError,
    );
  });
}

final class _MemorySecretBackend implements DeviceSecretBackend {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }
}
