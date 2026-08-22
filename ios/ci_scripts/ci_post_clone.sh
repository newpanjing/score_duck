#!/bin/bash

set -euo pipefail

readonly REPOSITORY_PATH="${CI_PRIMARY_REPOSITORY_PATH:?CI_PRIMARY_REPOSITORY_PATH is required}"
readonly FLUTTER_VERSION="3.47.0"
readonly FLUTTER_PATH="${HOME}/flutter"
readonly IOS_BRANCH="ios"

if [[ "${CI_BRANCH:-}" != "${IOS_BRANCH}" ]]; then
  echo "Skipping iOS setup for branch '${CI_BRANCH:-unknown}'."
  exit 0
fi

cd "${REPOSITORY_PATH}"

if [[ ! -x "${FLUTTER_PATH}/bin/flutter" ]] || [[ "$(git -C "${FLUTTER_PATH}" describe --tags --exact-match 2>/dev/null || true)" != "${FLUTTER_VERSION}" ]]; then
  rm -rf "${FLUTTER_PATH}"
  git clone --depth 1 --branch "${FLUTTER_VERSION}" https://github.com/flutter/flutter.git "${FLUTTER_PATH}"
fi

export PATH="${FLUTTER_PATH}/bin:${PATH}"

flutter config --no-analytics
flutter precache --ios
flutter pub get

cd ios
pod install --deployment
