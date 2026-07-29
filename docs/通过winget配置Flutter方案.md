# 晓记账：通过 winget 配置 Flutter 方案

| 项目 | 内容 |
| --- | --- |
| 提案编号 | T-015 |
| 文档版本 | v0.2 |
| 提案日期 | 2026-07-29 |
| 前置状态 | winget v1.29.280 已修复并验证 |
| 当前状态 | 已选择方案 3：Flutter 官方 SDK，winget 管理构建依赖 |

## 1. 当前发现

已运行 `winget search "Flutter" --accept-source-agreements`。搜索结果中：

- 没有由 Google 或 Flutter 官方发布的 Flutter SDK 包。
- 有 `Google.DartSDK`，但 Dart SDK 不等于 Flutter SDK，单独安装不能构建 Flutter App。
- 有第三方 Flutter 版本管理器 `Puro`，包 ID 为 `pingbird.Puro`。
- 有 Microsoft Store 中的 `Sidekick for Flutter` 等第三方工具，但它们不是 Flutter SDK。

因此，不能为了“使用 winget”而安装一个名称带 Flutter 的第三方应用并声称 SDK 已安装。

## 2. 方案 1：winget 安装 Puro，再由 Puro 安装 Flutter

做法：通过 winget 安装第三方版本管理器 `pingbird.Puro`，再使用 Puro 下载并固定 Flutter 3.44.8。

优势：

- Puro 本身由 winget 安装和管理。
- 可以为项目固定 Flutter 版本，适合多个项目使用不同版本。
- 后续切换和升级 Flutter 版本比较方便。

劣势：

- Puro 是第三方工具，不是 Google / Flutter 官方组件。
- 增加一层版本管理工具，下载源、缓存和故障排查更复杂。
- 仍需由 Puro 从网络下载完整 Flutter SDK，不能消除网络问题。

## 3. 方案 2：winget 安装官方 Dart，再通过 FVM 安装 Flutter

做法：使用 winget 安装 `Google.DartSDK`，再从 Dart 官方包仓库安装第三方 FVM，通过 FVM 下载并固定 Flutter 版本。

优势：

- Dart SDK 的 winget 包由 Google 提供。
- FVM 是常见的 Flutter 版本管理方式。
- 可以为项目固定 Flutter 版本。

劣势：

- Flutter 自带 Dart，再单独安装 Dart 会产生重复工具链。
- FVM 仍是第三方工具，并且多出全局 Dart 包和 PATH 配置。
- 步骤比方案 1 更多，当前项目没有明显收益。

## 4. 方案 3：Flutter 保持官方 SDK，winget 用于构建依赖

做法：Flutter SDK 仍按之前确定的方式，从 Flutter 官方发布体系或经官方哈希校验的镜像获取；winget 用于安装和维护 Git、Visual Studio C++ 构建工具等 Windows 桌面依赖。

优势：

- Flutter SDK 本身保持官方来源，不引入第三方版本管理器。
- 与此前选择的“项目内独立 Flutter 工具链”一致。
- winget 用在它真正有官方包、适合管理的 Windows 构建依赖上。
- 项目 SDK 与电脑其他项目隔离。

劣势：

- Flutter SDK 不能直接通过 winget 安装。
- 仍需完成大型 SDK 下载和哈希验证。
- Visual Studio C++ 构建工具体积较大，安装前需要另行提案和用户确认。

## 5. 我的建议

建议选择 **方案 3**。

它不把第三方工具误当成 Flutter 官方方案，保留已经确定的项目级版本隔离，同时让 winget 负责 Git、Visual Studio 等适合由 Windows 包管理器维护的依赖。

如果更看重“Flutter 版本也必须由 winget 管理”，可以选择方案 1，但需要接受 Puro 这一第三方依赖。

## 6. 决策记录

| 日期 | 用户选择 | 理由 | 状态 |
| --- | --- | --- | --- |
| 2026-07-29 | 方案 3：Flutter 保持官方 SDK，winget 用于构建依赖 | 用户明确选择 3，具体理由未说明 | 已决定 |

## 7. 变更记录

| 版本 | 日期 | 变更 |
| --- | --- | --- |
| v0.1 | 2026-07-29 | 根据 winget 实测搜索结果提出三种 Flutter 配置方案 |
| v0.2 | 2026-07-29 | 记录用户选择方案 3，确定 Flutter SDK 与 winget 的使用边界 |
