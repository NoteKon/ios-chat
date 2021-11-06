//
//  EnvironmentManager.swift
//  Alamofire
//
//  Created by ice on 2019/9/2.
//

import Foundation

public var vdc_vv_com_sg: String {
    return EnvironmentManager.default.get(.vdc_vv_com_sg)
}

public var h5_host: String {
    return EnvironmentManager.default.get(.h5_host)
}

//public var logan_host: String {
//    return EnvironmentManager.default.get(.logan_host)
//}

public var app_update: String {
    return EnvironmentManager.default.get(.app_update)
}

public enum Environment: CustomStringConvertible, CaseIterable {
    case dev
    case test
    case pre
    case release
    
    public var description: String {
        switch self {
        case .dev:
            return "Develop"
        case .test:
            return "Test"
        case .pre:
            return "Pre"
        case .release:
            return "Release"
        }
    }
    
    /// - Note: 忽略大小写
    public init?(desc: String) {
        for caseName in Environment.allCases where desc.uppercased() == "\(caseName)".uppercased() {
            self = caseName
            return
        }
        return nil
    }
}

public final class EnvironmentManager {
    
    public enum Keys: String, CaseIterable, CustomStringConvertible {
        case vdc_vv_com_sg = "vdc.vv.com.sg"
        case h5_host = "h5.host"
        //case logan_host = "logan.host"
        case app_update = "app.update"
        
        public var description: String {
            switch self {
            case .vdc_vv_com_sg:
                return "Main Host"
            case .h5_host:
                return "H5 Host"
//            case .logan_host:
//                return "Logan Host"
            case .app_update:
                return "App Update"
            }
        }
    }
    
    public static let `default` = EnvironmentManager()
        
    public var env: Environment {
        didSet {
            saveEnv()
        }
    }
    private var hostMap: [Environment: [Keys: String]]
    private var hostNameCahe: [String]
    // 指定域名加密请求地址
    public  var exEnCodeHosts: [String] = []
    private var lock: NSRecursiveLock
    
    private init() {
        lock = NSRecursiveLock()
        hostNameCahe = []
        hostMap = [:]
        for env in Environment.allCases {
            hostMap[env] = [:]
        }
        
        #if DEBUG
        self.env = .dev
        #else
        self.env = .release
        #endif
        
        // 先加载plist配置文件
        if let env = readConfiguredEnv() {
            self.env = env
        }
        
//        #if DEBUG
        // 如果有调试工具配置，则覆盖上一个配置
        if let env = loadEnv() {
            self.env = env
        }
//        #endif
        
        buildHostMap()
        buildHostNameCache()
        SWLogger.debug("Environment = \(self.env)")
    }
    
    public func get(_ key: Keys?) -> String {
        return get(key, env: self.env)
    }
    
    public func get(_ key: Keys?, env: Environment?) -> String {
        guard let key = key, let env = env else { return "" }
        lock.lock()
        defer { lock.unlock() }
        return hostMap[env]?[key] ?? ""
    }
    
    public func set(_ value: String?, for key: Keys?) {
        set(value, for: key, env: self.env)
    }
    
    public func set(_ value: String?, for key: Keys?, env: Environment?) {
        guard let key = key, let env = env else { return }
        lock.lock()
        defer { lock.unlock() }
        hostMap[env]?[key] = value
        buildHostNameCache()
    }
    
    public func isVVHost(_ url: URL?) -> Bool {
        guard let host = url?.host else { return false }
        
        // BDTool
        if host == "120.42.36.28" {
            return true
        }
        
        lock.lock()
        defer { lock.unlock() }
        
        return hostNameCahe.contains(host)
    }
    
    private func buildHostMap() {
        // 开发环境
        hostMap[.dev]?[.vdc_vv_com_sg] = "http://dev.api-morsun.12316x.com"
        hostMap[.dev]?[.h5_host] = "http://dev.api-morsun.12316x.com"
        hostMap[.dev]?[.app_update] = "http://dev.api-morsun.12316x.com"
        
        // 测试
        hostMap[.test]?[.vdc_vv_com_sg] = "http://dev.api-morsun.12316x.com"
        hostMap[.test]?[.h5_host] = "http://dev.api-morsun.12316x.com"
        hostMap[.test]?[.app_update] = "http://dev.api-morsun.12316x.com"
        
        // 预发
        hostMap[.pre]?[.vdc_vv_com_sg] = "http://dev.api-morsun.12316x.com"
        hostMap[.pre]?[.h5_host] = "http://dev.api-morsun.12316x.com"
        hostMap[.pre]?[.app_update] = "http://dev.api-morsun.12316x.com"
        
        // 生产环境
        hostMap[.release]?[.vdc_vv_com_sg] = "http://dev.api-morsun.12316x.com"
        hostMap[.release]?[.h5_host] = "http://dev.api-morsun.12316x.com"
        hostMap[.release]?[.app_update] = "http://dev.api-morsun.12316x.com"
    }
    
    private func buildHostNameCache() {
        var hosts: [String] = []
        let keys: [Keys] = [.vdc_vv_com_sg, .app_update]
        for env in Environment.allCases {
            for key in keys {
                if let envURL = hostMap[env]?[key],
                    let envHost = URL(string: envURL)?.host {
                    hosts.append(envHost)
                }
            }
        }
        hosts += exEnCodeHosts
        hostNameCahe = hosts
    }
    
    private func saveEnv() {
        UserDefaults.standard.set("\(self.env)", forKey: "env")
        UserDefaults.standard.synchronize()
    }
    
    private func loadEnv() -> Environment? {
        if let str = UserDefaults.standard.value(forKey: "env") as? String,
            let env = Environment(desc: str) {
            return env
        }
        return nil
    }
    
    private func readConfiguredEnv() -> Environment? {
        if let plistPath = Bundle.main.path(forResource: "vvmodule", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: plistPath) as? [String: Any] {
            let envName = dict["env"] as? String
            return Environment(desc: envName ?? "")
        }
        return nil
    }    
}
