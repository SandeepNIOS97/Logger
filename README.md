# Logger

A lightweight, thread-safe Swift logging framework with emoji log levels, environment presets, source information, console output, and optional Apple unified logging through `os.Logger`.

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)

## Overview

The package provides a static `Log` API backed by a configurable `AppLogger`. It supports verbose, debug, info, success, warning, and error levels, and can be customized or replaced with a `LoggerProtocol` implementation for testing.

### Features

- Thread-safe static logging API
- Emoji-prefixed log levels
- Verbose, debug, info, success, warning, and error severities
- Development, staging, and production presets
- Optional console output with `debugPrint`
- Optional `os.Logger` integration outside production
- Configurable source file, function, and line information
- Custom logger injection through `LoggerProtocol`
- Swift Package Manager support

## Requirements

- Swift 6.0 or later
- iOS 14 or later

## Installation

### Swift Package Manager

Add the package to `Package.swift`:

```swift
dependencies: [
    .package(
        url: "https://github.com/SandeepNIOS97/Logger.git",
        branch: "main"
    )
]
```

Add the product to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Logger-framework", package: "Logger")
    ]
)
```

Import the module in source files:

```swift
import Logger_framework
```

Or add the package through Xcode:

1. Open **File → Add Package Dependencies…**
2. Enter `https://github.com/SandeepNIOS97/Logger.git`
3. Select the package and branch or version rule
4. Add the **Logger-framework** library to your target

## Quick Start

Configure the logger once, then use the short static logging methods:

```swift
import Logger_framework

Log.configure(configuration: .development)

Log.v("Verbose diagnostic")
Log.d("Fetching user profile")
Log.i("User ID:", 42)
Log.s("Profile loaded")
Log.w("Profile image is missing")
Log.e("Unable to authenticate", error)
```

Multiple arguments are converted with `String(describing:)` and joined with spaces.

## Usage

### Logging Levels

| Method | Case | Emoji | OSLog level | Intended use |
|---|---|---|---|---|
| `Log.v(_:)` | `.v` | 💬 | `.debug` | Verbose diagnostics |
| `Log.d(_:)` | `.d` | 🐛 | `.debug` | Development diagnostics |
| `Log.i(_:)` | `.i` | ℹ️ | `.info` | General information |
| `Log.s(_:)` | `.s` | ✅ | `.info` | Successful operations |
| `Log.w(_:)` | `.w` | ⚠️ | `.default` | Warnings and recoverable issues |
| `Log.e(_:)` | `.e` | ❌ | `.error` | Errors and failures |

The levels are ordered from `.v` through `.e`. A level below `minimumLevel` is skipped.

```swift
Log.v("Network request details")
Log.d("Application launched")
Log.i("User signed in")
Log.s("Profile saved")
Log.w("Response took longer than expected")
Log.e("Could not save the profile", error)
```

### Configuration

Create a custom configuration with `LogConfiguration`:

```swift
Log.configure(
    configuration: LogConfiguration(
        environment: .development,
        isConsoleLoggingEnabled: true,
        isOSLoggingEnabled: true,
        minimumLevel: .d,
        showsSourceInfo: true,
        subsystem: Bundle.main.bundleIdentifier ?? "App",
        category: "Application"
    )
)
```

### Configuration Options

| Option | Description | Default |
|---|---|---|
| `environment` | Controls environment-based output behavior | `.development` |
| `isConsoleLoggingEnabled` | Enables console output through `debugPrint` | `true` |
| `isOSLoggingEnabled` | Enables output through `os.Logger` | `true` |
| `minimumLevel` | Lowest severity to emit | `.v` |
| `showsSourceInfo` | Includes file, line, and function details | `true` |
| `subsystem` | `os.Logger` subsystem identifier | Bundle identifier or `"App"` |
| `category` | `os.Logger` category | `"App"` |

Console and OS logging are both disabled when `environment` is `.production`, regardless of their individual enablement flags.

### Environment Presets

```swift
Log.configure(configuration: .development)
Log.configure(configuration: .staging)
Log.configure(configuration: .production)
Log.configure(configuration: .developmentWithoutOSLog)
```

