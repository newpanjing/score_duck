#!/bin/bash

set -euo pipefail

readonly REPOSITORY_PATH="${CI_PRIMARY_REPOSITORY_PATH:?CI_PRIMARY_REPOSITORY_PATH is required}"
readonly FLUTTER_PATH="${HOME}/flutter"
readonly BUILD_NUMBER="${CI_BUILD_NUMBER:?CI_BUILD_NUMBER is required}"
readonly IOS_BRANCH="ios"

if [[ "${CI_BRANCH:-}" != "${IOS_BRANCH}" ]]; then
  echo "Skipping iOS packaging for branch '${CI_BRANCH:-unknown}'."
  exit 0
fi

export PATH="${FLUTTER_PATH}/bin:${PATH}"
cd "${REPOSITORY_PATH}"

flutter build ios \
  --release \
  --no-codesign \
  --config-only \
  --build-number="${BUILD_NUMBER}"
