#!/bin/bash

# 引入你的密钥信息（或者直接在脚本里 export）
API_KEY="KJY6D58SF3"
API_ISSUER="32c4fdad-058b-4320-ac99-cf69fce85a8b"


# 设置默认值
version="1.0.0" 

# 使用 getopts 处理 -v 参数
while getopts "v:" opt; do
  case $opt in
    v)
      version=$OPTARG # 将 -v 后面的值赋给 version
      ;;
    \?)
      echo "无效的选项: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# 自动生成 Build Number (格式如: 2025123021)
BUILD_NUMBER=$(date +%Y%m%d%H)

echo "🚀 开始 iOS 构建 ( Version: $version, Build: $BUILD_NUMBER)..."

# 1. Flutter 编译生成 .ipa
flutter clean
flutter pub get
# --build-number 会覆盖 pubspec.yaml 里的设置
flutter build ipa --release --build-name=$version --build-number=$BUILD_NUMBER

# 2. 获取 IPA 文件路径
IPA_PATH=$(ls build/ios/ipa/*.ipa | head -n 1)

# 3. 验证并上传
echo "验证并上传到 App Store Connect..."
xcrun altool --upload-app \
  --type ios \
  --file "$IPA_PATH" \
  --apiKey "$API_KEY" \
  --apiIssuer "$API_ISSUER" \
  --verbose

if [ $? -eq 0 ]; then
  echo "✅ iOS 上传成功！"
else
  echo "❌ iOS 上传失败。"
fi