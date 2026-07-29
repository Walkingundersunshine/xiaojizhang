# 晓记账：Flutter SDK Git 所有权处理方案

| 项目 | 内容 |
| --- | --- |
| 提案编号 | T-018 |
| 文档版本 | v0.3 |
| 提案日期 | 2026-07-29 |
| 当前状态 | 方案 1 已配置并验证，Flutter 初始化完成 |

## 配置与验证结果

- Git 全局配置只新增：`E:/记账App/.tools/flutter`。
- Flutter 首次依赖解析成功。
- Flutter：3.44.8 stable。
- Dart：3.12.2。
- DevTools：2.57.0。
- Flutter Doctor 已识别 Visual Studio Build Tools 2022、Windows SDK 和 Windows 桌面设备。
- Android SDK 与 Chrome 未安装；它们只影响 Android 和 Web，不影响当前 Windows/macOS 桌面范围。
- Flutter 与 Dart 未加入全局 PATH；这是此前选择的项目内隔离方案，项目命令使用 `.tools/flutter/bin/flutter.bat`。

## 1. 问题原因

Flutter SDK 已经过官方 SHA-256 验证并解压成功。项目文件由隔离的 Codex 沙箱账户写入，而联网初始化命令需要在当前 Windows 管理员账户下运行。Git 发现 Flutter SDK 仓库的文件所有者与当前运行账户不同，因此触发 `dubious ownership` 安全检查并拒绝继续。

这不是 SDK 损坏，也不是 Flutter 版本错误，而是 Git 防止运行不可信仓库脚本的所有权保护。

## 2. 方案 1：只信任这个 Flutter SDK 路径

做法：在当前 Windows 用户的 Git 全局配置中加入一个精确的 `safe.directory`：

`E:/记账App/.tools/flutter`

优势：

- 只信任这一个经过官方哈希验证的 SDK 目录。
- 不更改文件所有者和权限，改动最小。
- 是 Git 错误信息建议的处理方式。
- 以后可用一条 Git 命令移除该信任记录。

劣势：

- 会在当前用户的全局 Git 配置中增加一条记录。
- 如果以后有人替换该目录内容，Git 仍会把同一路径视为安全，因此 `.tools` 目录必须继续只用于项目工具链。

## 3. 方案 2：把 SDK 文件所有权改为当前用户

做法：递归把 `.tools/flutter` 中大量文件的 Windows 所有者和权限改为 Administrator。

优势：

- 不需要 Git `safe.directory` 例外。
- 当前用户对 SDK 文件具有一致所有权。

劣势：

- 会递归修改数万文件的 Windows 权限和所有者，改动范围明显更大。
- 后续沙箱账户更新 SDK 时可能再次产生权限冲突。
- 权限继承处理不当可能造成无法更新或删除文件。

## 4. 方案 3：不进行联网初始化

做法：保持当前状态，尝试通过人工准备所有依赖并进行离线初始化。

优势：

- 不修改 Git 配置或 Windows 文件所有权。

劣势：

- 需要单独下载并组织 Flutter 工具依赖，步骤复杂。
- 很难保证以后所有依赖都能离线解析。
- 仍不能解决管理员账户执行 Flutter Git 仓库命令时的所有权检查。

## 5. 我的建议

建议选择 **方案 1：只把 `E:/记账App/.tools/flutter` 加入 Git safe.directory**。

该目录中的 SDK 已通过 Flutter 官方 SHA-256 验证，信任范围精确到一个路径，风险和改动都小于递归修改文件所有权。

## 6. 决策记录

| 日期 | 用户选择 | 理由 | 状态 |
| --- | --- | --- | --- |
| 2026-07-29 | 方案 1：将 `E:/记账App/.tools/flutter` 加入 Git safe.directory | 用户明确选择 1，具体理由未说明 | 已决定 |

## 7. 变更记录

| 版本 | 日期 | 变更 |
| --- | --- | --- |
| v0.1 | 2026-07-29 | 记录 Flutter 首次初始化的 Git 所有权检查并提出三种处理方案 |
| v0.2 | 2026-07-29 | 记录用户选择方案 1，开始添加精确 Git safe.directory 配置 |
| v0.3 | 2026-07-29 | 记录 Git 配置、Flutter 初始化和 Flutter Doctor 验证结果 |
