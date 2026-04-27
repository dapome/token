# Add Gemini service and update project configuration

**Commit:** `2fa0104`
**Branch:** main
**Date:** 2026-04-26

## Summary

This change introduces support for Gemini API by adding a new `GeminiUsageService`, which validates API keys and fetches usage snapshots. The `AppModel` has been updated to integrate Gemini service and key management, including operations to save and remove Gemini keys from the keychain. The UI components have been adjusted to display Gemini as a new provider, with relevant views updated to accommodate additional API key editing and provider status.

The project configuration has been updated to set 'main-icon' as the app icon, adjust marketing version to 0.23, and improve code signing settings by specifying 'Apple Development'. Additionally, it includes minor UI cleanup, improving padding, and removing unnecessary backgrounds across several views.

A new `make-dmg.sh` script has been added to automate the creation of a distributable DMG file for Token.app. This script allows specifying the application path, output file, and volume name, and handles the generation of the DMG using macOS's `hdiutil` tool.

## Files Changed

- **Token/Token.xcodeproj/project.pbxproj** — Set 'main-icon' as app icon, update marketing version to 0.23, improve code signing settings
- **Token/Token/App/AppModel.swift** — Add support for Gemini API service and integrate into the application model
- **Token/Token/Features/MenuBar/MenuBarRootView.swift** — Add Gemini to the list of providers and adjust UI layout
- **Token/Token/Features/MenuBar/ProviderSectionView.swift** — Improve layout and adjust styles for provider section view
- **Token/Token/Features/MenuBar/ProviderSnapshotView.swift** — Adjust spacing and font style in snapshot view
- **Token/Token/Features/MenuBar/ProviderStatusBadgeView.swift** — Streamline status badge with updated icon styles
- **Token/Token/Features/Settings/CredentialEditorView.swift** — Update credential editor layout and styling
- **Token/Token/Features/Settings/ProviderStatusView.swift** — Refine styling of provider status display
- **Token/Token/Features/Settings/SettingsView.swift** — Update settings layout with auto-refresh picker and Gemini support
- **Token/Token/Models/ProviderKind.swift** — Add Gemini as a new provider kind and update related properties
- **Token/Token/Services/AnthropicUsageService.swift** — Normalize cost to USD in Anthropic usage service
- **Token/Token/Services/GeminiUsageService.swift** — Create a new service for handling Gemini API key validation
- **Token/Token/Services/KeychainStore.swift** — Set keychain item accessibility to a more secure class
- **Token/Token/Support/AppLinks.swift** — Add Gemini-related documentation and usage URLs
- **Token/Token/Support/AppTheme.swift** — Adjust theme constants for spacing and layout
- **Token/TokenTests/ProviderParsingTests.swift** — Update test to match new Anthropic usage service normalization
- **scripts/make-dmg.sh** — Add script to create a distributable DMG for Token.app

## Checklist

### Needs Review
- [ ] Ensure the GeminiUsageService correctly handles API key validation and error responses.

### Considerations
- [ ] Consider adding more unit tests for new features and edge cases, especially around API key management.
