//
//  LogConfiguration.swift
//  Logger-framework
//
//  Created by Sandeep Nigam on 24/11/26.
//

import Foundation
/// App environment. OS logging is always OFF in-production
public enum LogEnvironment: Sendable {
    case development
    case staging
    case production
}

public struct LogConfiguration: Sendable {
    /// Current environment.
    public var environment: LogEnvironment
    // Enables debugPrint console output (always OFF in production).
    public var isConsoleLoggingEnabled: Bool
    /// Enables OS (unified) logging for non-prod. Ignored in production.
    public var isOSLoggingEnabled: Bool
    /// Logs below this type are skipped.
    public var minimumLevel: LogType
    /// Shows `File swift:42 function ()` in each log.
    public var showsSourceInfo: Bool
    /// os.Logger subsystem / category.
    public var subsystem: String
    public var category: String
    
    public init(environment: LogEnvironment = . development,
                isConsoleLoggingEnabled: Bool = true,
                isOSLoggingEnabled: Bool = true,
                minimumLevel: LogType = .v,
                showsSourceInfo: Bool = true,
                subsystem: String = Bundle.main.bundleIdentifier ?? "App",
                category: String = "App") {
        self.environment = environment
        self.isConsoleLoggingEnabled = isConsoleLoggingEnabled
        self.isOSLoggingEnabled = isOSLoggingEnabled
        
        self.minimumLevel = minimumLevel
        self.showsSourceInfo = showsSourceInfo
        self.subsystem = subsystem
        self.category = category
    }
    
    /// Final decision: OS logging only in non-prod AND when enabled.
    public var shouldUseOSLogging: Bool { environment != . production &&
        isOSLoggingEnabled }
    
    /// Final decision: console only in non-prod AND when enabled.
    public var shouldUseConsole: Bool { environment != .production &&
        isConsoleLoggingEnabled }
    
    // Presets
    public static let development = LogConfiguration(environment: .development)
    public static let developmentWithoutOSLog = LogConfiguration(environment:
            .development, isOSLoggingEnabled: false)
    public static let staging = LogConfiguration(environment: .staging)
    public static let production = LogConfiguration(environment: .production)
}
