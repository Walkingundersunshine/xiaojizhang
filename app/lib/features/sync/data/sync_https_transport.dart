import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:jizhangben/features/sync/data/tls_device_identity.dart';

abstract final class SyncHttpsProtocol {
  static const name = 'xiaojizhang.sync.https';
  static const version = 1;
  static const statusPath = '/xiaojizhang/v1/status';
  static const maximumStatusBytes = 4096;
}

final class SyncHttpsStatus {
  const SyncHttpsStatus({required this.protocol, required this.version});

  final String protocol;
  final int version;
}

/// A local-only HTTPS listener. Pairing and ledger routes will be added only
/// after their request validation and transaction rules are implemented.
final class SyncHttpsServer {
  SyncHttpsServer({
    required this.identity,
    this.requirePairedClientCertificate = false,
    Iterable<String> trustedClientCertificatesPem = const [],
  }) : _trustedClientCertificatesPem = List.unmodifiable(
         trustedClientCertificatesPem,
       ),
       _trustedClientFingerprints = Set.unmodifiable(
         trustedClientCertificatesPem.map(certificateFingerprint),
       ) {
    if (requirePairedClientCertificate &&
        _trustedClientCertificatesPem.isEmpty) {
      throw ArgumentError(
        '要求双向 TLS 时必须至少提供一个已配对客户端证书',
        'trustedClientCertificatesPem',
      );
    }
  }

  final TlsDeviceIdentity identity;
  final bool requirePairedClientCertificate;
  final List<String> _trustedClientCertificatesPem;
  final Set<String> _trustedClientFingerprints;
  HttpServer? _server;

  bool get isRunning => _server != null;

  InternetAddress get address =>
      _server?.address ?? (throw StateError('HTTPS 服务尚未启动'));

  int get port => _server?.port ?? (throw StateError('HTTPS 服务尚未启动'));

  Future<void> start({required InternetAddress address, int port = 0}) async {
    if (_server != null) throw StateError('HTTPS 服务已经启动');
    if (port < 0 || port > 65535) {
      throw ArgumentError.value(port, 'port', '端口必须为 0 至 65535');
    }
    final context = identity.createSecurityContext();
    if (requirePairedClientCertificate) {
      final trustedCertificates = utf8.encode(
        _trustedClientCertificatesPem.join('\n'),
      );
      context
        ..setTrustedCertificatesBytes(trustedCertificates)
        ..setClientAuthoritiesBytes(trustedCertificates);
    }
    final server = await HttpServer.bindSecure(
      address,
      port,
      context,
      requestClientCertificate: requirePairedClientCertificate,
      shared: false,
    );
    server
      ..autoCompress = false
      ..idleTimeout = const Duration(seconds: 10);
    _server = server;
    server.listen(_handleRequest, onError: (_) {}, cancelOnError: false);
  }

  Future<void> close({bool force = true}) async {
    final server = _server;
    _server = null;
    await server?.close(force: force);
  }

  Future<void> _handleRequest(HttpRequest request) async {
    final response = request.response;
    response.headers
      ..contentType = ContentType.json
      ..set(HttpHeaders.cacheControlHeader, 'no-store')
      ..set('x-content-type-options', 'nosniff');

    if (requirePairedClientCertificate) {
      final certificate = request.certificate;
      if (certificate == null) {
        response.statusCode = HttpStatus.unauthorized;
        response.write(
          jsonEncode(const {'error': 'client_certificate_required'}),
        );
        await response.close();
        return;
      }
      final fingerprint = sha256.convert(certificate.der).toString();
      if (!_trustedClientFingerprints.contains(fingerprint)) {
        response.statusCode = HttpStatus.forbidden;
        response.write(jsonEncode(const {'error': 'unpaired_client'}));
        await response.close();
        return;
      }
    }

    if (request.uri.path != SyncHttpsProtocol.statusPath) {
      response.statusCode = HttpStatus.notFound;
      response.write(jsonEncode(const {'error': 'not_found'}));
      await response.close();
      return;
    }
    if (request.method != 'GET') {
      response.statusCode = HttpStatus.methodNotAllowed;
      response.headers.set(HttpHeaders.allowHeader, 'GET');
      response.write(jsonEncode(const {'error': 'method_not_allowed'}));
      await response.close();
      return;
    }

    response.statusCode = HttpStatus.ok;
    response.write(
      jsonEncode(const {
        'protocol': SyncHttpsProtocol.name,
        'version': SyncHttpsProtocol.version,
        'status': 'ready',
      }),
    );
    await response.close();
  }
}

/// Creates a new one-shot HTTPS client per request so a certificate exception
/// can never leak into unrelated internet traffic.
final class SyncHttpsClient {
  const SyncHttpsClient();

  Future<SyncHttpsStatus> probe({
    required String host,
    required int port,
    required String expectedCertificateSha256,
    TlsDeviceIdentity? clientIdentity,
  }) async {
    if (InternetAddress.tryParse(host) == null) {
      throw ArgumentError.value(host, 'host', '连接地址必须为 IP');
    }
    if (port < 1 || port > 65535) {
      throw ArgumentError.value(port, 'port', '端口必须为 1 至 65535');
    }
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(expectedCertificateSha256)) {
      throw ArgumentError.value(
        expectedCertificateSha256,
        'expectedCertificateSha256',
        '证书指纹必须为 64 位小写十六进制文本',
      );
    }

    final client =
        HttpClient(
            context:
                clientIdentity?.createSecurityContext() ??
                SecurityContext(withTrustedRoots: false),
          )
          ..connectionTimeout = const Duration(seconds: 8)
          ..idleTimeout = const Duration(seconds: 5)
          ..badCertificateCallback =
              (certificate, certificateHost, certificatePort) {
                if (certificateHost != host || certificatePort != port) {
                  return false;
                }
                return sha256.convert(certificate.der).toString() ==
                    expectedCertificateSha256;
              };

    try {
      final uri = Uri(
        scheme: 'https',
        host: host,
        port: port,
        path: SyncHttpsProtocol.statusPath,
      );
      final request = await client.getUrl(uri);
      request.headers
        ..set(HttpHeaders.acceptHeader, ContentType.json.mimeType)
        ..set(HttpHeaders.cacheControlHeader, 'no-store');
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('HTTPS 协议状态检查失败：${response.statusCode}', uri: uri);
      }
      final bytes = BytesBuilder(copy: false);
      await for (final chunk in response) {
        bytes.add(chunk);
        if (bytes.length > SyncHttpsProtocol.maximumStatusBytes) {
          throw const FormatException('HTTPS 状态响应过长');
        }
      }
      final decoded = jsonDecode(utf8.decode(bytes.takeBytes()));
      if (decoded is! Map<String, Object?> ||
          decoded['protocol'] != SyncHttpsProtocol.name ||
          decoded['version'] != SyncHttpsProtocol.version ||
          decoded['status'] != 'ready') {
        throw const FormatException('HTTPS 状态响应格式无效');
      }
      return SyncHttpsStatus(
        protocol: decoded['protocol']! as String,
        version: decoded['version']! as int,
      );
    } finally {
      client.close(force: true);
    }
  }
}
