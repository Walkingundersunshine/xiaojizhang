import 'package:flutter/material.dart';
import 'package:jizhangben/features/sync/data/pairing_qr_payload.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PairingQrCard extends StatelessWidget {
  const PairingQrCard({super.key, this.payload});

  final PairingQrPayload? payload;

  @override
  Widget build(BuildContext context) {
    final currentPayload = payload;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: currentPayload == null
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_2_outlined, size: 64),
                  SizedBox(height: 12),
                  Text('配对服务尚未启动，暂不生成二维码', textAlign: TextAlign.center),
                  SizedBox(height: 8),
                  Text(
                    '真实的加密监听地址准备好后，这里才会显示可扫描的短时二维码。',
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    label: '晓记账设备配对二维码',
                    image: true,
                    child: QrImageView(
                      data: currentPayload.encode(),
                      version: QrVersions.auto,
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
                      size: 240,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('设备：${currentPayload.deviceName}'),
                  Text('到期：${_formatTime(currentPayload.expiresAt)}'),
                ],
              ),
      ),
    );
  }
}

String _formatTime(DateTime value) {
  final local = value.toLocal();
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return '${twoDigits(local.hour)}:${twoDigits(local.minute)}:${twoDigits(local.second)}';
}
