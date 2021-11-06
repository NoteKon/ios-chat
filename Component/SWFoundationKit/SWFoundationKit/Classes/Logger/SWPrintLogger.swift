//
//  SWPrintLogger.swift
//  SWFoundationKit
//
//  Created by ice on 2019/11/23.
//

import Foundation

class SWPrintLogger: SWLoggerProtocol {
    static var level: SWLoggerLevel = .verbose
    
    var loggerQueue: DispatchQueue?
    
    private let formatter = SWPrintLoggerFormatter()
    private let dispatchKey = DispatchSpecificKey<SWPrintLogger>()
    
    init() {
        loggerQueue = DispatchQueue(label: "SWPrintLoggerQueue")
        loggerQueue?.setSpecific(key: dispatchKey, value: self)
    }
    
    func logMessage(_ message: SWLoggerMessage) {
        assert(isOnInternalQueue, "should only run on internal queue")
        
        let output = formatter.formatLogMessage(message)
        print(output)
    }
    
    func flush() {
        
    }
    
    private var isOnInternalQueue: Bool {
        return DispatchQueue.getSpecific(key: dispatchKey) === self
    }
}

class SWPrintLoggerFormatter: SWLoggerFormatter {
    func formatLogMessage(_ message: SWLoggerMessage) -> String {
        let dateString = toLoggerFormat(Date())
        let filename = URL(string: message.filename)?.deletingPathExtension().lastPathComponent
        let result = String(format: "%@: %@:%d: [%@] %@",
                            dateString, filename ?? message.filename, message.lineno,
                            message.level.description, message.message)
        return result
    }
}
