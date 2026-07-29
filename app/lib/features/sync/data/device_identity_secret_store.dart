import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jizhangben/features/sync/data/tls_device_identity.dart';

abstract interface class DeviceSecretBackend {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);
}

final class SystemDeviceSecretBackend implements DeviceSecretBackend {
  const SystemDeviceSecretBackend([
    this._storage = const FlutterSecureStorage(),
  ]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

final class DeviceIdentitySecretStore {
  const DeviceIdentitySecretStore(this.backend);

  static const _certificateKey = 'xiaojizhang.sync.tls.certificate.v1';
  static const _privateKeyKey = 'xiaojizhang.sync.tls.private_key.v1';

  final DeviceSecretBackend backend;

  Future<TlsDeviceIdentity?> read() async {
    final values = await Future.wait([
      backend.read(_certificateKey),
      backend.read(_privateKeyKey),
    ]);
    final certificate = values[0];
    final privateKey = values[1];
    if (certificate == null && privateKey == null) return null;
    if (certificate == null || privateKey == null) {
      await delete();
      return null;
    }
    final identity = TlsDeviceIdentity(
      certificatePem: certificate,
      privateKeyPem: privateKey,
    );
    identity.createSecurityContext();
    return identity;
  }

  Future<void> write(TlsDeviceIdentity identity) async {
    identity.createSecurityContext();
    await backend.write(_certificateKey, identity.certificatePem);
    try {
      await backend.write(_privateKeyKey, identity.privateKeyPem);
    } catch (_) {
      await delete();
      rethrow;
    }
  }

  Future<void> delete() async {
    await Future.wait([
      backend.delete(_certificateKey),
      backend.delete(_privateKeyKey),
    ]);
  }
}
