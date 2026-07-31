import 'package:flutter_test/flutter_test.dart';
import 'package:jizhangben/features/sync/data/pairing_credentials.dart';
import 'package:jizhangben/features/sync/data/pairing_qr_payload.dart';

void main() {
  final issuedAt = DateTime.utc(2026, 7, 31, 10);
  const fingerprint =
      '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

  IssuedPairingCredentials issue() => IssuedPairingCredentials.create(
    deviceId: 'device-12345678',
    deviceName: '书房电脑',
    host: '192.168.1.20',
    port: 45678,
    certificateSha256: fingerprint,
    issuedAt: issuedAt,
  );

  test('生成六位数字短码并与二维码共用两分钟期限', () {
    final credentials = issue();

    expect(credentials.manualCode, matches(RegExp(r'^\d{6}$')));
    expect(ManualPairingCodePolicy.length, 6);
    expect(ManualPairingCodePolicy.maximumFailedAttempts, 5);
    expect(
      credentials.qrPayload.expiresAt.difference(issuedAt),
      PairingCredentialPolicy.validity,
    );
    expect(credentials.verifier.expiresAt, credentials.qrPayload.expiresAt);
  });

  test('二维码令牌验证成功后立即单次作废', () {
    final credentials = issue();
    final verifier = credentials.verifier;

    expect(
      verifier.verify(
        kind: PairingCredentialKind.qrToken,
        value: credentials.qrPayload.oneTimeToken,
        now: issuedAt,
      ),
      PairingCredentialVerification.accepted,
    );
    expect(verifier.isConsumed, isTrue);
    expect(
      verifier.verify(
        kind: PairingCredentialKind.qrToken,
        value: credentials.qrPayload.oneTimeToken,
        now: issuedAt,
      ),
      PairingCredentialVerification.alreadyUsed,
    );
  });

  test('六位手动短码验证成功后同时作废二维码令牌', () {
    final credentials = issue();
    final verifier = credentials.verifier;

    expect(
      verifier.verify(
        kind: PairingCredentialKind.manualCode,
        value: credentials.manualCode,
        now: issuedAt,
      ),
      PairingCredentialVerification.accepted,
    );
    expect(
      verifier.verify(
        kind: PairingCredentialKind.qrToken,
        value: credentials.qrPayload.oneTimeToken,
        now: issuedAt,
      ),
      PairingCredentialVerification.alreadyUsed,
    );
  });

  test('第五次失败立即锁定且正确短码也不能继续使用', () {
    final credentials = issue();
    final verifier = credentials.verifier;
    final wrongCode = credentials.manualCode == '000000' ? '000001' : '000000';

    for (var attempt = 1; attempt <= 4; attempt += 1) {
      expect(
        verifier.verify(
          kind: PairingCredentialKind.manualCode,
          value: wrongCode,
          now: issuedAt,
        ),
        PairingCredentialVerification.invalid,
      );
    }
    expect(verifier.remainingAttempts, 1);
    expect(
      verifier.verify(
        kind: PairingCredentialKind.manualCode,
        value: 'not-six-digits',
        now: issuedAt,
      ),
      PairingCredentialVerification.locked,
    );
    expect(verifier.failedAttempts, 5);
    expect(verifier.remainingAttempts, 0);
    expect(
      verifier.verify(
        kind: PairingCredentialKind.manualCode,
        value: credentials.manualCode,
        now: issuedAt,
      ),
      PairingCredentialVerification.locked,
    );
  });

  test('到达两分钟边界后二维码和短码都过期', () {
    final credentials = issue();

    expect(
      credentials.verifier.verify(
        kind: PairingCredentialKind.manualCode,
        value: credentials.manualCode,
        now: issuedAt.add(PairingCredentialPolicy.validity),
      ),
      PairingCredentialVerification.expired,
    );
    expect(credentials.verifier.failedAttempts, 0);
  });
}
