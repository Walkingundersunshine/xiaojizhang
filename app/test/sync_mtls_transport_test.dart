import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jizhangben/features/sync/data/sync_https_transport.dart';
import 'package:jizhangben/features/sync/data/tls_device_identity.dart';

void main() {
  late TlsDeviceIdentity serverIdentity;
  late TlsDeviceIdentity pairedClientIdentity;
  late TlsDeviceIdentity unpairedClientIdentity;
  late SyncHttpsServer server;

  setUpAll(() async {
    final identities = await Future.wait([
      const TlsDeviceIdentityGenerator().generate(
        deviceId: 'mtls-server',
        validityDays: 1,
      ),
      const TlsDeviceIdentityGenerator().generate(
        deviceId: 'mtls-paired-client',
        validityDays: 1,
      ),
      const TlsDeviceIdentityGenerator().generate(
        deviceId: 'mtls-unpaired-client',
        validityDays: 1,
      ),
    ]);
    serverIdentity = identities[0];
    pairedClientIdentity = identities[1];
    unpairedClientIdentity = identities[2];
  });

  setUp(() async {
    server = SyncHttpsServer(
      identity: serverIdentity,
      requirePairedClientCertificate: true,
      trustedClientCertificatesPem: [pairedClientIdentity.certificatePem],
    );
    await server.start(address: InternetAddress.loopbackIPv4);
  });

  tearDown(() => server.close());

  test('已配对客户端出示证书后完成双向 TLS', () async {
    final status = await const SyncHttpsClient().probe(
      host: server.address.address,
      port: server.port,
      expectedCertificateSha256: serverIdentity.certificateSha256,
      clientIdentity: pairedClientIdentity,
    );

    expect(status.protocol, SyncHttpsProtocol.name);
    expect(status.version, SyncHttpsProtocol.version);
  });

  test('没有客户端证书时不能访问已配对同步服务', () async {
    await expectLater(
      const SyncHttpsClient().probe(
        host: server.address.address,
        port: server.port,
        expectedCertificateSha256: serverIdentity.certificateSha256,
      ),
      throwsA(anyOf(isA<HttpException>(), isA<HandshakeException>())),
    );
  });

  test('未配对客户端证书不能通过双向 TLS 握手', () async {
    await expectLater(
      const SyncHttpsClient().probe(
        host: server.address.address,
        port: server.port,
        expectedCertificateSha256: serverIdentity.certificateSha256,
        clientIdentity: unpairedClientIdentity,
      ),
      throwsA(
        anyOf(
          isA<HandshakeException>(),
          isA<SocketException>(),
          isA<HttpException>(),
        ),
      ),
    );
  });

  test('双向 TLS 模式必须提供至少一个受信任证书', () {
    expect(
      () => SyncHttpsServer(
        identity: serverIdentity,
        requirePairedClientCertificate: true,
      ),
      throwsArgumentError,
    );
  });
}
