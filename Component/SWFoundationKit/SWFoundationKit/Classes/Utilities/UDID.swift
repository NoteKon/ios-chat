//
//  UDID.swift
//  SWFoundationKit
//
//  Created by ice on 2020/6/5.
//

import Foundation
import KeychainSwift

fileprivate let KEY = "UUID"

public struct UDID {
    
    public init() {
        // nothing
    }
    
    /// UDID String
    public var udidString: String {
        let keychain = KeychainSwift()
        if let udid = keychain.get(KEY) {
            return udid
        }
        
        let udid: String
        if let identifierForVendor = UIDevice.current.identifierForVendor {
            udid = identifierForVendor.uuidString.replacingOccurrences(of: "-", with: "")
        } else {
            udid = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        }
        keychain.set(udid, forKey: KEY, withAccess: .accessibleAfterFirstUnlockThisDeviceOnly)
        return udid
    }
    
}
