# Logger

A lightweight, thread-safe Swift logger with emoji log levels, environment-based configuration, and native Apple `OSLog` support.

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)

## Overview

**Logger** provides a simple and consistent API for application diagnostics while supporting Swift concurrency and Apple's unified logging system.

### Features

- Thread-safe logging
- Emoji-prefixed log levels
- Debug, info, warning, error, and critical severities
- Environment-based configuration
- Native `OSLog` / `os.Logger` integration
- Configurable minimum log level
- Category-based logging
- Metadata support
- Swift Package Manager support
- Suitable for applications and reusable Swift frameworks

## Requirements

- Swift 5.9 or later
- iOS 13+
- macOS 10.15+
- tvOS 13+
- watchOS 6+
- visionOS 1+

Exact platform requirements may vary depending on the package configuration.

## Installation

### Swift Package Manager

Add **Logger** to `Package.swift`:

```swift
dependencies: [
    .package(
        url: "https://github.com/SandeepNIOS97/Logger.git",
        from: "1.0.0"
    )
]
```

Add it to the desired target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Logger", package: "Logger")
    ]
)
```

Or add the package through Xcode:

1. Open **File → Add Package Dependencies…**
2. Enter `https://github.com/SandeepNIOS97/Logger.git`
3. Select the required version rule
4. Add **Logger** to your target

## Quick Start

```swift
import Logger

Logger.configure(
    .init(
        minimumLevel: .debug,
        isEmojiEnabled: true
    )
)

Logger.debug("Fetching user profile")
Logger.info("Profile loaded")
Logger.warning("Profile image is missing")
Logger.error("Unable to authenticate")
Logger.critical("Cache storage is unavailable")
```

## Logging Levels

| Level | Emoji | Intended use |
|---|---:|---|
| Debug | 🐛 | Development diagnostics and internal state |
| Info | ℹ️ | Normal application lifecycle events |
| Warning | ⚠️ | Recoverable or unexpected conditions |
| Error | ❌ | Operation failures requiring attention |
| Critical | 🔥 | Severe failures or system-wide impact |

Log levels are ordered from least to most severe.

## Basic Usage

### Debug

```swift
Logger.debug("Application launched")
```

### Information

```swift
Logger.info("User signed in")
```

### Warning

```swift
Logger.warning("Response took longer than expected")
```

### Error

```swift
Logger.error(
    "Failed to save profile",
    error: error
)
```

### Critical

```swift
Logger.critical("Unable to initialize the application database")
```

## Configuration

Configure Logger once during application startup:

```swift
Logger.configure(
    .init(
        minimumLevel: .info,
        isEmojiEnabled: true,
        usesOSLogger: true
    )
)
```

### Configuration Options

| Option | Description | Default |
|---|---|---|
| `minimumLevel` | Lowest severity to emit | `.debug` |
| `isEmojiEnabled` | Includes emoji in console output | `true` |
| `usesOSLogger` | Sends output through Apple's unified logging system | `true` |

## Environment-Based Configuration

Use environment variables or build configuration to control logging behavior.

```swift
Logger.configure(
    .init(
        minimumLevel: Environment.isProduction ? .warning : .debug,
        isEmojiEnabled: !Environment.isProduction,
        usesOSLogger: true
    )
)
```

### Recommended Environments

| Environment | Minimum level | Emoji | OSLog |
|---|---|---:|---:|
| Development | `.debug` | Enabled | Enabled |
| Testing | `.debug` | Enabled | Enabled |
| Staging | `.info` | Optional | Enabled |
| Production | `.warning` | Disabled | Enabled |

## Categories

Categories make logs easier to filter in Console.app and the OSLog subsystem.

```swift
let networkLogger = Logger(category: "Network")

networkLogger.info("Request started")
networkLogger.error("Request failed", error: error)
```

## Structured Metadata

Attach contextual information to logs:

```swift
Logger.info(
    "User profile loaded",
    metadata: [
        "user_id": "12345",
        "cache": "hit",
        "duration_ms": "42"
    ]
)
```

