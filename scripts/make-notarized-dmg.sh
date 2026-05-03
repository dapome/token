#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Build, Developer ID sign, notarize, staple, and verify a Token DMG.

Usage:
  TOKEN_DEVELOPMENT_TEAM=TEAMID \
  TOKEN_BUNDLE_ID=dev.example.token \
  NOTARY_PROFILE=token-notary \
  scripts/make-notarized-dmg.sh 0.24

  TOKEN_DEVELOPMENT_TEAM=TEAMID \
  TOKEN_BUNDLE_ID=dev.example.token \
  NOTARY_KEY=/path/to/AuthKey_ABC123DEFG.p8 \
  NOTARY_KEY_ID=ABC123DEFG \
  NOTARY_ISSUER=00000000-0000-0000-0000-000000000000 \
  scripts/make-notarized-dmg.sh 0.24

Required environment:
  TOKEN_DEVELOPMENT_TEAM  Apple Developer Team ID used for Developer ID signing.
  TOKEN_BUNDLE_ID         Public bundle identifier for the app.

Notarization environment:
  NOTARY_PROFILE          notarytool keychain profile name, or:
  NOTARY_KEY              App Store Connect API private key path.
  NOTARY_KEY_ID           App Store Connect API key ID.
  NOTARY_ISSUER           App Store Connect API issuer ID.

Optional environment:
  SIGN_IDENTITY           Code signing identity hash or name. Default: first Developer ID Application identity.
  DERIVED_DATA_PATH       Build output root. Default: /tmp/token-notarized-derived-data
  OUTPUT_DIR              DMG output directory. Default: ./dist

Before first use:
  xcrun notarytool store-credentials "$NOTARY_PROFILE" \
    --apple-id "you@example.com" \
    --team-id "$TOKEN_DEVELOPMENT_TEAM" \
    --password "app-specific-password"
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

VERSION="${1:-}"
if [[ -z "$VERSION" ]]; then
  echo "Missing version argument." >&2
  usage
  exit 1
fi

if [[ -z "${TOKEN_DEVELOPMENT_TEAM:-}" ]]; then
  echo "TOKEN_DEVELOPMENT_TEAM is required." >&2
  exit 1
fi

if [[ -z "${TOKEN_BUNDLE_ID:-}" ]]; then
  echo "TOKEN_BUNDLE_ID is required." >&2
  exit 1
fi

if [[ -n "${NOTARY_PROFILE:-}" ]]; then
  NOTARY_ARGS=(--keychain-profile "$NOTARY_PROFILE")
elif [[ -n "${NOTARY_KEY:-}" && -n "${NOTARY_KEY_ID:-}" && -n "${NOTARY_ISSUER:-}" ]]; then
  NOTARY_ARGS=(--key "$NOTARY_KEY" --key-id "$NOTARY_KEY_ID" --issuer "$NOTARY_ISSUER")
else
  echo "Set NOTARY_PROFILE or NOTARY_KEY, NOTARY_KEY_ID, and NOTARY_ISSUER." >&2
  exit 1
fi

DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-/tmp/token-notarized-derived-data}"
OUTPUT_DIR="${OUTPUT_DIR:-./dist}"
APP_PATH="$DERIVED_DATA_PATH/Build/Products/Release/Token.app"
DMG_PATH="$OUTPUT_DIR/Token-$VERSION.dmg"

if [[ -z "${SIGN_IDENTITY:-}" ]]; then
  SIGN_IDENTITY="$(
    security find-identity -v -p codesigning |
      awk -F'[ )]+' '/Developer ID Application/ { print $3; exit }'
  )"
fi

if [[ -z "$SIGN_IDENTITY" ]] || ! security find-identity -v -p codesigning | grep -F "$SIGN_IDENTITY" >/dev/null; then
  echo "Code signing identity not found: $SIGN_IDENTITY" >&2
  echo "Install a Developer ID Application certificate before notarizing." >&2
  exit 1
fi

rm -rf "$DERIVED_DATA_PATH"
mkdir -p "$OUTPUT_DIR"

xcodebuild \
  -project "Token/Token.xcodeproj" \
  -scheme Token \
  -configuration Release \
  -destination 'platform=macOS' \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="$SIGN_IDENTITY" \
  CODE_SIGN_INJECT_BASE_ENTITLEMENTS=NO \
  DEVELOPMENT_TEAM="$TOKEN_DEVELOPMENT_TEAM" \
  OTHER_CODE_SIGN_FLAGS="--timestamp" \
  PRODUCT_BUNDLE_IDENTIFIER="$TOKEN_BUNDLE_ID" \
  build

codesign --verify --deep --strict --verbose=2 "$APP_PATH"

scripts/make-dmg.sh \
  -a "$APP_PATH" \
  -o "$DMG_PATH" \
  -v "Token $VERSION"

codesign --force --sign "$SIGN_IDENTITY" "$DMG_PATH"

xcrun notarytool submit "$DMG_PATH" \
  "${NOTARY_ARGS[@]}" \
  --wait

xcrun stapler staple "$DMG_PATH"
xcrun stapler validate "$DMG_PATH"
spctl --assess --type open --context context:primary-signature --verbose "$DMG_PATH"

shasum -a 256 "$DMG_PATH"
echo "Notarized DMG: $DMG_PATH"
