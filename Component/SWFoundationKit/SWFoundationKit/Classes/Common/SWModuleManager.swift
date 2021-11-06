//
//  SWModuleManager.swift
//  Alamofire
//
//  Created by ice on 2019/8/27.
//

import Foundation

/// 模块类
open class SWModule: NSObject {
    open class func moduleInit() {
        
    }
}

/// 模块管理
public class SWModuleManager {
    /// 模块配置文件
    static let kModuleSpecFilename = "vvmodule.plist"
    /// 键名：类名
    static let kModuleClassKey = "module.class"
    /// 键名：排序
    static let kModuleSortKey = "module.sort"
    /// 默认排序值
    static let kDefaultSortValue = 100
    
    /// 初始化所有模块
    public static func initAllModules() {
        SWLogger.debug("Initialize all modules...")
        let mainBundlePath = Bundle.main.resourcePath!
        var filePaths = [String]()
        
        let frameworksPath = (mainBundlePath as NSString).appendingPathComponent("Frameworks")
        let frameworksContents = loadFromFrameworks(frameworksPath)
        filePaths.append(contentsOf: frameworksContents)
        
        let mainContents = findBundlesInDir(mainBundlePath)
        filePaths.append(contentsOf: mainContents)
        
        let modules = filePaths.map { loadModuleWithSpecFile($0) }.sorted { $0.1 < $1.1 }
        modules.forEach { (className, _) in
            if let className = className, let clazz = NSClassFromString(className) as? SWModule.Type {
                SWLogger.debug("initializing module \(className)...")
                clazz.moduleInit()
            }
        }
    }
    
    /// 从Frameworks中寻找所有的模块描述文件
    /// - Parameter dir: Frameworks文件目录路径
    /// - Returns: 模块描述文件的路径列表
    private static func loadFromFrameworks(_ dir: String) -> [String] {
        var result = [String]()
        let frameworks = contentsInDirWithSuffix(dir, suffix: ".framework")
        for framework in frameworks {
            let frameworkPath = (dir as NSString).appendingPathComponent(framework)
            let bundles = findBundlesInDir(frameworkPath)
            result.append(contentsOf: bundles)
        }
        return result
    }
    
    /// 寻找指定framework内的模块描述文件，包含framework包含的bundle
    /// - Parameter dir: framework所在文件路径
    /// - Returns: 模块描述文件的路径列表
    private static func findBundlesInDir(_ dir: String) -> [String] {
        var result = [String]()
        
        let bundles = contentsInDirWithSuffix(dir, suffix: ".bundle")
        for bundle in bundles {
            let bundlePath = (dir as NSString).appendingPathComponent(bundle)
            let modspecPath = (bundlePath as NSString).appendingPathComponent(kModuleSpecFilename)
            if FileManager.default.fileExists(atPath: modspecPath) {
                result.append(modspecPath)
            }
        }
        
        let modspecPath = (dir as NSString).appendingPathComponent(kModuleSpecFilename)
        if FileManager.default.fileExists(atPath: modspecPath) {
            result.append(modspecPath)
        }
        
        return result
    }
    
    /// 返回指定路径中后缀为`suffix`值的文件列表
    /// - Parameters:
    ///   - dir: 指定路径
    ///   - suffix: 后缀名
    /// - Returns: 符合条件的文件路径列表
    private static func contentsInDirWithSuffix(_ dir: String, suffix: String) -> [String] {
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: dir)
            return contents.filter { $0.hasSuffix(suffix) }
        } catch {
            SWLogger.debug("can't read contents of dir: \(dir), error: \(error)")
        }
        return [String]()
    }
    
    /// 从模块描述文件中，加载模块描述类名和排序值
    /// - Parameter path: 模块描述文件路径
    /// - Returns: 模块描述类名和排序值
    private static func loadModuleWithSpecFile(_ path: String) -> (String?, Int) {
        guard let dict = parseModuleSpecFile(path) else {
            return (nil, kDefaultSortValue)
        }
        
        let sort = dict[kModuleSortKey] as? Int ?? kDefaultSortValue
        var className: String?
        if let moduleClassName = dict[kModuleClassKey] as? String {
            var alternatives = [moduleClassName]
            let prefixes = guessFrameworkName(path)
            alternatives.append(contentsOf: prefixes.map({ $0 + "." + moduleClassName }))
            for alternative in alternatives {
                if tryLoadModuleClass(alternative) {
                    className = alternative
                    break
                }
            }
        }
        
        return (className, sort)
    }
    
    /// 验证模块描述类名是否有效
    /// - Parameter moduleClassName: 模块描述类名
    /// - Returns: 类是否存在且继承于`SWModule`
    private static func tryLoadModuleClass(_ moduleClassName: String) -> Bool {
        if NSClassFromString(moduleClassName) is SWModule.Type {
            return true
        }
        return false
    }
    
    /// 从路径中推测出Framework的名称
    /// - Parameter path: 路径
    /// - Returns: Framework的名称
    private static func guessFrameworkName(_ path: String) -> [String] {
        let components = path.split(separator: "/")
        let matches = components.filter {
            $0.hasSuffix(".framework") || $0.hasSuffix(".bundle") || $0.hasSuffix(".app")
        }
        let names = matches.map({ ($0 as NSString).deletingPathExtension })
        ///FIXME: Module/App名称中带有空格，必须要转成下划线
        let fixedNames = names.map { $0.replacingOccurrences(of: " ", with: "_") }
        return fixedNames
    }
    
    /// 解析模块描述文件。将plist文件解析成Dictionary
    /// - Parameter path: 模块描述文件路径
    /// - Returns: 解析后的模块描述文件内容
    private static func parseModuleSpecFile(_ path: String) -> [String: Any]? {
        if let nsdict = NSDictionary(contentsOfFile: path) {
            return nsdict as? [String: Any]
        }
        return nil
    }
}
