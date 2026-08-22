#!/bin/sh

set -eu

SCRIPT_DIRECTORY=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROJECT_DIRECTORY=$(CDPATH= cd -- "$SCRIPT_DIRECTORY/.." && pwd)
. "$SCRIPT_DIRECTORY/xcode_cloud.env"

FLUTTER_DIRECTORY="${HOME}/flutter-sdk-${FLUTTER_SDK_VERSION}"
export PATH="$FLUTTER_DIRECTORY/bin:$FLUTTER_DIRECTORY/bin/cache/dart-sdk/bin:$PATH"

if [ "${CI_BRANCH:-}" != "$IOS_RELEASE_BRANCH" ]; then
  echo "Skipping iOS setup for branch '${CI_BRANCH:-unknown}'; expected '$IOS_RELEASE_BRANCH'."
  exit 0
fi

APP_VERSION=$(sed -n 's/^version:[[:space:]]*\([^+[:space:]]*\).*/\1/p' \
  "$PROJECT_DIRECTORY/pubspec.yaml" | head -n 1)
if [ -z "$APP_VERSION" ]; then
  echo "Unable to read the app version from pubspec.yaml." >&2
  exit 1
fi

BUILD_NUMBER_FILE="$PROJECT_DIRECTORY/.xcode_cloud_build_number"
APP_BUILD_NUMBER="$(date -u +%y%m%d%H%M)"
if [ -s "$BUILD_NUMBER_FILE" ]; then
  LAST_BUILD_NUMBER=$(sed -n '1p' "$BUILD_NUMBER_FILE")
  case "$LAST_BUILD_NUMBER" in
    ''|*[!0-9]*)
      ;;
    *)
      if [ "$LAST_BUILD_NUMBER" -ge "$APP_BUILD_NUMBER" ]; then
        APP_BUILD_NUMBER=$((LAST_BUILD_NUMBER + 1))
      fi
      ;;
  esac
fi
printf '%s\n' "$APP_BUILD_NUMBER" > "$BUILD_NUMBER_FILE"

export PROJECT_DIRECTORY FLUTTER_DIRECTORY APP_VERSION APP_BUILD_NUMBER

configure_ios() {
  if [ ! -x "$FLUTTER_DIRECTORY/bin/flutter" ]; then
    echo "Flutter SDK is unavailable at $FLUTTER_DIRECTORY." >&2
    exit 1
  fi

  flutter config --no-analytics
  flutter config --no-enable-swift-package-manager
  flutter precache --ios
  cd "$PROJECT_DIRECTORY"
  flutter pub get
  flutter build ios --config-only --debug --no-codesign \
    --build-name "$APP_VERSION" --build-number "$APP_BUILD_NUMBER"
  flutter build ios --config-only --release --no-codesign \
    --build-name "$APP_VERSION" --build-number "$APP_BUILD_NUMBER"

  sed -i '' "s/DEVELOPMENT_TEAM = [A-Z0-9]*;/DEVELOPMENT_TEAM = $APPLE_DEVELOPMENT_TEAM;/g" \
    ios/Runner.xcodeproj/project.pbxproj

  (cd ios && pod install)

  test -f ios/Flutter/Generated.xcconfig
  test -f "ios/Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Debug-input-files.xcfilelist"
  test -f "ios/Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Debug-output-files.xcfilelist"
  test -f "ios/Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Release-input-files.xcfilelist"
  test -f "ios/Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Release-output-files.xcfilelist"
}
