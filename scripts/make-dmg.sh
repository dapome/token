#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Create a distributable DMG for Token.app.

Usage:
  scripts/make-dmg.sh [-a /path/to/Token.app] [-o Token.dmg] [-v "Token"]

Options:
  -a  Path to .app bundle (default: ./Token.app)
  -o  Output DMG file path (default: ./Token.dmg)
  -v  DMG volume name (default: Token)
  -h  Show help

Example:
  scripts/make-dmg.sh -a "./Token.app" -o "./dist/Token.dmg" -v "Token"
EOF
}

APP_PATH="./Token.app"
OUTPUT_DMG="./Token.dmg"
VOLUME_NAME="Token"

while getopts ":a:o:v:h" opt; do
  case "$opt" in
    a) APP_PATH="$OPTARG" ;;
    o) OUTPUT_DMG="$OPTARG" ;;
    v) VOLUME_NAME="$OPTARG" ;;
    h)
      usage
      exit 0
      ;;
    :)
      echo "Missing value for -$OPTARG" >&2
      usage
      exit 1
      ;;
    \?)
      echo "Unknown option: -$OPTARG" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ ! -d "$APP_PATH" || "${APP_PATH##*.}" != "app" ]]; then
  echo "App bundle not found: $APP_PATH" >&2
  exit 1
fi

OUTPUT_DIR="$(dirname "$OUTPUT_DMG")"
mkdir -p "$OUTPUT_DIR"

TMP_ROOT="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

cp -R "$APP_PATH" "$TMP_ROOT/"
ln -s /Applications "$TMP_ROOT/Applications"

echo "Creating DMG: $OUTPUT_DMG"
hdiutil create \
  -volname "$VOLUME_NAME" \
  -srcfolder "$TMP_ROOT" \
  -ov \
  -format UDZO \
  "$OUTPUT_DMG"

echo "Done: $OUTPUT_DMG"
