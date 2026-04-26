# Token

Token is a small macOS menu bar app for checking usage and spend across provider admin APIs.

It currently supports:

- OpenAI organization usage and cost reporting
- Anthropic Usage & Cost Admin API reporting
- OpenRouter credits and management-key spend reporting

This app is intentionally narrow in scope. It is for org admins who already have access to provider reporting APIs. It is not a general-purpose dashboard for normal end-user API keys or consumer subscriptions.

## Security model

- Provider keys are stored in the user's macOS Keychain.
- Keys are never written to app storage or committed files.
- The app only stores enough information locally to know whether a key exists and what the latest fetched snapshot was in memory.
- The app is sandboxed and only requests outbound network access for provider API calls.
- If you discover a potential vulnerability, please do not open a public issue with sensitive details. Use the security reporting process in [SECURITY.md](SECURITY.md).

## Requirements

- macOS 26.2 or later
- Xcode 17 or later
- One or more of the following credentials:
  - OpenAI Admin API key for an organization
  - Anthropic Admin API key for an organization account
  - OpenRouter management key

Normal OpenAI, Anthropic, and OpenRouter inference keys will not work with these reporting endpoints.

## Build

Open `Token/Token.xcodeproj` in Xcode and run the `Token` scheme.

Command line build:

```sh
xcodebuild -project "Token/Token.xcodeproj" -scheme Token -destination 'platform=macOS' build
```

Run tests:

```sh
xcodebuild -project "Token/Token.xcodeproj" -scheme Token -destination 'platform=macOS' test
```

The project defaults to ad hoc signing for local builds. If you plan to archive, notarize, or distribute the app, set your own bundle identifier and signing team in Xcode first.

## Provider notes

### OpenAI

- Uses organization usage and costs endpoints.
- Requires an Admin API key.
- Spend is bucketed and may lag behind the current UTC day.

### Anthropic

- Uses the Usage & Cost Admin API.
- Requires an Admin API key that starts with `sk-ant-admin`.
- The API is not available for individual accounts.

### OpenRouter

- Uses credits and management-key reporting endpoints.
- Requires a management key.
- Token counts are not currently exposed by the API used here.

## Project status

This is an early utility app, not a polished product. The main areas that still need hardening are:

- better portability for app signing and packaging
- broader runtime verification across provider account shapes

## Contributing

Small focused issues and PRs are the best fit right now. If you change provider parsing, include sample payloads or tests where possible because these admin/reporting APIs are the most fragile part of the app.

## License

MIT. See [LICENSE](LICENSE).

## Releases

Release process notes live in [RELEASING.md](RELEASING.md).
