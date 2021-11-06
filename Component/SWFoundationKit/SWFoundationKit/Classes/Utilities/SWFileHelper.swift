//
//  SWFileHelper.swift
//  LetsMeet
//

import Foundation

/// 路径管理
public enum SWPath {
    /// 用户主目录
    case home
    /// 缓存文件目录
    case caches
    /// 文档文件目录
    case document
    /// 临时文件目录
    case temporary
    /// 搜索路径
    case directory(FileManager.SearchPathDirectory)
    /// 自定义文件目录
    case url(URL)
    
    /// 获取目录的URL地址
    public var url: URL {
        switch self {
        case .home:
            return URL(fileURLWithPath: NSHomeDirectory())
        case .caches:
//            if SWAppInfo.isSimulator {
//                return URL(fileURLWithPath: "/tmp")
//            }
            return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        case .document:
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        case .temporary:
            return URL(fileURLWithPath: NSTemporaryDirectory())
        case .directory(let path):
            return FileManager.default.urls(for: path, in: .userDomainMask).first!
        case .url(let url):
            return url
        }
    }
    
    /// 获取目录的路径
    public var path: String {
        return self.url.path
    }
    
    /// 是否是普通文件
    public var isFile: Bool {
        return url.isFile
    }
    
    /// 是否是目录
    public var isDirectory: Bool {
        return url.isDirectory
    }
    
    /// 文件是否存在
    public var isExists: Bool {
        return url.fileExists
    }
    
    /// Returns a directory enumerator object that can be used to perform a deep enumeration of the directory at the specified URL.
    /// - Parameters:
    ///   - keys: An array of keys that identify the properties that you want pre-fetched for each item in the enumeration. The values for these keys are cached in the corresponding `NSURL` objects. You may specify nil for this parameter. For a list of keys you can specify, see `URLResourceKey`.
    ///   - mask: Options for the enumeration. For a list of valid options, see `FileManager.DirectoryEnumerationOptions`.
    ///   - handler: An optional error handler block for the file manager to call when an error occurs. The handler block should return true if you want the enumeration to continue or false if you want the enumeration to stop. The block takes the following parameters:
    ///   `url`: A URL that identifies the item for which the error occurred.
    ///   `error`: An NSError object that contains information about the error.
    ///   If you specify nil for this parameter, the enumerator object continues to enumerate items as if you had specified a block that returned true.
    /// - Returns: An directory enumerator object that enumerates the contents of the directory at url. If url is a filename, the method returns an enumerator object that enumerates no files—the first call to nextObject() returns nil.
    /// - SeeAlso: `FileManager.enumerator(at:includingPropertiesForKeys:options:errorHandler:)`
    public func enumerator(includingPropertiesForKeys keys: [URLResourceKey]? = nil, options mask: FileManager.DirectoryEnumerationOptions = [], errorHandler handler: ((URL, Error) -> Bool)? = nil) -> FileManager.DirectoryEnumerator? {
        return FileManager.default.enumerator(at: self.url, includingPropertiesForKeys: keys, options: mask, errorHandler: handler)
    }
    
    /// 遍历目录（递归子目录）
    /// - Parameter handler: 遍历处理代码块
    public func walk(_ handler: (URL) -> Void) {
        enumerator()?.forEach { path in
            if let path = path as? URL {
                handler(path)
            }
        }
    }
    
    /// 处理相对路径
    /// - Parameters:
    ///   - path: 相对路径
    ///   - root: 根路径
    /// - Returns: 处理后的路径
    public func resolve(_ path: String) -> SWPath {
        if path.hasPrefix("/") {
            return .url(URL(fileURLWithPath: path))
        }
        var url = self.url
        for part in path.split(separator: "/") {
            if part == "." {
                continue
            } else if part == ".." {
                url = url.deletingLastPathComponent()
            } else if !part.isEmpty {
                url = url.appendingPathComponent(String(part))
            }
        }
        
        return .url(url)
    }
    
    /// 向文件写入内容
    /// - Parameter data: 写入文件的数据
    /// - Returns: 是否写入成功
    @discardableResult
    public func write(data: Data?) -> Bool {
        return SWFileHelper.write(data, to: url)
    }
    
    /// 读取文件内容
    /// - Returns: 文件内容
    public func readData() -> Data? {
        return SWFileHelper.read(from: url)
    }
    
    /// 删除文件
    /// - Returns: 是否删除成功
    @discardableResult
    public func removeFile() -> Bool {
        return SWFileHelper.remove(url)
    }
    
    /// 复制文件
    /// - Parameter path: 目标文件路径
    /// - Returns: 是否复制成功
    @discardableResult
    public func copy(to path: SWPath) -> Bool {
        return SWFileHelper.copy(url, to: path.url)
    }
    
    /// 移动文件
    /// - Parameter path: 目标文件路径
    /// - Returns: 是否移动成功
    @discardableResult
    public func move(to path: SWPath) -> Bool {
        return SWFileHelper.move(url, to: path.url)
    }
}

public struct SWFileHelper {
    
    /// 向文件写入内容
    /// - Parameters:
    ///   - data: 写入文件的数据
    ///   - file: 文件URL
    /// - Returns: 是否写入成功
    @discardableResult
    public static func write(_ data: Data?, to file: URL) -> Bool {
        guard let data = data else {
            SWLogger.debug("无法将 nil 值写入文件中")
            return false
        }
        guard SWFileHelper.prepareToWrite(file) else { return false }
        
        do {
            try data.write(to: file)
//            SWLogger.debug("写入文件: \(file.path) (\(data.count) bytes)")
            return true
        } catch let error {
            SWLogger.error("写入文件失败: \(error)")
            return false
        }
    }
    
