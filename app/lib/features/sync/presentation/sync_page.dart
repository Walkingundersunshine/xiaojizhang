import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:jizhangben/features/sync/presentation/manual_pairing_dialog.dart';
import 'package:jizhangben/features/sync/presentation/pairing_qr_card.dart';
import 'package:jizhangben/features/sync/presentation/pairing_scanner_page.dart';

class SyncPage extends StatelessWidget {
  const SyncPage({super.key, this.isAndroid});

  final bool? isAndroid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('局域网同步')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sync_lock_outlined,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '局域网双向同步',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '手机和电脑将在同一 Wi-Fi 下，由你主动发起同步。只有同一笔账在两端都变化时，才会显示差异并由你选择保留哪一版。',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  if (isAndroid ??
                      defaultTargetPlatform == TargetPlatform.android)
                    _AndroidPairingActions()
                  else
                    const PairingQrCard(),
                  const SizedBox(height: 12),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.security_outlined),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text('二维码只在本地处理，不会打开链接或上传扫码内容。安全连接服务仍在实现中。'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AndroidPairingActions extends StatelessWidget {
  const _AndroidPairingActions();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('与电脑配对'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => const PairingScannerPage()),
              ),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('扫描电脑二维码'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => showManualPairingDialog(context),
              icon: const Icon(Icons.keyboard_outlined),
              label: const Text('手动输入配对信息'),
            ),
          ],
        ),
      ),
    );
  }
}