| Preset | Environment | Console | OSLog | Minimum level |
|---|---|---|---|---|
| `.development` | Development | Enabled | Enabled | `.v` |
| `.developmentWithoutOSLog` | Development | Enabled | Disabled | `.v` |
| `.staging` | Staging | Enabled | Enabled | `.v` |
| `.production` | Production | Disabled | Disabled | `.v` |

For a custom production configuration:

```swift
Log.configure(
    configuration: LogConfiguration(
        environment: .production,
        isConsoleLoggingEnabled: false,
        isOSLoggingEnabled: false,
        minimumLevel: .w
    )
)
```

### Minimum Log Level

Messages below the configured minimum are not evaluated or emitted:

```swift
Log.configure(
    configuration: LogConfiguration(
        environment: .development,
        minimumLevel: .w
    )
)

Log.d("Not emitted")
Log.i("Not emitted")
Log.w("Emitted")
Log.e("Emitted")
```

### Source Information

Source information is enabled by default:

```swift
Log.configure(
    configuration: LogConfiguration(
        environment: .development,
        showsSourceInfo: true
    )
)

Log.i("Request started")
```

This produces source context containing the file name, line number, and function name.

Disable it for shorter messages:

```swift
Log.configure(
    configuration: LogConfiguration(
        environment: .development,
        showsSourceInfo: false
    )
)
```

### OS Logging

On platforms that provide `os.Logger`, configure the subsystem and category:

```swift
Log.configure(
    configuration: LogConfiguration(
        environment: .development,
        isConsoleLoggingEnabled: true,
        isOSLoggingEnabled: true,
        subsystem: Bundle.main.bundleIdentifier ?? "App",
        category: "Network"
    )
)

Log.i("Request started")
Log.e("Request failed", error)
```

OS logging can be viewed in Xcode's console or macOS Console.app. It is automatically disabled for `.production`.

### Custom Logger Injection

The static API accepts any implementation of `LoggerProtocol`:

```swift
final class TestLogger: LoggerProtocol {
    private(set) var messages: [(LogType, String)] = []

    func log(
        _ type: LogType,
        _ message: @autoclosure () -> String,
        file: String,
        function: String,
        line: Int
    ) {
        messages.append((type, message()))
    }
}

let testLogger = TestLogger()
Log.inject(testLogger)
Log.i("Test message")
```

`LoggerProtocol.isEnabled(_:)` has a default implementation that returns `true`, so custom implementations only need to implement `log(_:_:file:function:line:)` unless filtering is required.

To implement filtering:

```swift
final class FilteredTestLogger: LoggerProtocol {
    func isEnabled(_ type: LogType) -> Bool {
        type >= .w
    }

    func log(
        _ type: LogType,
        _ message: @autoclosure () -> String,
        file: String,
        function: String,
        line: Int
    ) {
        print(message())
    }
}
```

### Concurrent Usage

The static logger and `AppLogger` are designed for concurrent use:

```swift
await withTaskGroup(of: Void.self) { group in
    for index in 1...100 {
        group.addTask {
            Log.i("Processing item", index)
        }
    }
}
```

### Error Logging

Pass an error as another variadic item. `Log` joins all items into one string:

```swift
do {
    try await repository.save(profile)
} catch {
    Log.e(
        "Could not save the user profile",
        error,
        "operation=save-profile",
        "user_id=", profile.id
    )
}
```

The framework does not provide a separate metadata argument.

## Thread Safety

`Log` protects its injected logger with `NSLock`. `AppLogger` also protects its configuration and `os.Logger` instance. Callers do not need to add synchronization around `Log.v`, `Log.d`, `Log.i`, `Log.s`, `Log.w`, or `Log.e`.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make focused changes
4. Run the Swift package test suite
5. Submit a pull request

```bash
git clone https://github.com/SandeepNIOS97/Logger.git
cd Logger/Logger-framework
swift test
```

## Author

**SandeepNIOS97**

GitHub: [https://github.com/SandeepNIOS97](https://github.com/SandeepNIOS97)
