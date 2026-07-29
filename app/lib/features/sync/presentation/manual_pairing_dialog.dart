import 'package:flutter/material.dart';

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
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: '电脑显示的连接地址',
                hintText: '例如 192.168.1.20:45678',
              ),
              keyboardType: TextInputType.url,
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(labelText: '一次性短码'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Text('加密监听服务接入后才能提交；当前入口用于确认备用流程和布局。'),
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
