//
//  LogType.swift
//  Logger-framework
//
//  Created by Sandeep Nigam on 24/11/26.
//

import Foundation
#if canImport (os)
import os
#endif

/// Logging types. Short names map to Log.s, "Log.i, Log.e'
public enum LogType: Int, CaseIterable, Comparable, Sendable{
    case v  // verbose
    case d  // debug
    case i  // info
    case s  // success
    case w  // warning
    case e  // error
    
    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
    var emoji: String {
        switch self {
        case .v: "💬"
        case .d: "🐛"
        case .i: "ℹ️"
        case .s: "✅"
        case .e: "❌"
        case .w: "⚠️"
        }
    }
    
    var title: String {
        switch self {
        case .v: "VERBOSE"
        case .d: "DEBUG"
        case .i: "INFO"
        case .s: "SUCCESS"
        case .e: "ERROR"
        case .w: "WARNING"
        }
    }
    
#if canImport (os)
    var osLogType: OSLogType {
        switch self {
        case .v, .d: .debug
        case .i, .s: .info
        case .w: .default
        case .e: .error
        }
    }
#endif
}

