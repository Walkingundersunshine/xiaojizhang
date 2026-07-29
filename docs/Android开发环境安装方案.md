# 晓记账：Android 开发环境安装方案

| 项目 | 内容 |
| --- | --- |
| 技术决策编号 | T-038 |
| 日期 | 2026-07-30 |
| 当前状态 | 已选择并完成方案 1：Android Studio + Google 官方 Android SDK |
| 当前检查 | Flutter 已启用 Android 支持，但本机未安装 Android SDK |

## 要决定什么

在当前 Windows 电脑上用什么方式准备 Android SDK、构建工具和测试设备，以生成可安装 APK。

## 方案 1：安装 Android Studio 和官方 Android SDK（推荐）

安装 Google 官方 Android Studio，由它管理 Android SDK、构建工具和模拟器。项目代码仍然可以继续在 VS Code 中编辑，Android Studio 不会替代已经选定的 VS Code。

优势：Google 官方支持；SDK、许可证和模拟器管理最完整；Flutter 文档和常见问题大多按此环境说明；以后连接真机、查看日志和升级 SDK 较方便。

劣势：安装体积最大；Android Studio 本身和一个模拟器镜像可能占用数 GB 到十几 GB；首次下载组件较久。

成本和风险：软件免费；需要从 Google 下载 SDK 与 Maven 构建依赖，当前网络检查曾出现超时，安装时可能需要重试，但不能在未确认来源的情况下改用不可信下载站。

## 方案 2：只安装 Android 命令行工具，使用真实手机测试

不安装完整 Android Studio，仅安装 Google 官方 Command-line Tools、SDK Platform、Build Tools 和 Platform Tools；使用 VS Code 编写代码，通过 USB 或无线调试连接 Android 手机。

优势：占用空间较小；不安装用不到的完整 IDE；继续完全以 VS Code 为主。

劣势：环境变量、SDK 组件、许可证和版本需要手动管理；没有方便的模拟器管理界面；排查配置问题更困难；必须准备可开启开发者模式的 Android 手机。

成本和风险：软件免费；维护成本高于方案 1，手动遗漏组件会导致 Gradle 构建失败。

## 方案 3：使用 GitHub Actions 在线构建 APK

本机不安装 Android SDK；把代码推送到 GitHub 后，由 GitHub 的在线构建机器生成 APK，再下载到 `E:\jizhang\dist`。

优势：本机占用最少；构建环境容易重复；适合以后自动发布版本。

劣势：每次构建都依赖 GitHub 网络和在线服务；本地调试速度慢；仍需要真实手机测试；正式签名时还要安全保存签名密钥。

成本和风险：公开仓库通常有可用的免费构建额度，但规则可能变化；构建日志和依赖获取发生在外部服务；不适合当前频繁调试阶段。

## 我的建议

建议选择方案 1。它是最稳妥的 Flutter Android 官方路径，后续仍可继续只用 VS Code 写代码；Android Studio主要负责 SDK、模拟器和疑难排查。为节省空间，可以先不安装模拟器镜像，优先连接你的 Android 真机测试。

## 决策记录

| 日期 | 选择 | 说明 | 状态 |
| --- | --- | --- | --- |
| 2026-07-30 | 方案 1：Android Studio 和官方 Android SDK | 用户明确选择 1，具体理由未说明 | 已完成 |

## 安装与验证结果

- Android Studio：稳定版 `2026.1`，winget 包 `Google.AndroidStudio`。
- 安装位置：`C:\Program Files\Android\Android Studio`。
- Android SDK：`C:\Users\Administrator\AppData\Local\Android\Sdk`。
- Command-line Tools：`22.0`；安装包来自 Google 官方 `dl.google.com`，SHA-1 与官方仓库清单一致。
- SDK Platform：Android API 36。
- Build Tools：`36.0.0`。
- Platform Tools：已安装。
- NDK：`28.2.13676358`，与当前 Flutter 要求一致。
- JDK：Android Studio 自带 OpenJDK 21，Flutter 已精确配置该路径。
- Android SDK 许可证：全部接受。
- `flutter doctor -v`：Android toolchain 检查通过。
- 未安装 Android 模拟器系统镜像；先保留磁盘空间，后续优先使用真实 Android 手机测试。

