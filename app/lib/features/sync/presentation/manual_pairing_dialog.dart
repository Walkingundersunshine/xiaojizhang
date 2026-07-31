import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jizhangben/features/sync/data/pairing_credentials.dart';

Future<void> showManualPairingDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => const _ManualPairingDialog(),
);

class _ManualPairingDialog extends StatelessWidget {
  const _ManualPairingDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('手动输入配对信息'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: '电脑显示的连接地址',
                hintText: '例如 192.168.1.20:45678',
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(labelText: '6 位一次性短码'),
              keyboardType: TextInputType.number,
              maxLength: ManualPairingCodePolicy.length,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(
                  ManualPairingCodePolicy.length,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('短码两分钟内有效，连续输入错误 5 次后立即作废。'),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: null, child: Text('等待配对服务')),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('关闭'),
        ),
      ],
    );
  }
}
