#!/bin/sh

set -eu

SCRIPT_DIRECTORY=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec "$SCRIPT_DIRECTORY/../../ci_scripts/ci_pre_xcodebuild.sh"
