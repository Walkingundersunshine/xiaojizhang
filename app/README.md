# 晓记账 Flutter App

本目录包含“晓记账”的 Flutter 源码，目标平台为 Windows 和 macOS。

可以使用系统 Flutter stable，或自行配置项目隔离的 Flutter SDK。

```bash
cd app
flutter pub get
flutter analyze
flutter test
flutter run -d windows
```

当前工程包含花销、两级分类、多货币、历史汇率统计、CSV 导出、完整备份恢复和本地诊断日志。
