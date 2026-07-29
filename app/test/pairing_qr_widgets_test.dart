import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jizhangben/features/sync/data/pairing_qr_payload.dart';
import 'package:jizhangben/features/sync/presentation/pairing_qr_card.dart';
import 'package:jizhangben/features/sync/presentation/pairing_scanner_page.dart';
import 'package:jizhangben/features/sync/presentation/sync_page.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  final issuedAt = DateTime.now().toUtc();
  final payload = PairingQrPayload(
    deviceId: 'device-12345678',
    deviceName: '书房电脑',
    host: '192.168.1.20',
    port: 45678,
    certificateSha256:
        '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
    oneTimeToken: 'AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8',
    issuedAt: issuedAt,
    expiresAt: issuedAt.add(const Duration(minutes: 5)),
  );

  testWidgets('监听服务未启动时不显示伪造二维码', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: PairingQrCard())),
    );

    expect(find.byType(QrImageView), findsNothing);
    expect(find.textContaining('暂不生成二维码'), findsOneWidget);
  });

  testWidgets('真实载荷可由 qr_flutter 绘制并标记设备', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PairingQrCard(payload: payload)),
      ),
    );

    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('设备：书房电脑'), findsOneWidget);
    expect(tester.widget<QrImageView>(find.byType(QrImageView)).size, 240);
  });

  testWidgets('安卓同步页提供主动扫码和手动输入入口', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SyncPage(isAndroid: true)));

    expect(find.text('扫描电脑二维码'), findsOneWidget);
    expect(find.text('手动输入配对信息'), findsOneWidget);
    expect(find.byType(QrImageView), findsNothing);

    await tester.tap(find.text('手动输入配对信息'));
    await tester.pumpAndSettle();
    expect(find.text('一次性短码'), findsOneWidget);
    expect(find.text('等待配对服务'), findsOneWidget);
  });

  testWidgets('扫码页拒绝普通网址并接受严格载荷', (tester) async {
    late ValueChanged<String> scan;
    await tester.pumpWidget(
      MaterialApp(
        home: PairingScannerPage(
          scannerBuilder: (context, onScanned) {
            scan = onScanned;
            return const ColoredBox(color: Colors.black);
          },
        ),
      ),
    );

    scan('https://example.com');
    await tester.pump();
    expect(find.text('不是晓记账配对二维码'), findsOneWidget);

    scan(payload.encode());
    await tester.pump();
    expect(find.text('已识别 书房电脑'), findsOneWidget);
    expect(find.textContaining('格式、安全指纹和有效期校验通过'), findsOneWidget);
  });
}
