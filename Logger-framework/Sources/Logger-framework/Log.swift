//
//  Log 2.swift
//  Logger-framework
//
//  Created by Sandeep Nigam
//


import Foundation
/// Easy-to-use static API.
///

/// Log. configure (.development)        // once at app launch
/// Log. s ("Login success")
/// Log.i("User id:", 42)
/// Log. e( "Failed", error)

public enum Log {
    nonisolated(unsafe) private static var _logger: any LoggerProtocol = AppLogger()
    private static let lock = NSLock()
    public static var logger: any LoggerProtocol {
        lock.withLock { _logger }
    }
    // Configure the default logger.
    public static func configure(configuration: LogConfiguration) {
        inject (AppLogger(configuration: configuration))
    }
    /// Inject any custom logger (e.g. a mock in unit tests).
    public static func inject<L: LoggerProtocol>(_ logger: L) {
        lock.withLock { _logger = logger }
    }
    
    // MARK: - Public API (variadic generics: no 'Any boxing, no array allocation)
    public static func v<each T>(_ items: repeat each T, file: String = #fileID,
                                 function: String = #function, line: Int = #line) {
        write(.v, repeat each items, file: file, function: function, line: line)
    }
    
    public static func d<each T>(_ items: repeat each T, file: String = #fileID,
                                 function: String = #function, line: Int = #line) {
        write(.d, repeat each items, file: file, function: function, line: line)
    }
    
    public static func i<each T>(_ items: repeat each T, file: String = #fileID,
                                 function: String = #function, line: Int = #line) {
        write(.i, repeat each items, file: file, function: function, line: line)
    }
    public static func s<each T>(_ items: repeat each T, file: String = #fileID,
                                 function: String = #function, line: Int = #line) {
        write(.s, repeat each items, file: file, function: function, line: line)
    }
    
    public static func w<each T>(_ items: repeat each T, file: String = #fileID,
                                 function: String = #function, line: Int = #line) {
        write(.w, repeat each items, file: file, function: function, line: line)
    }
    
    public static func e<each T>(_ items: repeat each T, file: String = #fileID,
                                 function: String = #function, line: Int = #line) {
        write(.e, repeat each items, file: file, function: function, line: line)
    }
    
    // MARK: - Private
    
    /// Single funnel: checks isEnabled first so disabled logs (e.g. production) cost nothing.
    @inline(__always)
    private static func write<each T>(_ type: LogType, _ items: repeat each T,
                                      file: String, function: String, line: Int) {
        let logger = self.logger
        guard logger.isEnabled (type) else { return }
        logger.log (type, message (repeat each items), file: file, function: function, line: line)
    }
    
    /// Joins any heterogeneous values into one string.
    static func message<each T>(_ items: repeat each T) -> String {
        var parts: [String] = []
        for item in repeat each items {
            parts.append(String (describing: item))
        }
        return parts.joined(separator: " ")
    }
}
