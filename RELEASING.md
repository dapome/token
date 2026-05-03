# Releasing Token

This checklist is for creating a tagged GitHub release for Token.

## 1) Prepare release metadata

- Choose a version number (for example, `0.3.0`).
- Update app versioning in Xcode project settings:
  - `MARKETING_VERSION` -> release version
  - `CURRENT_PROJECT_VERSION` -> incremented build number
- Update `README.md` if requirements or provider behavior changed.

## 2) Validate locally

Run from repo root:

```sh
xcodebuild -project "Token/Token.xcodeproj" -scheme Token -destination 'platform=macOS' build
xcodebuild -project "Token/Token.xcodeproj" -scheme Token -destination 'platform=macOS' test
```

Recommended manual checks:

- Launch app and verify menu bar rendering.
- Verify at least one provider path end-to-end.
- Confirm credential save/update/delete behavior in settings.
- Regenerate the README screenshot if the menu UI changed:

```sh
scripts/render-demo-screenshot.sh repo/images/token-gh.jpg
```

## 3) Commit and tag

- Commit release changes to `main`.
- Create an annotated tag:

```sh
git tag -a v0.3.0 -m "Token v0.3.0"
git push origin main --tags
```

## 4) Publish GitHub release

- Create a release from tag `v0.3.0`.
- Add concise notes:
  - user-visible changes
  - provider/API compatibility notes
  - known limitations

## 5) Post-release follow-up

- Confirm CI is green for the release commit.
- Watch for user issues after publish.
- If needed, cut a patch release (`v0.3.1`) with focused fixes.

## Optional: signed/notarized distribution

If distributing binaries outside source builds:

- Install a Developer ID Application certificate in Keychain.
- Store notarization credentials once:

```sh
xcrun notarytool store-credentials "token-notary" \
  --apple-id "you@example.com" \
  --team-id "TEAMID" \
  --password "app-specific-password"
```

If Apple ID authentication fails, use a Team App Store Connect API key instead. In App Store Connect, go to **Users and Access > Integrations > App Store Connect API**, select **Team Keys**, create a key, download the `.p8` file, and keep the key private.

- Build, sign, notarize, staple, and verify the DMG with a Keychain profile:

```sh
TOKEN_DEVELOPMENT_TEAM=TEAMID \
TOKEN_BUNDLE_ID=dev.example.token \
NOTARY_PROFILE=token-notary \
scripts/make-notarized-dmg.sh 0.24
```

- Or build, sign, notarize, staple, and verify the DMG with an App Store Connect API key:

```sh
TOKEN_DEVELOPMENT_TEAM=TEAMID \
TOKEN_BUNDLE_ID=dev.example.token \
NOTARY_KEY=/path/to/AuthKey_ABC123DEFG.p8 \
NOTARY_KEY_ID=ABC123DEFG \
NOTARY_ISSUER=00000000-0000-0000-0000-000000000000 \
scripts/make-notarized-dmg.sh 0.24
```

- Attach the notarized artifact from `dist/` to the GitHub release.
