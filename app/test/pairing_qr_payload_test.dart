import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jizhangben/features/sync/data/pairing_qr_payload.dart';

void main() {
  final issuedAt = DateTime.utc(2026, 7, 30, 10);
  const fingerprint =
      '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
  const token = 'AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8';

  PairingQrPayload validPayload() => PairingQrPayload(
    deviceId: 'device-12345678',
    deviceName: '书房电脑',
    host: '192.168.1.20',
    port: 45678,
    certificateSha256: fingerprint,
    oneTimeToken: token,
    issuedAt: issuedAt,
    expiresAt: issuedAt.add(PairingCredentialPolicy.validity),
  );

  test('严格往返晓记账 v1 配对载荷', () {
    final encoded = validPayload().encode();
    final decoded = PairingQrPayload.parse(
      encoded,
      now: issuedAt.add(const Duration(minutes: 1)),
    );

    expect(encoded, startsWith(PairingQrPayload.prefix));
    expect(decoded.deviceId, 'device-12345678');
    expect(decoded.deviceName, '书房电脑');
    expect(decoded.host, '192.168.1.20');
    expect(decoded.port, 45678);
    expect(decoded.certificateSha256, fingerprint);
    expect(decoded.oneTimeToken, token);
  });

  test('生成一次性 256 位随机令牌并固定两分钟有效期', () {
    final first = PairingQrPayload.create(
      deviceId: 'device-12345678',
      deviceName: '电脑',
      host: '10.0.0.8',
      port: 45678,
      certificateSha256: fingerprint,
      issuedAt: issuedAt,
    );
    final second = PairingQrPayload.create(
      deviceId: 'device-12345678',
      deviceName: '电脑',
      host: '10.0.0.8',
      port: 45678,
      certificateSha256: fingerprint,
      issuedAt: issuedAt,
    );

    expect(PairingCredentialPolicy.validity, const Duration(minutes: 2));
    expect(
      first.expiresAt.difference(first.issuedAt),
      const Duration(minutes: 2),
    );
    expect(first.oneTimeToken, hasLength(43));
    expect(
      base64Url.decode(base64Url.normalize(first.oneTimeToken)),
      hasLength(32),
    );
    expect(first.oneTimeToken, isNot(second.oneTimeToken));
  });

  test('拒绝普通 URL 和其他二维码内容', () {
    for (final value in ['https://example.com/pair', '{"v":1}', 'plain text']) {
      expect(
        () => PairingQrPayload.parse(value, now: issuedAt),
        throwsA(isA<PairingQrFormatException>()),
      );
    }
  });

  test('拒绝过期、未来签发和超长有效期', () {
    expect(
      () => PairingQrPayload.parse(
        validPayload().encode(),
        now: issuedAt.add(PairingCredentialPolicy.validity),
      ),
      throwsA(
        isA<PairingQrFormatException>().having(
          (error) => error.message,
          'message',
          contains('过期'),
        ),
      ),
    );

    final future = PairingQrPayload(
      deviceId: 'device-12345678',
      deviceName: '电脑',
      host: '192.168.1.20',
      port: 45678,
      certificateSha256: fingerprint,
      oneTimeToken: token,
      issuedAt: issuedAt.add(const Duration(minutes: 3)),
      expiresAt: issuedAt.add(const Duration(minutes: 5)),
    );
    final futureSource = _encodeUnchecked(future);
    expect(
      () => PairingQrPayload.parse(futureSource, now: issuedAt),
      throwsA(isA<PairingQrFormatException>()),
    );

    final longLived = PairingQrPayload(
      deviceId: 'device-12345678',
      deviceName: '电脑',
      host: '192.168.1.20',
      port: 45678,
      certificateSha256: fingerprint,
      oneTimeToken: token,
      issuedAt: issuedAt,
      expiresAt: issuedAt.add(const Duration(minutes: 3)),
    );
    expect(
      () => PairingQrPayload.parse(_encodeUnchecked(longLived), now: issuedAt),
      throwsA(isA<PairingQrFormatException>()),
    );
  });

  test('仅接受局域网 IP 字面量和非特权端口', () {
    for (final host in ['example.com', '8.8.8.8', '127.0.0.1', '0.0.0.0']) {
      final payload = PairingQrPayload(
        deviceId: 'device-12345678',
        deviceName: '电脑',
        host: host,
        port: 45678,
        certificateSha256: fingerprint,
        oneTimeToken: token,
        issuedAt: issuedAt,
        expiresAt: issuedAt.add(PairingCredentialPolicy.validity),
      );
      expect(
        () => PairingQrPayload.parse(_encodeUnchecked(payload), now: issuedAt),
        throwsA(isA<PairingQrFormatException>()),
      );
    }

    final payload = PairingQrPayload(
      deviceId: 'device-12345678',
      deviceName: '电脑',
      host: '192.168.1.20',
      port: 443,
      certificateSha256: fingerprint,
      oneTimeToken: token,
      issuedAt: issuedAt,
      expiresAt: issuedAt.add(PairingCredentialPolicy.validity),
    );
    expect(
      () => PairingQrPayload.parse(_encodeUnchecked(payload), now: issuedAt),
      throwsA(isA<PairingQrFormatException>()),
    );
  });

  test('拒绝错误指纹、低熵令牌和未知字段', () {
    final document = _document(validPayload())
      ..['fp'] = List.filled(32, 'AA').join()
      ..['token'] = '123456';
    expect(
      () => PairingQrPayload.parse(_encodeDocument(document), now: issuedAt),
      throwsA(isA<PairingQrFormatException>()),
    );

    final withUnknownField = _document(validPayload())..['url'] = 'https://x';
    expect(
      () => PairingQrPayload.parse(
        _encodeDocument(withUnknownField),
        now: issuedAt,
      ),
      throwsA(isA<PairingQrFormatException>()),
    );
  });

  test('在解析 JSON 前拒绝超长输入', () {
    final source = '${PairingQrPayload.prefix}${'A' * 3000}';
    expect(
      () => PairingQrPayload.parse(source, now: issuedAt),
      throwsA(isA<PairingQrFormatException>()),
    );
  });
}

String _encodeUnchecked(PairingQrPayload payload) =>
    _encodeDocument(_document(payload));

Map<String, Object> _document(PairingQrPayload payload) => <String, Object>{
  'v': PairingQrPayload.formatVersion,
  'id': payload.deviceId,
  'name': payload.deviceName,
  'host': payload.host,
  'port': payload.port,
  'fp': payload.certificateSha256,
  'token': payload.oneTimeToken,
  'iat': payload.issuedAt.millisecondsSinceEpoch ~/ 1000,
  'exp': payload.expiresAt.millisecondsSinceEpoch ~/ 1000,
};

String _encodeDocument(Map<String, Object> document) =>
    '${PairingQrPayload.prefix}${base64Url.encode(utf8.encode(jsonEncode(document))).replaceAll('=', '')}';
