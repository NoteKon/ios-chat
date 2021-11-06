//
//  SWBusinessKitModule.swift
//  Alamofire
//
//  Created by ice on 2019/9/5.
//

import Foundation
import SWFoundationKit

public class SWBusinessKitModule: SWModule {
    public override class func moduleInit() {
        _ = EnvironmentManager.default
        SWNetworking.initReachability()
        SWNetWorking.initSystemUserAgent()
        UIImageView.addWebPParsing()
    }
}
