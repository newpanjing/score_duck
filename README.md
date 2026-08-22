# scoreduck

A new Flutter project.

## Xcode Cloud

仓库已包含 Xcode Cloud 生命周期脚本（`ios/ci_scripts/`）。创建 Xcode Cloud 工作流时，请选择：

- 触发条件：Branch Changes，分支仅选择 `iOS`
- 项目：`ios/Runner.xcworkspace`
- Scheme：`Runner`
- 构建操作：Archive（Release）
- 完成后操作：选择 `TestFlight` 或 `App Store` 分发到 App Store Connect

工作流会在 `iOS` 分支克隆后安装 Flutter `3.47.0`、关闭 Flutter Swift Package Manager、执行 `flutter pub get` 和 `pod install`，并在 Xcode 构建前使用 UTC 时间生成十位 iOS 构建号。请在 App Store Connect 中为 Bundle ID `com.noondot.ScoreDuck` 配置 Team ID `3AVKA6L8FE` 的签名证书和描述文件，并在工作流的环境设置中启用自动签名。Xcode Cloud 会使用 Archive 产物自动上传到 App Store Connect；不需要在仓库中保存 API Key。

本地仓库仍保持在 `main` 分支。需要发布 iOS 时，将代码合并或推送到远程 `iOS` 分支即可触发工作流。

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
