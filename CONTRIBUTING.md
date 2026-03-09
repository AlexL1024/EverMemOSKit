# Contributing

## Scope

This repository is the standalone Swift package for the EverMemOS client SDK. Keep game-specific code, app settings, and local tooling out of this package.

## Development

```bash
swift build
swift test
```

## Guidelines

- Preserve source compatibility for public API changes where possible.
- Add or update tests for request encoding, decoding, auth, retries, and streaming behavior.
- Keep examples in `README.md` aligned with the current API.
- Avoid adding third-party dependencies unless there is a strong maintenance reason.

