
import Foundation
#if canImport (os)
import os
#endif

/// Abstraction so any project can inject its own / mock logger.
public protocol LoggerProtocol: Sendable {
    /// Cheap check performed before any message is built.
    func isEnabled(_ type: LogType) -> Bool
    /// `message` is lazy - only evaluated if the logger actually outputs it.
    func log(_ type: LogType,_ message: @autoclosure () -> String, file: String, function: String, line: Int)
}

public extension LoggerProtocol {
    func isEnabled(_ type: LogType) -> Bool { true }
}

/// Default implementation: debugPrint + optional OS logging.
public final class AppLogger: LoggerProtocol, @unchecked Sendable {
    private let lock = NSLock()
    private var _config: LogConfiguration
#if canImport (os)
    private var _osLogger: os.Logger
#endif
    
    public init(configuration: LogConfiguration = .development) {
        _config = configuration
#if canImport (os)
        _osLogger = os.Logger(subsystem: configuration.subsystem, category: configuration.category)
#endif
    }
    
    public var configuration: LogConfiguration {
        get { lock.withLock { _config } }
        set {
            lock.withLock {
                _config = newValue
#if canImport(os)
                _osLogger = os.Logger(subsystem: newValue.subsystem,
                                      category: newValue.category)
#endif
            }
        }
    }
    
    public func isEnabled(_ type: LogType) -> Bool {
        let config = configuration
        return type >= config.minimumLevel && (config.shouldUseConsole || config.shouldUseOSLogging)
    }
    
    
    public func log(_ type: LogType, _ message: @autoclosure () -> String, file: String, function: String, line: Int) {
        let config = configuration
        guard type >= config.minimumLevel, config.shouldUseConsole ||
                config.shouldUseOSLogging else { return }
        
        let source = config.showsSourceInfo
        ? " [\(file.split(separator: "/").last.map(String.init) ?? file):\(line) \(function)]" : ""
        let text = "\(type.emoji) [\(type.title)]\(source) → \(message())"
        
        
        if config.shouldUseConsole {
            debugPrint (text)
        }
#if canImport (os)
        if config.shouldUseOSLogging {
            let osLogger = lock.withLock { _osLogger }
            osLogger.log(level: type.osLogType, "\(text, privacy: .public)")
        }
#endif
        
    }
}
