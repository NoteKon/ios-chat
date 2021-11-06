//
//  Error+Ex.swift
//  VVPartner
//
//  Created by huang on 2019/10/26.
//  Copyright © 2019 vv. All rights reserved.
//

import Foundation
import SWBusinessKit

extension Error {
    public var simpleNetErrorDescription: String {
        if SWNetWorking.reachabilityStatus().reachable {
            #if DEBUG
            if let error = self as? SWError, let code = error.code {
                return String(format: localizedString("vl_network_error_fmt"), code)
            }
            return localizedDescription
            #else
            return String(format: localizedString("sw_network_error"))
            #endif
        }
        return localizedString("sw_errorview_no_network")
    }
    
    /// 系统错误的提示
    public var systemErrorDescription: String {
        return localizedString("sw_network_system_error")
    }
    
    /// 系统错误的提示
    public static var systemErrorDescription: String {
        return localizedString("sw_network_system_error")
    }
}
