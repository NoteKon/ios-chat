//
//  SWLogger.swift
//  SWFoundationKit
//
//  Created by ice on 2019/11/21.
//

import Foundation

public class SWLogger {
    public static let `default` = SWLogger()
    static let disptachKey = DispatchSpecificKey<Void>()
    
    private var loggingQueue: DispatchQueue
    private var loggingGroup: DispatchGroup
    private var queueSemaphore: DispatchSemaphore
    private var numProcessors: Int
    private var loggerNodes: [SWLoggerNode] = []
    
    public static var maxQueueSize = 1000
    public static var logLevel: SWLoggerLevel = .verbose
    
    private init() {
        loggingQueue = DispatchQueue(label: "com.vv.SWLogger")
        loggingQueue.setSpecific(key: SWLogger.disptachKey, value: ())
        
        loggingGroup = DispatchGroup()
        
        queueSemaphore = DispatchSemaphore(value: SWLogger.maxQueueSize)
        
        numProcessors = max(ProcessInfo.processInfo.processorCount, 1)
        
        addLogger(SWPrintLogger(), level: SWPrintLogger.level)
        addLogger(SWFileLogger(), level: SWFileLogger.level)
                
        #if DEBUG
        print("SWLogger: number of processors = \(numProcessors)")
        #endif
    }
    
    private func addLogger(_ logger: SWLoggerProtocol, level: SWLoggerLevel) {
        let addBlock = { [unowned self] in
            for loggerNode in self.loggerNodes {
                if loggerNode.logger === logger && loggerNode.level == level {
                    return
                }
            }
            
            var loggerQueue: DispatchQueue
            if let queue = logger.loggerQueue {
                loggerQueue = queue
            } else {
                loggerQueue = DispatchQueue(label: "loggerQueue(\(level))")
            }
            
            let loggerNode = SWLoggerNode(logger: logger, level: level, loggerQueue: loggerQueue)
            self.loggerNodes.append(loggerNode)
        }
        
        if DispatchQueue.getSpecific(key: SWLogger.disptachKey) != nil {
            addBlock()
        } else {
            loggingQueue.sync(execute: addBlock)
        }
    }
    
    private func logMessage(_ message: SWLoggerMessage) {
        assert(DispatchQueue.getSpecific(key: SWLogger.disptachKey) != nil, "should only run on logging queue")
        
        if numProcessors > 1 {
            for loggerNode in loggerNodes {
                if loggerNode.level > message.level {
                    continue
                }
                
                loggerNode.loggerQueue.async(group: loggingGroup, execute: {
                    autoreleasepool {
                        loggerNode.logger.logMessage(message)
                    }
                })
            }
            
            _ = loggingGroup.wait(timeout: .distantFuture)
        } else {
            for loggerNode in loggerNodes {
                if loggerNode.level > message.level {
                    continue
                }
                
                loggerNode.loggerQueue.sync {
                    autoreleasepool {
                        loggerNode.logger.logMessage(message)
                    }
                }
            }
        }
        
        queueSemaphore.signal()
    }
    
    private func queueMessage(_ message: SWLoggerMessage, asynchronous: Bool) {
        let logBlock = { [unowned self] in
            _ = self.queueSemaphore.wait(timeout: .distantFuture)
            
            autoreleasepool {
                self.logMessage(message)
            }
        }
        
        if asynchronous {
            loggingQueue.async(execute: logBlock)
        } else if DispatchQueue.getSpecific(key: SWLogger.disptachKey) != nil {
            logBlock()
        } else {
            loggingQueue.sync(execute: logBlock)
        }
    }
    
    private static func dolog(_ items: [Any], separator: String, level: SWLoggerLevel, file: String, line: Int, asynchronous: Bool) {
        let string = items.map { String(describing: $0) }.joined(separator: separator)
        let message = SWLoggerMessage(message: string, level: level, filename: file, lineno: line)
        SWLogger.default.queueMessage(message, asynchronous: asynchronous)
    }
    
    private func flush() {
        assert(DispatchQueue.getSpecific(key: SWLogger.disptachKey) != nil, "should only run on logging queue")
        
        for loggerNode in loggerNodes {
            loggerNode.loggerQueue.async(group: loggingGroup, execute: {
                autoreleasepool {
                    loggerNode.logger.flush()
                }
            })
        }
        
        _ = loggingGroup.wait(timeout: .distantFuture)
    }
    
    private func doflush() {
        let flushBlock = { [unowned self] in
            autoreleasepool {
                self.flush()
            }
        }
        
        if DispatchQueue.getSpecific(key: SWLogger.disptachKey) != nil {
            flushBlock()
        } else {
            loggingQueue.sync(execute: flushBlock)
        }
    }
}

extension SWLogger {
    public static func verbose(_ items: Any..., separator: String = " ", file: String = #file, line: Int = #line, asynchronous: Bool = true) {
        dolog(items, separator: separator, level: .verbose, file: file, line: line, asynchronous: asynchronous)
    }
    
    public static func debug(_ items: Any..., separator: String = " ", file: String = #file, line: Int = #line, asynchronous: Bool = true) {
        dolog(items, separator: separator, level: .debug, file: file, line: line, asynchronous: asynchronous)
    }
    
    public static func info(_ items: Any..., separator: String = " ", file: String = #file, line: Int = #line, asynchronous: Bool = true) {
        dolog(items, separator: separator, level: .info, file: file, line: line, asynchronous: asynchronous)
    }
    
    public static func warn(_ items: Any..., separator: String = " ", file: String = #file, line: Int = #line, asynchronous: Bool = true) {
        dolog(items, separator: separator, level: .warn, file: file, line: line, asynchronous: asynchronous)
    }
    
    public static func error(_ items: Any..., separator: String = " ", toFile: Bool = true, file: String = #file, line: Int = #line, asynchronous: Bool = false) {
        dolog(items, separator: separator, level: .error, file: file, line: line, asynchronous: asynchronous)
    }
    
    public static func flush() {
        SWLogger.default.doflush()
    }
    
    public static func addLogger(_ logger: SWLoggerProtocol, level: SWLoggerLevel) {
        SWLogger.default.addLogger(logger, level: level)
    }
}

extension SWLogger {
    public static func loggerFilePaths() -> [String] {
        var result: [String] = []
        
        for loggerNode in self.default.loggerNodes {
            if let logger = loggerNode.logger as? SWFileLogger {
                let paths = logger.getLogFilePaths()
                result.append(contentsOf: paths)
            }
        }
        
        result.sort { (path1, path2) -> Bool in
            return path1 > path2
        }
        
        return result
    }
}
