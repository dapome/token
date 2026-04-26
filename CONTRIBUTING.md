# Contributing

Token is still a small app, so the best contributions are narrow and easy to validate.

## Before opening a PR

- confirm the app still builds with:

```sh
xcodebuild -project "Token/Token.xcodeproj" -scheme Token -destination 'platform=macOS' build
```

- run the provider parsing tests with:

```sh
xcodebuild -project "Token/Token.xcodeproj" -scheme Token -destination 'platform=macOS' test
```

- keep provider-specific changes isolated when possible
- update docs if you change supported credentials or provider behavior

## Secrets and payloads

- never commit API keys, admin keys, or management keys
- never paste live credentials into issues or PRs
- if a provider response changed, prefer sharing a redacted sample payload or a minimal schema diff

## Good first contribution areas

- provider response parsing hardening
- clearer error states and setup guidance
- automated tests around date bucketing and response decoding
- release signing and packaging docs

## Pull request notes

Include:

- what provider or area changed
- how you verified it
- any docs or API references used