Keep metadata short, stable, and useful for debugging. Avoid logging credentials, access tokens, secrets, personally identifiable information, or sensitive medical or financial data.

## OSLog Integration

When OSLog integration is enabled, messages are sent through Apple's unified logging system.

```swift
Logger.configure(
    .init(
        minimumLevel: .info,
        usesOSLogger: true,
        subsystem: Bundle.main.bundleIdentifier,
        category: "Application"
    )
)
```

View logs using Xcode's console or macOS Console.app.

### Filtering in Console.app

```text
subsystem:com.example.application category:Network
```

## Thread Safety

Logger is safe to use across concurrent tasks and threads.

```swift
await withTaskGroup(of: Void.self) { group in
    for index in 1...100 {
        group.addTask {
            Logger.info("Processing item \(index)")
        }
    }
}
```

Concurrent writes are serialized safely; callers do not need to add synchronization.

## Swift Concurrency

Logger may be used from synchronous and asynchronous contexts:

```swift
func fetchProfile() async throws {
    Logger.debug("Starting profile request")

    do {
        let profile = try await profileService.fetch()
        Logger.info("Profile request succeeded")
    } catch {
        Logger.error("Profile request failed", error: error)
        throw error
    }
}
```

## Filtering by Severity

```swift
Logger.configure(
    .init(minimumLevel: .warning)
)

Logger.debug("Not emitted")
Logger.info("Not emitted")
Logger.warning("Emitted")
Logger.error("Emitted")
Logger.critical("Emitted")
```

## Error Logging

Prefer logging an error at the boundary where it is handled:

```swift
do {
    try await repository.save(profile)
} catch {
    Logger.error(
        "Could not save the user profile",
        error: error,
        metadata: [
            "operation": "save-profile",
            "user_id": profile.id
        ]
    )
}
```

Avoid logging the same error at every layer unless additional context provides operational value.

## Testing

Configure Logger explicitly when testing log behavior:

```swift
final class ProfileServiceTests: XCTestCase {
    func testProfileFetchFailure() {
        Logger.configure(
            .init(minimumLevel: .error)
        )

        XCTAssertThrowsError(
            try service.fetchProfile(id: "invalid")
        )
    }
}
```

For tests that validate emitted logs, use a test output sink or inject an appropriate Logger abstraction.

## Performance Guidance

- Use `debug` for high-frequency diagnostics.
- Configure production logs to warn or above.
- Avoid expensive string interpolation in hot paths.
- Do not construct complex metadata unless the message will be emitted.
- Use OSLog for system-level diagnostic visibility.
- Keep log messages stable and concise.

## Security and Privacy

- Never log passwords, API keys, authentication tokens, session IDs, or encryption keys.
- Do not log complete request headers or response bodies.
- Redact personally identifiable information.
- Avoid sensitive application state.
- Review logging output before shipping.
- Use privacy-sensitive OSLog APIs where supported.

## API Stability

Public APIs should follow semantic versioning:

- **Patch**: bug fixes and non-breaking changes
- **Minor**: backward-compatible features
- **Major**: breaking API changes

Deprecated APIs should remain available for at least one release cycle when practical.

## Contributing

Contributions are welcome.

1. Fork the repository
2. Create a feature branch
3. Add or update tests
4. Run the complete test suite
5. Submit a pull request with a clear description

```bash
git clone https://github.com/SandeepNIOS97/Logger.git
cd Logger
swift test
```

### Contribution Guidelines

- Follow Swift API Design Guidelines
- Preserve source compatibility
- Add documentation for public APIs
- Include tests for behavior changes
- Keep changes focused
- Avoid unrelated formatting changes
- Use descriptive commit messages
- Document breaking changes clearly

## License

License information will be added here.

## Author

**SandeepNIOS97**

GitHub: [https://github.com/SandeepNIOS97](https://github.com/SandeepNIOS97)
