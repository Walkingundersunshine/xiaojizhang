import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('系统安全存储可以写入、读取并删除同步测试凭据', (tester) async {
    const storage = FlutterSecureStorage();
    const key = 'xiaojizhang.integration_test.secure_storage';
    const value = 'temporary-test-value';

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await storage.delete(key: key);
    addTearDown(() => storage.delete(key: key));

    await storage.write(key: key, value: value);
    expect(await storage.read(key: key), value);

    await storage.delete(key: key);
    expect(await storage.read(key: key), isNull);
  });
}
