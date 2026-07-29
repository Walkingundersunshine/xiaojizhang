import 'package:flutter/material.dart';
import 'package:jizhangben/features/sync/data/pairing_qr_payload.dart';
import 'package:jizhangben/features/sync/presentation/manual_pairing_dialog.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

typedef PairingScannerBuilder =
    Widget Function(BuildContext context, ValueChanged<String> onScanned);

class PairingScannerPage extends StatefulWidget {
  const PairingScannerPage({super.key, this.scannerBuilder});

  final PairingScannerBuilder? scannerBuilder;

  @override
  State<PairingScannerPage> createState() => _PairingScannerPageState();
}

class _PairingScannerPageState extends State<PairingScannerPage> {
  PairingQrPayload? _recognized;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('扫描电脑配对码')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _recognized == null
                      ? (widget.scannerBuilder?.call(
                              context,
                              _handleRawValue,
                            ) ??
                            _buildScanner())
                      : _buildRecognized(),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? '只识别晓记账电脑端显示的配对二维码',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => showManualPairingDialog(context),
                icon: const Icon(Icons.keyboard_outlined),
                label: const Text('相机不可用？手动输入'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanner() {
    return MobileScanner(
      controller: MobileScannerController(
        formats: const [BarcodeFormat.qrCode],
        detectionSpeed: DetectionSpeed.noDuplicates,
      ),
      onDetect: (capture) {
        for (final barcode in capture.barcodes) {
          final value = barcode.rawValue;
          if (barcode.format == BarcodeFormat.qrCode && value != null) {
            _handleRawValue(value);
            return;
          }
        }
      },
      errorBuilder: (context, error) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error.errorCode == MobileScannerErrorCode.permissionDenied
                  ? '相机权限被拒绝，请使用下方手动输入'
                  : '相机不可用，请使用下方手动输入',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      overlayBuilder: (context, constraints) => Center(
        child: Container(
          width: constraints.maxWidth * 0.72,
          height: constraints.maxWidth * 0.72,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 3),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildRecognized() {
    final payload = _recognized!;
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_user_outlined, size: 64),
              const SizedBox(height: 16),
              Text('已识别 ${payload.deviceName}'),
              const SizedBox(height: 8),
              const Text(
                '格式、安全指纹和有效期校验通过。加密连接服务完成后，下一步将在这里确认设备。',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRawValue(String value) {
    try {
      final payload = PairingQrPayload.parse(value);
      if (!mounted) return;
      setState(() {
        _recognized = payload;
        _errorMessage = null;
      });
    } on PairingQrFormatException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.message);
    }
  }
}
