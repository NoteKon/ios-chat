//
//  SWKeyChain.swift
//  Pods
//
//  Created by ice on 2019/8/7.
//

import Foundation
import KeychainSwift

public class SWKeyChain {
    public static func getValue(key: String,
                                synchronzible: Bool = false,
                                accessGroup: String? = nil) -> String? {
        let keychain = KeychainSwift()
        keychain.synchronizable = synchronzible
        keychain.accessGroup = accessGroup
        let value = keychain.get(key)
        return value
    }
    
    public static func saveValue(value: String,
                                 key: String,
                                 synchronzible: Bool = false,
                                 accessGroup: String? = nil) {
        let keychain = KeychainSwift()
        keychain.synchronizable = synchronzible
        keychain.accessGroup = accessGroup
        keychain.set(value, forKey: key)
    }
    
    public static func deleteValue(key: String,
                                   synchronzible: Bool = false,
                                   accessGroup: String? = nil) {
        let keychain = KeychainSwift()
        keychain.synchronizable = synchronzible
        keychain.accessGroup = accessGroup
        keychain.delete(key)
    }
    
    public static func getUUID(key: String,
                               synchronzible: Bool = false,
                               accessGroup: String? = nil) -> String {
        // 从Keychain寻找
        if let uuid = SWKeyChain.getValue(key: key, synchronzible: synchronzible, accessGroup: accessGroup), !uuid.isEmpty {
            return uuid
        }
        // 从UserDefaults寻找
        if let uuid = UserDefaults.standard.string(forKey: "UUID"), !uuid.isEmpty {
            return uuid
        }
        
        let newuuid = UUID().uuidString
        SWKeyChain.saveValue(value: newuuid, key: key, accessGroup: accessGroup)
        UserDefaults.standard.set(newuuid, forKey: "UUID")
        return newuuid
    }
}
