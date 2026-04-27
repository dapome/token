# Add Xcode configuration for debug and release builds

**Commit:** `4469672`
**Branch:** main
**Date:** 2026-04-26

## Summary

This commit introduces new Xcode configuration files for both debug and release builds. The configuration consolidates the code signing identities and styles into `AppDebug.xcconfig` and `AppRelease.xcconfig` files, with overrides exemplified in `LocalOverrides.example.xcconfig`. The `.gitignore` file has been updated to exclude local Xcode signing overrides and release artifacts, ensuring that local changes do not affect the repository. Additionally, updates to `project.pbxproj` link these new configuration files to improve maintainability and flexibility of environment-specific settings. This change sets a foundation for easier management of code signing and environment overrides, centralizing configurations into dedicated files.

## Files Changed

- **.gitignore** — Add entries to ignore local Xcode overrides and release artifacts
- **Token/Config/AppDebug.xcconfig** — Create debug configuration with code signing setup
- **Token/Config/AppRelease.xcconfig** — Create release configuration with code signing setup
- **Token/Config/LocalOverrides.example.xcconfig** — Provide example overrides file for local configuration
- **Token/Token.xcodeproj/project.pbxproj** — Link new xcconfig files to Xcode project for debug and release builds
- **commit-docs/2026-04-26-2fa0104-add-gemini-service-and-update-project-configuratio.md** — Add documentation for changes related to Gemini service and configurations
- **dist/Token.dmg** — Add binary DMG release artifact to distribution

## Checklist

### Needs Review
- [ ] Ensure LocalOverrides are correctly documented for local overrides setup

### Considerations
- [ ] Consider adding more detailed comments in xcconfig files for future maintainers
