import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Shared lifetime for both pairing QR payloads and the future manual code.
abstract final class PairingCredentialPolicy {
  static const validity = Duration(minutes: 2);
}

/// The only QR payload format accepted by Xiaojizhang pairing.
final class PairingQrPayload {
  const PairingQrPayload({
    required this.deviceId,
    required this.deviceName,
    required this.host,
    required this.port,
    required this.certificateSha256,
    required this.oneTimeToken,
    required this.issuedAt,
    required this.expiresAt,
  });

  static const formatVersion = 1;
  static const prefix = 'xiaojizhang-pairing:v1:';
  static const maximumEncodedLength = 2048;
  static const maximumDecodedLength = 1024;

  final String deviceId;
  final String deviceName;
  final String host;
  final int port;
  final String certificateSha256;
  final String oneTimeToken;
  final DateTime issuedAt;
  final DateTime expiresAt;

  factory PairingQrPayload.create({
    required String deviceId,
    required String deviceName,
    required String host,
    required int port,
    required String certificateSha256,
    required DateTime issuedAt,
  }) {
    final random = Random.secure();
    final tokenBytes = List<int>.generate(32, (_) => random.nextInt(256));
    final normalizedIssuedAt = issuedAt.toUtc();
    return PairingQrPayload(
      deviceId: deviceId,
      deviceName: deviceName,
      host: host,
      port: port,
      certificateSha256: certificateSha256,
      oneTimeToken: base64Url.encode(tokenBytes).replaceAll('=', ''),
      issuedAt: normalizedIssuedAt,
      expiresAt: normalizedIssuedAt.add(PairingCredentialPolicy.validity),
    ).validated(now: normalizedIssuedAt);
  }

  String encode() {
    validated(now: issuedAt);
    final document = <String, Object>{
      'v': formatVersion,
      'id': deviceId,
      'name': deviceName,
      'host': host,
      'port': port,
      'fp': certificateSha256,
      'token': oneTimeToken,
      'iat': issuedAt.toUtc().millisecondsSinceEpoch ~/ 1000,
      'exp': expiresAt.toUtc().millisecondsSinceEpoch ~/ 1000,
    };
    final bytes = utf8.encode(jsonEncode(document));
    if (bytes.length > maximumDecodedLength) {
      throw const PairingQrFormatException('配对信息过长');
    }
    final result = '$prefix${base64Url.encode(bytes).replaceAll('=', '')}';
    if (result.length > maximumEncodedLength) {
      throw const PairingQrFormatException('配对信息过长');
    }
    return result;
  }

