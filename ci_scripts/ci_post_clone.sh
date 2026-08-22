#!/bin/sh

set -eu

SCRIPT_DIRECTORY=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIRECTORY/common.sh"

if [ ! -x "$FLUTTER_DIRECTORY/bin/flutter" ]; then
  rm -rf "$FLUTTER_DIRECTORY"
  git clone --depth 1 --branch "$FLUTTER_SDK_VERSION" \
    "$FLUTTER_SDK_REPOSITORY" "$FLUTTER_DIRECTORY"
fi

if [ ! -x "$FLUTTER_DIRECTORY/bin/flutter" ]; then
  echo "Flutter SDK is unavailable at $FLUTTER_DIRECTORY." >&2
  exit 1
fi

configure_ios
