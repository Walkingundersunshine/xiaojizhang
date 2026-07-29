import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jizhangben/features/sync/data/sync_https_transport.dart';
import 'package:jizhangben/features/sync/data/tls_device_identity.dart';

void main() {
  late TlsDeviceIdentity identity;
  late SyncHttpsServer server;

  setUpAll(() async {
    identity = await const TlsDeviceIdentityGenerator().generate(
      deviceId: 'https-test-device',
      validityDays: 1,
    );
  });

  setUp(() async {
    server = SyncHttpsServer(identity: identity);
    await server.start(address: InternetAddress.loopbackIPv4);
  });

  tearDown(() => server.close());

  test('真实 HTTPS 连接只在证书 SHA-256 指纹一致时成功', () async {
    final status = await const SyncHttpsClient().probe(
      host: server.address.address,
      port: server.port,
      expectedCertificateSha256: identity.certificateSha256,
    );

    expect(status.protocol, SyncHttpsProtocol.name);
    expect(status.version, SyncHttpsProtocol.version);
    expect(server.isRunning, isTrue);
  });

  test('错误证书指纹不能绕过自签名证书校验', () async {
    await expectLater(
      const SyncHttpsClient().probe(
        host: server.address.address,
        port: server.port,
        expectedCertificateSha256: List.filled(64, '0').join(),
      ),
      throwsA(anyOf(isA<HandshakeException>(), isA<SocketException>())),
    );
  });

  test('客户端拒绝域名、错误端口和错误格式指纹', () async {
    await expectLater(
      const SyncHttpsClient().probe(
        host: 'example.com',
        port: server.port,
        expectedCertificateSha256: identity.certificateSha256,
      ),
      throwsArgumentError,
    );
    await expectLater(
      const SyncHttpsClient().probe(
        host: server.address.address,
        port: 0,
        expectedCertificateSha256: identity.certificateSha256,
      ),
      throwsArgumentError,
    );
    await expectLater(
      const SyncHttpsClient().probe(
        host: server.address.address,
        port: server.port,
        expectedCertificateSha256: 'invalid',
      ),
      throwsArgumentError,
    );
  });

  test('服务停止后不再接受新连接', () async {
    final closedPort = server.port;
    await server.close();

    expect(server.isRunning, isFalse);
    await expectLater(
      const SyncHttpsClient().probe(
        host: InternetAddress.loopbackIPv4.address,
        port: closedPort,
        expectedCertificateSha256: identity.certificateSha256,
      ),
      throwsA(isA<SocketException>()),
    );
  });

  test('未知地址和错误请求方式分别返回 404 与 405', () async {
    final client = HttpClient(context: SecurityContext(withTrustedRoots: false))
      ..badCertificateCallback = (certificate, host, port) {
        return host == server.address.address &&
            port == server.port &&
            sha256.convert(certificate.der).toString() ==
                identity.certificateSha256;
      };
    try {
      final base = Uri(
        scheme: 'https',
        host: server.address.address,
        port: server.port,
      );
      final unknownRequest = await client.getUrl(
        base.replace(path: '/unknown'),
      );
      final unknownResponse = await unknownRequest.close();
      expect(unknownResponse.statusCode, HttpStatus.notFound);
      await unknownResponse.drain<void>();

      final methodRequest = await client.postUrl(
        base.replace(path: SyncHttpsProtocol.statusPath),
      );
      final methodResponse = await methodRequest.close();
      expect(methodResponse.statusCode, HttpStatus.methodNotAllowed);
      expect(methodResponse.headers.value(HttpHeaders.allowHeader), 'GET');
      await methodResponse.drain<void>();
    } finally {
      client.close(force: true);
    }
  });
}
