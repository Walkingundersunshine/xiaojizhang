# 晓记账：winget 修复方案

| 项目 | 内容 |
| --- | --- |
| 提案编号 | T-014 |
| 文档版本 | v0.4 |
| 提案日期 | 2026-07-29 |
| 当前系统 | Windows Enterprise 25H2，Build 26200 |
| 检查结果 | App Installer 已通过 Microsoft Store 安装，winget 已验证 |
| 当前状态 | 修复完成：winget v1.29.280 可用 |

## 当前执行状态

- 用户通过 Microsoft Store 安装了微软官方“应用安装程序”。
- 商店产品页确认名称为“应用安装程序”，发布者为 `Microsoft Windows`，状态为“已安装”。
- WindowsApps 应用别名已生成。
- `winget --version` 验证结果：`v1.29.280`。
- 软件源验证成功：`msstore`、`winget`、`winget-font`。
- `winget search "Flutter"` 只读搜索成功。
- 搜索结果没有 Google 官方 Flutter SDK 包；有 `Google.DartSDK` 和若干第三方 Flutter 工具，不能把它们误认为官方 Flutter SDK。

## 1. 问题原因

`winget.exe` 由微软的“应用安装程序（Microsoft.DesktopAppInstaller / App Installer）”提供。当前系统中：

- 找不到 `winget.exe` 命令。
- WindowsApps 目录中没有 winget 命令入口。
- 当前用户和全体用户均没有注册 `Microsoft.DesktopAppInstaller`。
- Microsoft Store 应用包也不存在，因此不能直接打开商店安装 App Installer。

这说明问题不是命令路径失效，而是 winget 所属应用包缺失。

## 2. 修复方案 1：安装微软官方 App Installer 包

做法：从微软官方 WinGet GitHub 发布页下载签名的 App Installer MSIXBundle 及必要依赖，使用 Windows 的 `Add-AppxPackage` 为当前用户安装，然后验证数字签名和 `winget --version`。

优势：

- 不依赖 Microsoft Store，适合当前系统状态。
- 来源是微软官方 WinGet 项目，安装内容和版本可明确记录。
- 只安装 winget 所需组件，系统改动范围相对小。
- 修复完成后可正常使用 `winget search`、`winget install` 和升级命令。

劣势：

- 需要下载并安装 MSIX/AppX 依赖包。
- 若企业策略禁止旁加载应用包，可能需要管理员权限或策略调整。
- 后续自动更新不如 Microsoft Store 渠道顺畅，需要用 winget 或重新安装新版 App Installer 更新。

## 3. 修复方案 2：先恢复 Microsoft Store，再安装 App Installer

做法：修复或重新注册 Microsoft Store 组件，然后从商店安装“应用安装程序”。

优势：

- App Installer 后续通常可通过 Microsoft Store 自动更新。
- 更接近普通 Windows 电脑的默认维护方式。

劣势：

- 当前 Store 包也不存在，修复范围明显大于只安装 winget。
- 企业版 Windows 可能受组织策略限制，恢复过程可能需要管理员权限或系统映像源。
- 会增加与当前项目无关的系统组件，耗时和失败点更多。

## 4. 修复方案 3：使用微软 WinGet PowerShell 修复模块

做法：从 PowerShell Gallery 安装微软的 WinGet 客户端模块，再运行修复命令安装或重新注册 WinGet Package Manager。

优势：

- 修复流程自动化程度较高。
- 适合需要脚本化修复多台电脑的场景。

劣势：

- 额外依赖 PowerShell Gallery、NuGet 和模块执行策略。
- 自动化过程隐藏了部分依赖安装细节，出错时排查更复杂。
- 当前只修复一台电脑，没有明显优于直接安装官方包。

## 5. 我的建议

建议选择 **方案 1：安装微软官方 App Installer 包**。

理由：当前 Microsoft Store 本身缺失，方案 1 能以最小系统改动恢复 winget；安装前可以检查包来源，安装后可以直接验证版本和命令功能。

## 6. 选择后的安全步骤

1. 只访问微软官方 GitHub 发布页或微软官方短链接。
2. 下载 App Installer MSIXBundle 和它明确要求的依赖。
3. 检查安装包的 Microsoft 数字签名；签名无效时停止。
4. 使用 `Add-AppxPackage` 为当前用户安装。
5. 运行 `winget --version`、`winget source list` 和一次只读搜索验证。
6. 成功后再用 winget 继续查找 Flutter 相关安装方式。

## 7. 决策记录

| 日期 | 用户选择 | 理由 | 状态 |
| --- | --- | --- | --- |
| 2026-07-29 | 方案 1：安装微软官方 App Installer 包 | 用户明确选择 1，具体理由未说明 | 已决定 |

## 8. 变更记录

| 版本 | 日期 | 变更 |
| --- | --- | --- |
| v0.1 | 2026-07-29 | 记录 winget 缺失原因并提出三种官方修复方案 |
| v0.2 | 2026-07-29 | 记录用户选择方案 1，开始官方 App Installer 修复流程 |
| v0.3 | 2026-07-29 | 记录 Microsoft Store 下载后的复查结果：App Installer 尚未注册，winget 仍不可用 |
| v0.4 | 2026-07-29 | 确认 Microsoft Store 安装完成；验证 winget v1.29.280、软件源和搜索正常 |
