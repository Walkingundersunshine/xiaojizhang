import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:jizhangben/features/sync/data/pairing_qr_payload.dart';

abstract final class ManualPairingCodePolicy {
  static const length = 6;
  static const maximumFailedAttempts = 5;

  static bool isValid(String value) => RegExp(r'^\d{6}$').hasMatch(value);
}

enum PairingCredentialKind { qrToken, manualCode }

enum PairingCredentialVerification {
  accepted,
  invalid,
  expired,
  locked,
  alreadyUsed,
}

/// Secrets shown by the computer while a single pairing window is open.
final class IssuedPairingCredentials {
  IssuedPairingCredentials._({
    required this.qrPayload,
    required this.manualCode,
    required this.verifier,
  });

  final PairingQrPayload qrPayload;
  final String manualCode;
  final PairingCredentialVerifier verifier;

  factory IssuedPairingCredentials.create({
    required String deviceId,
    required String deviceName,
    required String host,
    required int port,
    required String certificateSha256,
    required DateTime issuedAt,
  }) {
    final random = Random.secure();
    final qrPayload = PairingQrPayload.create(
      deviceId: deviceId,
      deviceName: deviceName,
      host: host,
      port: port,
      certificateSha256: certificateSha256,
      issuedAt: issuedAt,
    );
    final manualCode = random
        .nextInt(1000000)
        .toString()
        .padLeft(ManualPairingCodePolicy.length, '0');
    return IssuedPairingCredentials._(
      qrPayload: qrPayload,
      manualCode: manualCode,
      verifier: PairingCredentialVerifier._create(
        qrToken: qrPayload.oneTimeToken,
        manualCode: manualCode,
        expiresAt: qrPayload.expiresAt,
        random: random,
      ),
    );
  }
}

/// Keeps only salted digests, never the QR token or manual code themselves.
final class PairingCredentialVerifier {
  PairingCredentialVerifier._({
    required this.expiresAt,
    required this._salt,
    required this._qrTokenDigest,
    required this._manualCodeDigest,
  });

  factory PairingCredentialVerifier._create({
    required String qrToken,
    required String manualCode,
    required DateTime expiresAt,
    required Random random,
  }) {
    final salt = Uint8List.fromList(
      List<int>.generate(32, (_) => random.nextInt(256)),
    );
    return PairingCredentialVerifier._(
      expiresAt: expiresAt.toUtc(),
      salt: salt,
      qrTokenDigest: _digest(salt, PairingCredentialKind.qrToken, qrToken),
      manualCodeDigest: _digest(
        salt,
        PairingCredentialKind.manualCode,
        manualCode,
      ),
    );
  }

  final DateTime expiresAt;
  final Uint8List _salt;
  final Uint8List _qrTokenDigest;
  final Uint8List _manualCodeDigest;

  var _failedAttempts = 0;
  var _consumed = false;

  int get failedAttempts => _failedAttempts;

  int get remainingAttempts =>
      ManualPairingCodePolicy.maximumFailedAttempts - _failedAttempts;

  bool get isConsumed => _consumed;

  PairingCredentialVerification verify({
    required PairingCredentialKind kind,
    required String value,
    required DateTime now,
  }) {
    if (_consumed) return PairingCredentialVerification.alreadyUsed;
    if (_failedAttempts >= ManualPairingCodePolicy.maximumFailedAttempts) {
      return PairingCredentialVerification.locked;
    }
    if (!expiresAt.isAfter(now.toUtc())) {
      return PairingCredentialVerification.expired;
    }

    final hasValidFormat = switch (kind) {
      PairingCredentialKind.qrToken => RegExp(
        r'^[A-Za-z0-9_-]{43}$',
      ).hasMatch(value),
      PairingCredentialKind.manualCode => ManualPairingCodePolicy.isValid(
        value,
      ),
    };
    final expectedDigest = switch (kind) {
      PairingCredentialKind.qrToken => _qrTokenDigest,
      PairingCredentialKind.manualCode => _manualCodeDigest,
    };
    final matches =
        hasValidFormat &&
        _constantTimeEquals(expectedDigest, _digest(_salt, kind, value));
    if (matches) {
      _consumed = true;
      return PairingCredentialVerification.accepted;
    }

    _failedAttempts += 1;
    if (_failedAttempts >= ManualPairingCodePolicy.maximumFailedAttempts) {
      return PairingCredentialVerification.locked;
    }
    return PairingCredentialVerification.invalid;
  }
}

Uint8List _digest(Uint8List salt, PairingCredentialKind kind, String value) {
  final input = BytesBuilder(copy: false)
    ..add(salt)
    ..addByte(kind.index)
    ..add(utf8.encode(value));
  return Uint8List.fromList(sha256.convert(input.takeBytes()).bytes);
}

bool _constantTimeEquals(Uint8List left, Uint8List right) {
  var difference = left.length ^ right.length;
  final length = min(left.length, right.length);
  for (var index = 0; index < length; index += 1) {
    difference |= left[index] ^ right[index];
  }
  return difference == 0;
}