  factory PairingQrPayload.parse(String source, {DateTime? now}) {
    if (source.isEmpty || source.length > maximumEncodedLength) {
      throw const PairingQrFormatException('二维码长度无效');
    }
    if (!source.startsWith(prefix)) {
      throw const PairingQrFormatException('不是晓记账配对二维码');
    }
    final encoded = source.substring(prefix.length);
    if (encoded.isEmpty || !RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(encoded)) {
      throw const PairingQrFormatException('二维码编码无效');
    }

    late final List<int> bytes;
    try {
      bytes = base64Url.decode(base64Url.normalize(encoded));
    } on FormatException {
      throw const PairingQrFormatException('二维码编码无效');
    }
    if (bytes.isEmpty || bytes.length > maximumDecodedLength) {
      throw const PairingQrFormatException('二维码内容长度无效');
    }

    late final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(bytes));
    } on FormatException {
      throw const PairingQrFormatException('二维码内容无效');
    }
    if (decoded is! Map<String, Object?>) {
      throw const PairingQrFormatException('二维码内容不是对象');
    }
    const requiredKeys = <String>{
      'v',
      'id',
      'name',
      'host',
      'port',
      'fp',
      'token',
      'iat',
      'exp',
    };
    if (decoded.keys.toSet().difference(requiredKeys).isNotEmpty ||
        requiredKeys.difference(decoded.keys.toSet()).isNotEmpty) {
      throw const PairingQrFormatException('二维码字段不完整');
    }
    if (decoded['v'] != formatVersion ||
        decoded['id'] is! String ||
        decoded['name'] is! String ||
        decoded['host'] is! String ||
        decoded['port'] is! int ||
        decoded['fp'] is! String ||
        decoded['token'] is! String ||
        decoded['iat'] is! int ||
        decoded['exp'] is! int) {
      throw const PairingQrFormatException('二维码字段类型或版本无效');
    }

    final payload = PairingQrPayload(
      deviceId: decoded['id']! as String,
      deviceName: decoded['name']! as String,
      host: decoded['host']! as String,
      port: decoded['port']! as int,
      certificateSha256: decoded['fp']! as String,
      oneTimeToken: decoded['token']! as String,
      issuedAt: DateTime.fromMillisecondsSinceEpoch(
        (decoded['iat']! as int) * 1000,
        isUtc: true,
      ),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        (decoded['exp']! as int) * 1000,
        isUtc: true,
      ),
    );
    return payload.validated(now: (now ?? DateTime.now()).toUtc());
  }

  PairingQrPayload validated({required DateTime now}) {
    if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9._-]{7,99}$').hasMatch(deviceId)) {
      throw const PairingQrFormatException('设备标识无效');
    }
    if (deviceName != deviceName.trim() ||
        deviceName.isEmpty ||
        utf8.encode(deviceName).length > 120 ||
        RegExp(r'[\x00-\x1f\x7f]').hasMatch(deviceName)) {
      throw const PairingQrFormatException('设备名称无效');
    }
    if (!_isPrivateIpAddress(host)) {
      throw const PairingQrFormatException('连接地址不是有效的局域网 IP');
    }
    if (port < 1024 || port > 65535) {
      throw const PairingQrFormatException('连接端口无效');
    }
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(certificateSha256)) {
      throw const PairingQrFormatException('证书指纹无效');
    }
    if (!RegExp(r'^[A-Za-z0-9_-]{43}$').hasMatch(oneTimeToken)) {
      throw const PairingQrFormatException('一次性令牌无效');
    }
    try {
      if (base64Url.decode(base64Url.normalize(oneTimeToken)).length != 32) {
        throw const PairingQrFormatException('一次性令牌长度无效');
      }
    } on FormatException {
      throw const PairingQrFormatException('一次性令牌无效');
    }
    if (!expiresAt.isAfter(issuedAt)) {
      throw const PairingQrFormatException('二维码有效期无效');
    }
    if (expiresAt.difference(issuedAt) > PairingCredentialPolicy.validity) {
      throw const PairingQrFormatException('二维码有效期过长');
    }
    final normalizedNow = now.toUtc();
    if (issuedAt.isAfter(normalizedNow.add(const Duration(minutes: 2)))) {
      throw const PairingQrFormatException('二维码签发时间无效');
    }
    if (!expiresAt.isAfter(normalizedNow)) {
      throw const PairingQrFormatException('二维码已过期');
    }
    return this;
  }
}

final class PairingQrFormatException implements FormatException {
  const PairingQrFormatException(this.message);

  @override
  final String message;

  @override
  int? get offset => null;

  @override
  String? get source => null;

  @override
  String toString() => 'PairingQrFormatException: $message';
}

bool _isPrivateIpAddress(String source) {
  final address = InternetAddress.tryParse(source);
  if (address == null || address.address != source) return false;
  final bytes = address.rawAddress;
  if (address.type == InternetAddressType.IPv4) {
    return bytes[0] == 10 ||
        (bytes[0] == 172 && bytes[1] >= 16 && bytes[1] <= 31) ||
        (bytes[0] == 192 && bytes[1] == 168) ||
        (bytes[0] == 169 && bytes[1] == 254) ||
        (bytes[0] == 100 && bytes[1] >= 64 && bytes[1] <= 127);
  }
  if (address.type == InternetAddressType.IPv6) {
    return (bytes[0] & 0xfe) == 0xfc ||
        (bytes[0] == 0xfe && (bytes[1] & 0xc0) == 0x80);
  }
  return false;
}
