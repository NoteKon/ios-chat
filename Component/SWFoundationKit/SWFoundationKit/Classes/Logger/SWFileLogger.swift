//
//  SWFileLogger.swift
//  SWFoundationKit
//
//  Created by ice on 2019/11/23.
//

import Foundation

class SWFileLogger: SWLoggerProtocol {
    static var level: SWLoggerLevel = .info
    
    var loggerQueue: DispatchQueue?
    
    private let formatter = SWFileLoggerFormatter()
    private let dispatchKey = DispatchSpecificKey<SWFileLogger>()
    
    init() {
        loggerQueue = DispatchQueue(label: "SWFileLoggerQueue")
        loggerQueue?.setSpecific(key: dispatchKey, value: self)
    }
    
    func logMessage(_ message: SWLoggerMessage) {
        #if DEBUG
        assert(isOnInternalQueue, "should only run on internal queue")
        
        var message = formatter.formatLogMessage(message)
        if message.hasSuffix("\n") == false {
            message += "\n"
        }
        
        let fileHandle = currentLoggerFileHandle()
        fileHandle?.seekToEndOfFile()
        if let data = message.data(using: .utf8) {
            fileHandle?.write(data)
        }
        #endif
    }
    
    func flush() {
        #if DEBUG
        assert(isOnInternalQueue, "should only run on internal queue")
        
        let fileHandle = currentLoggerFileHandle()
        fileHandle?.synchronizeFile()
        #endif
    }
    
    private var isOnInternalQueue: Bool {
        return DispatchQueue.getSpecific(key: dispatchKey) === self
    }
    
    private func loggerFileHandle(path: String) -> FileHandle? {
        let handle = FileHandle(forWritingAtPath: path)
        handle?.seekToEndOfFile()
        return handle
    }
    
    private var loggerDirectory: URL = {
        let cache = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last
        var dir: URL
        if let cache = cache, let parent = URL(string: cache) {
            dir = parent
        } else {
            dir = URL(fileURLWithPath: NSTemporaryDirectory())
        }
        
        return dir.appendingPathComponent("SWLogger")
    }()
    
    private func currentLoggerFileHandle() -> FileHandle? {
        let filePath = currentLoggerFilePath()
        createLoggerFileIfNeeded(path: filePath)
        
        let fileHandle = loggerFileHandle(path: filePath)
        return fileHandle
    }
    
    private func currentLoggerFilePath() -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())
        return loggerDirectory.appendingPathComponent("log-\(dateString).txt").absoluteString
    }
    
    private func createLoggerFileIfNeeded(path: String) {
        if !FileManager.default.fileExists(atPath: path) {
            do {
                let url = URL(fileURLWithPath: path).deletingLastPathComponent()
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("can't create logger: \(error)")
            }
            
            FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        }
    }
    
    func getLogFilePaths() -> [String] {
        let contents = try? FileManager.default.contentsOfDirectory(atPath: loggerDirectory.absoluteString)
        let urls = contents?.map { loggerDirectory.appendingPathComponent($0).absoluteString }
        let logs = urls?.filter { $0.hasSuffix(".txt") }
        return logs ?? []
    }
}

class SWFileLoggerFormatter: SWLoggerFormatter {
    func formatLogMessage(_ message: SWLoggerMessage) -> String {
        let dateString = toLoggerFormat(Date())
        let result = String(format: "%@ [%@] %@",
                            dateString, message.level.description, message.message)
        return result
    }
}
