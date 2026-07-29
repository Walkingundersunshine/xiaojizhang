# 晓记账

一款面向 Windows 和 macOS 的本地优先、多货币桌面记账应用。使用 Flutter、Riverpod、Drift 和 SQLite 构建。

> 当前处于 `0.1.0` 内部测试阶段。Windows x64 已完成构建与测试；macOS 工程已生成，但仍需要在 Mac 上完成编译和实机验收。

## 功能

- 记录、编辑和删除花销。
- 支持 CNY、USD、EUR、GBP、JPY、HKD、MOP、TWD、SGD、AUD、CAD、KRW。
- 13 个一级分类、82 个默认二级分类，支持完整的分类新增、重命名、排序和停用。
- 按当地日期、货币、一级分类、二级分类筛选，并支持时间正序/倒序。
- 使用 Frankfurter / 欧洲央行公开历史汇率进行本位币统计，无需 API 密钥。
- 月度汇总、原币统计、本位币折算和一级分类横向条形图。
- CSV 技术字段导出。
- `.jizhang` JSON 完整备份与事务恢复；恢复前自动创建安全备份。
- 本地 JSON Lines 滚动诊断日志，由用户主动导出，不自动上传。

## 隐私与数据

- 账本、分类、设置、汇率缓存和诊断日志默认只保存在本机。
- 不提供账号、云同步、遥测或自动崩溃上传。
- 只有历史汇率查询会访问 Frankfurter 服务。
- MOP 和 TWD 不参与汇率折算，始终保持原币统计。
- 首版数据库不加密，请依赖操作系统账户、磁盘加密和文件权限保护设备。

## 技术栈

- Flutter 3.44.8 / Dart 3.12.2
- Riverpod
- Drift + SQLite
- `file_selector`
- `logging`

## 开发环境

需要安装 Flutter stable，以及对应平台的桌面构建环境：

- Windows：Visual Studio Build Tools 2022，包含 Desktop development with C++。
- macOS：Xcode 与 CocoaPods。

进入 Flutter 工程目录后运行：

```bash
cd app
flutter pub get
flutter analyze
flutter test
```

Windows 运行与构建：

```bash
flutter run -d windows
flutter build windows --release
```

macOS 运行与构建（必须在 macOS 上执行）：

```bash
flutter run -d macos
flutter build macos --release
```

## 项目结构

```text
app/        Flutter 应用源码与测试
docs/       产品、架构和技术决策记录
packaging/  内部测试包说明
```

主要文档：

- [产品需求文档](docs/产品需求文档.md)
- [技术选型与决策规则](docs/技术选型与决策规则.md)
- [GitHub 开源发布方案](docs/GitHub开源发布方案.md)
- [贡献指南](CONTRIBUTING.md)
- [安全政策](SECURITY.md)

## 当前验证状态

- 37 项自动测试通过。
- `flutter analyze` 无问题。
- Windows Debug / Release 构建通过。
- Windows x64 Release 启动、文件选择窗口、备份/恢复入口和诊断日志导出入口已人工验收。
- 用户可见名称和 Windows EXE 已统一为“晓记账”/`xiaojizhang.exe`；旧数据标识继续保留，确保现有账本兼容。
- macOS 工程包含所需插件注册，但尚未在 Mac 上完成构建和验收。

## 许可证

本项目使用 [GNU General Public License v3.0](LICENSE) 发布。分发修改版或衍生版本时，请遵守 GPL-3.0 的源代码提供和同许可证要求。
