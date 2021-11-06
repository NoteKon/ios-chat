//
//  VVDebugKitModule.swift
//  Alamofire
//
//  Created by dailiangjin on 2019/9/5.
//

import Foundation
import SWFoundationKit

public class VVDebugKitModule: SWModule {
    public override class func moduleInit() {
        VVDebugKit.default.show()
    }
}
