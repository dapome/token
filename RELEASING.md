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

- Set your own bundle ID and signing team in Xcode.
- Archive app with release signing.
- Notarize with Apple.
- Attach notarized artifact to GitHub release.
