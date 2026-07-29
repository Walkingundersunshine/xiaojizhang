# 晓记账：Android 应用标识方案

| 项目 | 内容 |
| --- | --- |
| 技术决策编号 | T-040 |
| 日期 | 2026-07-30 |
| 当前状态 | 已选择方案 1：`com.walkingundersunshine.xiaojizhang` |

## 要决定什么

确定 Android 的 Application ID。它是 Android 系统和应用商店识别晓记账的永久技术名称，用户通常看不到，但正式发布后不能随意更改。

## 方案 1：`com.walkingundersunshine.xiaojizhang`（推荐）

使用 GitHub 账号名作为组织标识，产品拼音作为应用标识。

优势：与公开仓库 `Walkingundersunshine/xiaojizhang` 对应清楚；不像示例包名；发生重名的概率较低；适合以后上架应用商店。

劣势：标识长期绑定当前 GitHub 公开身份；如果以后更换组织品牌，仍建议保留该 ID 以维持升级兼容。

成本和风险：没有直接费用；应视为永久决定。

## 方案 2：`app.xiaojizhang.android`

使用产品拼音作为主要标识，不包含个人 GitHub 账号。

优势：产品感较强；不直接绑定当前 GitHub 用户名。

劣势：域名式前缀并不对应当前已拥有的互联网域名；唯一性和归属表达不如方案 1 清楚；以后若真的使用该域名需要另行确认所有权。

成本和风险：没有直接费用；存在与其他开发者命名接近的可能。

## 方案 3：继续使用 `com.example.jizhangben`

保留 Flutter 工程早期的示例式标识。

优势：命名改动最少；与现有 Dart 包名和旧内部标识一致。

劣势：`com.example` 明确是示例前缀，不适合公开发布；不能清楚证明项目归属；以后修改会使 Android 把它当作另一个 App。

成本和风险：短期最快，长期迁移风险最高，不建议用于公开 APK。

## 我的建议

建议选择方案 1：`com.walkingundersunshine.xiaojizhang`。它与现有公开身份一致、命名清楚，并且不会改变 Windows 的旧数据目录或 Dart 包名 `jizhangben`。

## 决策记录

| 日期 | 选择 | 说明 | 状态 |
| --- | --- | --- | --- |
| 2026-07-30 | 方案 1：`com.walkingundersunshine.xiaojizhang` | 用户明确选择 1，具体理由未说明 | 已决定并写入 Android 工程 |

## 实现结果

- Android namespace：`com.walkingundersunshine.xiaojizhang`。
- Android Application ID：`com.walkingundersunshine.xiaojizhang`。
- 启动器显示名称：`晓记账`。
- 最低版本：Android 10 / API 29。
- 编译及目标版本：Android API 36。
- 已加入 Android 网络权限，供无密钥汇率请求及后续用户主动局域网同步使用。
- 保留 Dart 包名和桌面旧数据标识 `jizhangben`，不影响现有 Windows 账本。
- Android Debug 首次兼容构建成功；APK 清单复核确认 Application ID、显示名称、最低 API 29、目标 API 36 和网络权限均正确。
- 当前 APK 只用于编译兼容验证，手机布局和局域网同步尚未完成，不作为可交付版本。
