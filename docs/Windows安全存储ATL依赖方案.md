# 晓记账：Windows 安全存储 ATL 依赖方案

| 项目 | 内容 |
| --- | --- |
| 技术决策编号 | T-047 |
| 日期 | 2026-07-30 |
| 当前状态 | 等待用户选择；先完成 T-046 证书方案重新决策 |
| 触发原因 | `flutter_secure_storage_windows` 需要 Visual C++ ATL，当前精简 Build Tools 未安装 |

## 实测结果

- `flutter_secure_storage 10.3.1` 支持 Android、Windows 和 macOS，Android Debug APK 已成功构建。
- Windows Debug 构建在官方插件源文件处停止，错误为缺少 `atlstr.h`。
- `atlstr.h` 属于 Microsoft Visual C++ ATL，不是项目源码，也不能用空文件或跳过包含来替代。
- 现有 Windows App 代码未损坏；在决定处理方式前，不发布包含未验证安全存储功能的新版本。

## 方案 1：为现有 Build Tools 安装 Microsoft ATL 组件（推荐）

通过已安装的 Visual Studio Installer 给当前 Build Tools 2022 增加 `Microsoft.VisualStudio.Component.VC.ATL`，继续使用跨平台系统安全存储插件。

优势：保留已选择的系统安全存储方向；使用微软官方编译组件；Android、Windows、macOS 共用同一 Flutter 接口；插件升级路径清楚。

劣势：增加 Visual Studio 磁盘占用和安装时间；以后重装开发环境时也要记得安装 ATL；macOS 仍需 Mac 实机验证钥匙串行为。

成本和风险：组件免费，预计增加数百 MB 级别磁盘占用，具体由当前安装器显示；安装期间可能要求关闭正在使用编译工具的进程。

## 方案 2：Windows 单独编写 DPAPI/Credential Manager 实现

移除该 Windows 插件实现，自己通过 Windows API 保存私钥；Android 和 macOS 继续使用各自安全存储。

优势：可能不需要 ATL；可以精确控制 Windows 存储格式和错误处理。

劣势：需要维护一套安全相关 Windows 原生/FFI 代码；三个平台不再使用统一实现；测试和安全审查成本更高；自研错误可能造成私钥泄露或丢失。

成本和风险：无软件费用，但开发维护成本最高，不建议仅为节省 ATL 组件而采用。

## 方案 3：暂缓 Windows 局域网同步

移除安全存储插件变更，保持现有 Windows 记账功能和构建；Android 同步身份功能也暂不进入可交付版本，等待以后重新选择安全存储方案。

优势：不增加开发环境组件；现有 Windows 构建立即恢复。

劣势：手机与电脑局域网同步无法交付；已选择的长期配对方案暂停；Android 只能继续作为独立本地账本使用。

成本和风险：短期成本最低，但核心新增需求延期。

## 我的建议

建议选择方案 1。ATL 是微软官方 C++ 组件，安装它比自研 Windows 私钥存储更稳妥，也能维持三个平台统一的安全存储接口。

## 决策记录

| 日期 | 选择 | 说明 | 状态 |
| --- | --- | --- | --- |
| 2026-07-30 | 等待选择方案 1～3 | T-046 重新决定后再确认 | 待决定 |

