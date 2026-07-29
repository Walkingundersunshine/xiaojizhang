# 晓记账：Windows 桌面构建环境方案

| 项目 | 内容 |
| --- | --- |
| 提案编号 | T-016 |
| 文档版本 | v0.3 |
| 提案日期 | 2026-07-29 |
| 当前状态 | 方案 2 已安装并验证 |

## 安装与验证结果

- 安装方式：winget 官方源。
- 安装包：`Microsoft.VisualStudio.2022.BuildTools` 17.14.37。
- winget 已验证安装器哈希并报告安装成功。
- 安装位置：`C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools`。
- MSVC：14.44.35207，x64 编译器已定位。
- Windows SDK：10.0.26100.0。
- CMake：已安装并定位。
- Ninja：已安装并定位。
- 安装参数包含 `Microsoft.VisualStudio.Workload.VCTools`、推荐组件和禁止自动重启。

## 1. 当前环境检查

| 组件 | 状态 |
| --- | --- |
| Git | 已安装，2.55.0.windows.3 |
| Visual Studio 2022 Community | 未安装；winget 官方包版本 17.14.37 |
| Visual Studio 2022 Build Tools | 未安装；winget 官方包版本 17.14.37 |
| MSVC C++ 编译器 | 未安装 |
| CMake | 未发现 |
| Ninja | 未发现 |

Flutter 生成 Windows 桌面应用时，需要微软 C++ 编译器、Windows SDK 和 CMake 等组件。只安装 Flutter SDK 不能生成可运行的 Windows `.exe`。

## 2. 方案 1：Visual Studio Community 2022 完整 IDE

winget 包：`Microsoft.VisualStudio.2022.Community`

做法：安装 Visual Studio Community，并选择“使用 C++ 的桌面开发”工作负载及推荐组件。

优势：

- 包含完整图形化开发环境、调试器和项目管理界面。
- 如果以后需要人工调试 Windows 原生代码，操作比较直观。
- 微软官方维护，Flutter 官方文档常以该组合为标准环境。

劣势：

- 下载和磁盘占用最大，实际可能达到 10～20 GB 或更多。
- 安装时间长，会增加许多当前 Flutter 项目不一定使用的 IDE 组件。
- 后续更新体积也较大。

适合：希望以后亲自使用 Visual Studio 图形界面进行 Windows 原生开发或调试。

## 3. 方案 2：Visual Studio Build Tools 2022

winget 包：`Microsoft.VisualStudio.2022.BuildTools`

做法：只安装微软构建工具及“使用 C++ 的桌面开发”所需组件，不安装完整 Visual Studio 编辑器。

优势：

- 能满足 Flutter Windows 构建要求。
- 比完整 Community IDE 更轻，预计仍需约 7～12 GB，实际由微软安装器决定。
- 当前项目主要由 Codex 编写代码，不需要额外的大型编辑器。
- 同样使用微软官方 MSVC、Windows SDK 和 CMake 工具。

劣势：

- 没有完整 Visual Studio 图形界面。
- 如果以后需要人工调试原生 C++，命令行和轻量编辑器体验不如 Community。
- 安装命令必须明确添加 C++ 工作负载，否则只有空的安装器外壳。

适合：主要目标是可靠构建和测试 Flutter Windows App，不计划使用完整 Visual Studio IDE。

## 4. 方案 3：暂缓安装 Windows 构建环境

做法：先安装 Flutter SDK 并创建 Dart / Flutter 代码，暂时不安装 Visual Studio。

优势：

- 现在不占用大量磁盘和下载时间。
- 可以先进行部分代码编写和不依赖 Windows 原生构建的检查。

劣势：

- 无法编译、启动或验收 Windows 桌面版。
- 无法确认 SQLite 等桌面插件在 Windows 上真实可用。
- 项目明确要求支持 Windows，因此最终仍必须安装。
- 问题会被推迟到开发后期，届时修复成本更高。

适合：当前网络或磁盘条件暂时不允许大型安装，只作为临时方案。

## 5. 我的建议

建议选择 **方案 2：Visual Studio Build Tools 2022**。

理由：它提供 Flutter Windows 构建所需的全部微软官方组件，又不安装当前项目不需要的完整 IDE。项目由 Codex 协助开发，构建、测试和错误排查可以通过 Flutter 工具完成。

安装时会使用 winget 官方包，并明确加入 C++ 桌面工作负载和推荐组件。安装完成后运行 Flutter 环境检查验证 MSVC、Windows SDK、CMake 与 Ninja；不能只根据 winget 返回成功就判定环境可用。

## 6. 决策记录

| 日期 | 用户选择 | 理由 | 状态 |
| --- | --- | --- | --- |
| 2026-07-29 | 方案 2：Visual Studio Build Tools 2022 | 用户明确选择 2，具体理由未说明 | 已决定 |

## 7. 变更记录

| 版本 | 日期 | 变更 |
| --- | --- | --- |
| v0.1 | 2026-07-29 | 根据本机检查和 winget 官方包信息提出三种 Windows 构建环境方案 |
| v0.2 | 2026-07-29 | 记录用户选择方案 2，开始通过 winget 安装 C++ 桌面构建组件 |
| v0.3 | 2026-07-29 | 记录 Build Tools 安装成功及 MSVC、Windows SDK、CMake、Ninja 验证结果 |
