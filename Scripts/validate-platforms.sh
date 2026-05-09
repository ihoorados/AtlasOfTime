#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DERIVED_DATA_PATH="${ROOT_DIR}/.derivedData-platform-validation"

cleanup() {
  if [[ "${KEEP_DERIVED_DATA:-0}" != "1" ]]; then
    rm -rf "${DERIVED_DATA_PATH}"
  fi
}

trap cleanup EXIT

cd "${ROOT_DIR}"

echo "==> Validating macOS tests"
xcodebuild test \
  -project AtlasOfTime.xcodeproj \
  -scheme AtlasOfTime \
  -destination 'platform=macOS' \
  -derivedDataPath "${DERIVED_DATA_PATH}/macos"

echo "==> Validating iOS simulator build-for-testing"
xcodebuild build-for-testing \
  -project AtlasOfTime.xcodeproj \
  -scheme AtlasOfTime \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "${DERIVED_DATA_PATH}/ios"

echo "==> Platform validation passed"
