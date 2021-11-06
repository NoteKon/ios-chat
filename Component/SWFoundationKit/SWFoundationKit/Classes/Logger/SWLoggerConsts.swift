//
//  SWLoggerConsts.swift
//  SWFoundationKit
//
//  Created by ice on 2019/11/23.
//

import Foundation

public enum SWLoggerLevel: Int, CustomStringConvertible, CaseIterable {
    case verbose = 1
    case debug = 2
    case info = 3
    case warn = 4
    case error = 5
    
    public var description: String {
        switch self {
        case .verbose:
            return "VEB"
        case .debug:
            return "DBG"
        case .info:
            return "INF"
        case .warn:
            return "WRN"
        case .error:
            return "ERR"
        }
    }
}

extension SWLoggerLevel: Comparable {
    public static func < (lhs: SWLoggerLevel, rhs: SWLoggerLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

public struct SWLoggerMessage {
    public var message: String
    public var level: SWLoggerLevel
    public var filename: String
    public var lineno: Int
}

public protocol SWLoggerProtocol: class {
    static var level: SWLoggerLevel { get set }
    
    var loggerQueue: DispatchQueue? { get }
    
    func logMessage(_ message: SWLoggerMessage)
    func flush()
}

public protocol SWLoggerFormatter {
    func formatLogMessage(_ message: SWLoggerMessage) -> String
}

public func toLoggerFormat(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone.current
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    return formatter.string(from: date)
}

class SWLoggerNode {
    var logger: SWLoggerProtocol
    var level: SWLoggerLevel
    var loggerQueue: DispatchQueue
    
    init(logger: SWLoggerProtocol, level: SWLoggerLevel, loggerQueue: DispatchQueue) {
        self.logger = logger
        self.level = level
        self.loggerQueue = loggerQueue
    }
}
