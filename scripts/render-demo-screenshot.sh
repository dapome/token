#!/usr/bin/env bash
set -euo pipefail

OUTPUT_PATH="${1:-repo/images/token-gh.jpg}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-/tmp/token-demo-screenshot-derived-data}"
ABSOLUTE_OUTPUT_PATH="$(cd "$(dirname "$OUTPUT_PATH")" && pwd)/$(basename "$OUTPUT_PATH")"

xcodebuild \
  -project "Token/Token.xcodeproj" \
  -scheme Token \
  -configuration Debug \
  -destination 'platform=macOS' \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  CODE_SIGN_ENTITLEMENTS="" \
  ENABLE_APP_SANDBOX=NO \
  build

"$DERIVED_DATA_PATH/Build/Products/Debug/Token.app/Contents/MacOS/Token" \
  --render-demo-screenshot "$ABSOLUTE_OUTPUT_PATH"

echo "Rendered demo screenshot: $OUTPUT_PATH"
