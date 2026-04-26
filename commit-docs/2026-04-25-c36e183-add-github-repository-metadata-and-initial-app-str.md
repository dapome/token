# Add GitHub repository metadata and initial app structure

**Commit:** `c36e183`
**Branch:** main
**Date:** 2026-04-25

## Summary

This commit introduces essential GitHub repository metadata and sets up the core structure of the 'Token' macOS app.

The CODEOWNERS file specifies default code ownership across the repository to ensure proper review processes. Additionally, issue templates for bug reports and feature requests have been introduced to standardize the reporting process and improve contributions handling.

A comprehensive structure for the macOS app named 'Token' is also established, including main application files, configuration files, documentation, and directories necessary for the build process. The AppModel and TokenApp are initialized to handle the application's state and main functionalities, focusing on provider API keys management.

This setup is critical as it enables systematic source control management and lays the foundation for further feature development and team collaboration.

## Files Changed

- **.github/CODEOWNERS** — Define code ownership for repository files
- **.github/ISSUE_TEMPLATE/bug_report.yml** — Add template for bug reports
- **.github/ISSUE_TEMPLATE/config.yml** — Configure issue template settings
- **.github/ISSUE_TEMPLATE/feature_request.yml** — Add template for feature requests
- **.github/dependabot.yml** — Add dependabot configuration for dependency updates
- **.github/pull_request_template.md** — Add template for pull requests
- **.github/workflows/ci.yml** — Configure CI workflow for building and testing on macOS
- **.gitignore** — Update .gitignore for macOS and Xcode generated files
- **CODE_OF_CONDUCT.md** — Introduce a Contributor Covenant Code of Conduct
- **CONTRIBUTING.md** — Provide guidelines for contributing to the repository
- **LICENSE** — Add MIT license for the project
- **README.md** — Provide an overview of the 'Token' app, including requirements and setup instructions
- **RELEASING.md** — Outline the release process for the 'Token' app
- **SECURITY.md** — Establish security reporting policy and guidelines
- **Token/Token.xcodeproj/project.pbxproj** — Initialize Xcode project configuration for the 'Token' app
- **Token/Token/App/AppModel.swift** — Implement main app state management logic
- **Token/Token/App/TokenApp.swift** — Define the entry point and main scene for the Token macOS app
- **Token/Token/Features/MenuBar/DashboardHeroView.swift** — Create DashboardHeroView for displaying main dashboard metrics
- **Token/Token/Models/ProviderKind.swift** — Define provider types and related metadata
- **Token/Token/Models/ProviderLoadState.swift** — Represent different states of provider data loading
- **Token/Token/Models/ProviderSnapshot.swift** — Define structure to hold snapshot data for a provider
- **Token/Token/Models/UsageError.swift** — Enumerate possible errors in data usage requests
- **Token/Token/Services/AnthropicUsageService.swift** — Implement service for fetching usage data from the Anthropic API

## Checklist

### Needs Review
- [ ] Verify CODEOWNERS ensures correct ownership for sensitive areas

### Considerations
- [ ] Consider expanding test coverage for Xcode project structure and CI setup
