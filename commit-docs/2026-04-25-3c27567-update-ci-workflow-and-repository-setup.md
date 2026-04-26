# Update CI workflow and repository setup

**Commit:** `3c27567`
**Branch:** main
**Date:** 2026-04-25

## Summary

This commit updates the GitHub Actions CI workflow to utilize the latest stable version of Xcode and specifies a deployment target of macOS 15.0 for building and testing the 'Token' project. This ensures compatibility with the latest macOS features and enhances build reliability.

Additionally, a new documentation commit introduces essential GitHub repository metadata and sets up the core structure of the 'Token' macOS app. This includes setting up code ownership, issue templates, a .gitignore file, and initial app structure within Xcode. The setup of these components is crucial for maintaining a systematic source control management system and providing a firm foundation for further feature development and collaboration.

## Files Changed

- **.github/workflows/ci.yml** — Update CI workflow to use the latest stable Xcode and set macOS deployment target
- **commit-docs/2026-04-25-c36e183-add-github-repository-metadata-and-initial-app-str.md** — Add commit documentation for repository metadata and initial app structure setup

## Checklist

### Needs Review
- [ ] Verify CODEOWNERS ensures correct ownership for sensitive areas

### Considerations
- [ ] Consider expanding test coverage for Xcode project structure and CI setup
