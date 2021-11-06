//
//  SWAppHelper.swift
//  SWBusinessKit
//
//  Created by ice on 2019/9/24.
//

import Foundation

public class SWAppHelper {
    public static func getAppUAName() -> String {
        let bundleId = SWAppInfo.appBundleID
        switch bundleId {
        case "com.vv.life":
            return "VVLife"
        case "com.vv.life2b":
            return "VVPartner"
        case "com.vv.rider":
            return "VVRider"
        case "com.vv.bdtool":
            return "VVHunter"
        default:
            return "Unknown"
        }
    }
}
