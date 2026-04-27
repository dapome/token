# Update CI config and streamline Xcode project settings

**Commit:** `7df7650`
**Branch:** main
**Date:** 2026-04-27

## Summary

The CI workflow configuration file has been updated to use `macos-latest` and the latest stable Xcode version, to ensure the build uses the most up-to-date environments. In the Xcode project, redundant .xcconfig files for AppDebug and AppRelease have been removed, and the configuration has been merged into the main project file for simplicity. This changes the way code signing is set up, moving from placeholders to hardcoded defaults, which might require revisiting in multi-developer environments.

Additionally, the .gitignore file has been updated by removing local Xcode signing overrides and certain local release artifacts, reflecting a cleanup of unnecessary configurations. The LocalOverrides.example.xcconfig was renamed to LocalOverrides.xcconfig indicating an update in the development team ID.

## Files Changed

- **.github/workflows/ci.yml** — Updated to use macOS latest and latest-stable Xcode version.
- **.gitignore** — Removed local Xcode signing overrides and specific local release artifacts.
- **Token/Config/AppDebug.xcconfig** — Deleted redundant xcconfig file for AppDebug.
- **Token/Config/AppRelease.xcconfig** — Deleted redundant xcconfig file for AppRelease.
- **Token/Config/LocalOverrides.example.xcconfig** — Renamed to LocalOverrides.xcconfig with updated APP_DEVELOPMENT_TEAM.
- **Token/Token.xcodeproj/project.pbxproj** — Merged AppDebug and AppRelease settings into project.pbxproj, removed placeholders.
- **dist/Token.dmg** — Deleted Token.dmg from dist directory.

## Checklist

### Needs Review
- [ ] Verify the impact of removing AppDebug.xcconfig and AppRelease.xcconfig on build processes.

### Considerations
- [ ] Consider using environment variables or central configuration for code signing credentials to ensure they are not hardcoded.
