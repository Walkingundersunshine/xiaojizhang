import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:basic_utils/basic_utils.dart';
import 'package:crypto/crypto.dart';

final class TlsDeviceIdentity {
  const TlsDeviceIdentity({
    required this.certificatePem,
    required this.privateKeyPem,
  });

  final String certificatePem;
  final String privateKeyPem;

  String get certificateSha256 => certificateFingerprint(certificatePem);

  SecurityContext createSecurityContext() {
    return SecurityContext(withTrustedRoots: false)
      ..useCertificateChainBytes(utf8.encode(certificatePem))
      ..usePrivateKeyBytes(utf8.encode(privateKeyPem));
  }
}

final class TlsDeviceIdentityGenerator {
  const TlsDeviceIdentityGenerator();

  Future<TlsDeviceIdentity> generate({
    required String deviceId,
    required int validityDays,
  }) {
    final normalizedDeviceId = deviceId.trim();
    if (normalizedDeviceId.isEmpty || normalizedDeviceId.length > 100) {
      throw ArgumentError.value(deviceId, 'deviceId', '设备标识长度必须为 1 至 100');
    }
    if (validityDays < 1 || validityDays > 3650) {
      throw ArgumentError.value(
        validityDays,
        'validityDays',
        '证书有效期必须为 1 至 3650 天',
      );
    }
    return Isolate.run(
      () => _generateIdentity(normalizedDeviceId, validityDays),
    );
  }
}

TlsDeviceIdentity _generateIdentity(String deviceId, int validityDays) {
  final keyPair = CryptoUtils.generateRSAKeyPair(keySize: 3072);
  final privateKey = keyPair.privateKey as RSAPrivateKey;
  final publicKey = keyPair.publicKey as RSAPublicKey;
  final distinguishedName = <String, String>{
    'CN': 'xiaojizhang-$deviceId',
    'O': 'Xiaojizhang',
  };
  final csr = X509Utils.generateRsaCsrPem(
    distinguishedName,
    privateKey,
    publicKey,
    san: const ['xiaojizhang.local'],
    signingAlgorithm: 'SHA-256',
  );
  final certificatePem = X509Utils.generateSelfSignedCertificate(
    privateKey,
    csr,
    validityDays,
    sans: const ['xiaojizhang.local'],
    keyUsage: const [KeyUsage.DIGITAL_SIGNATURE, KeyUsage.KEY_ENCIPHERMENT],
    extKeyUsage: const [
      ExtendedKeyUsage.SERVER_AUTH,
      ExtendedKeyUsage.CLIENT_AUTH,
    ],
    cA: false,
    serialNumber: _randomSerialNumber(),
    notBefore: DateTime.now().toUtc().subtract(const Duration(minutes: 5)),
  );
  final privateKeyPem = CryptoUtils.encodeRSAPrivateKeyToPem(privateKey);
  final identity = TlsDeviceIdentity(
    certificatePem: certificatePem,
    privateKeyPem: privateKeyPem,
  );
  identity.createSecurityContext();
  return identity;
}

String certificateFingerprint(String certificatePem) {
  final body = certificatePem
      .replaceAll('-----BEGIN CERTIFICATE-----', '')
      .replaceAll('-----END CERTIFICATE-----', '')
      .replaceAll(RegExp(r'\s'), '');
  if (body.isEmpty) {
    throw const FormatException('TLS 证书内容为空');
  }
  try {
    return sha256.convert(base64Decode(body)).toString();
  } on FormatException {
    throw const FormatException('TLS 证书不是有效的 PEM 内容');
  }
}

String _randomSerialNumber() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[0] &= 0x7f;
  if (bytes.every((value) => value == 0)) bytes[15] = 1;
  return BigInt.parse(
    bytes.map((value) => value.toRadixString(16).padLeft(2, '0')).join(),
    radix: 16,
  ).toString();
}