    /// 读取文件内容
    /// - Parameter file: 文件URL
    /// - Returns: 文件内容
    public static func read(from file: URL) -> Data? {
        do {
            let data = try Data(contentsOf: file)
//            SWLogger.debug("读取文件: \(file.path) (\(data.count) bytes)")
            return data
        } catch let error {
            SWLogger.error("读取文件失败: \(error)")
            return nil
        }
    }
    
    /// 将图片信息写入文件中(保存为PNG格式)
    /// - Parameters:
    ///   - image: 图片内容
    ///   - file: 文件URL
    /// - Returns: 是否写入成功
    @discardableResult
    public static func write(image: UIImage, to file: URL) -> Bool {
        guard let data = image.pngData(), SWFileHelper.prepareToWrite(file) else { return false }
        
        let filename: URL
        if file.path.hasSuffix(".png") {
            filename = file
        } else {
            filename = file.appendingPathExtension("png")
        }
        return SWFileHelper.write(data, to: filename)
    }
    
    /// 读取文件的全部属性
    /// - Parameter file: 文件URL
    /// - Returns: 文件属性列表
    public static func attributes(of file: URL) -> [FileAttributeKey : Any]? {
        do {
//            SWLogger.debug("读取文件属性: \(file.path)")
            return try FileManager.default.attributesOfItem(atPath: file.path)
        } catch let error {
            SWLogger.error("读取文件属性失败: \(error)")
            return nil
        }
    }
    
    /// 读取文件属性
    /// - Parameters:
    ///   - key: 属性名称
    ///   - file: 文件URL
    /// - Returns: 文件属性值
    public static func attribute(forKey key: FileAttributeKey, of file: URL) -> Any? {
        return SWFileHelper.attributes(of: file)?[key]
    }
    
    /// 获取文件类型
    /// - Parameter file: 文件URL
    /// - Returns: 文件类型
    public static func fileType(of file: URL) -> FileAttributeType {
        if let fileType = attribute(forKey: .type, of: file) as? FileAttributeType {
            return fileType
        }
        return .typeUnknown
    }
    
    /// 判断是否是普通文件
    /// - Parameter file: 文件URL
    /// - Returns: 是否是普通文件
    public static func isFile(_ file: URL) -> Bool {
        return fileType(of: file) == .typeRegular
    }
    
    /// 判断是否是目录
    /// - Parameter file: 文件URL
    /// - Returns: 是否是目录
    public static func isDirectory(_ file: URL) -> Bool {
        return fileType(of: file) == .typeDirectory
    }
    
    /// 文件是否存在
    /// - Parameter path: 文件URL
    /// - Returns: 文件是否存在
    public static func exists(at path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    /// 文件是否存在
    /// - Parameter url: 文件URL
    /// - Returns: 文件是否存在
    public static func exists(at url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    /// 删除文件
    /// - Parameter file: 文件URL
    /// - Returns: 是否删除成功
    @discardableResult
    public static func remove(_ file: URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: file)
//            SWLogger.debug("删除文件: \(file.path)")
            return true
        } catch let error {
            SWLogger.error("删除文件失败: \(error)")
            return false
        }
    }
    
    /// 复制文件
    /// - Parameters:
    ///   - srcFile: 源文件URL
    ///   - destFile: 目标文件URL
    /// - Returns: 是否复制成功
    @discardableResult
    public static func copy(_ srcFile: URL, to destFile: URL) -> Bool {
        guard SWFileHelper.prepareToWrite(destFile) else { return false }
        do {
            try FileManager.default.copyItem(at: srcFile, to: destFile)
//            SWLogger.debug("复制文件: \(srcFile.path) 到 \(destFile.path)")
            return true
        } catch let error {
            SWLogger.error("复制文件失败: \(error)")
            return false
        }
    }
    
    /// 移动文件
    /// - Parameters:
    ///   - srcFile: 源文件URL
    ///   - destFile: 目标文件URL
    /// - Returns: 是否移动成功
    @discardableResult
    public static func move(_ srcFile: URL, to destFile: URL) -> Bool {
        guard SWFileHelper.prepareToWrite(destFile) else { return false }
        do {
            try FileManager.default.moveItem(at: srcFile, to: destFile)
//            SWLogger.debug("移动文件: \(srcFile.path) 到 \(destFile.path)")
            return true
        } catch let error {
            SWLogger.error("移动文件失败: \(error)")
            return false
        }
    }
    
    private static func prepareToWrite(_ file: URL) -> Bool {
        let manager = FileManager.default
        let dir = file.deletingLastPathComponent()
        if !manager.fileExists(atPath: dir.path) {
            do {
                try manager.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
//                SWLogger.debug("创建目录: \(dir.path)")
            } catch let error {
                SWLogger.error("创建目录失败: \(error)")
                return false
            }
        }
        return true
    }
}

extension URL {
    /// 是否是普通文件（仅当`isFileURL`为`true`时有效）
    public var isFile: Bool {
        guard isFileURL else {
            return false
        }
        return SWFileHelper.isFile(self)
    }
    
    /// 是否是目录（仅当`isFileURL`为`true`时有效）
    public var isDirectory: Bool {
        guard isFileURL else {
            return false
        }
        return SWFileHelper.isDirectory(self)
    }
    
    /// 文件是否存在（仅当`isFileURL`为`true`时有效）
    public var fileExists: Bool {
        guard isFileURL else {
            return false
        }
        return SWFileHelper.exists(at: self)
    }
}
