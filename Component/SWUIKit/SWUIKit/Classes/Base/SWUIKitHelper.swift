//
//  SWUIKitHelper.swift
//  Alamofire
//
//  Created by huang on 2019/9/18.
//

import Foundation
import SWFoundationKit

/***********多语言****************/
func localizedString(_ key: String, bundleName: String? = "SWUIKit") -> String {
    return Bundle.localizedString(key: key, value: "", bundleName: bundleName ?? "SWUIKit", targetClass: nil)
}

@discardableResult
func loadNibNamed(_ name: String, owner: Any?, options: [UINib.OptionsKey: Any]? = nil) -> [Any]? {
    return Bundle.loadNibNamed(name, owner: owner, bundleName: "SWUIKit", targetClass: SWUIKitModule.self)
}

func loadImageNamed(_ name: String) -> UIImage? {
    return Bundle.loadImage(name: name, bundleName: "SWUIKitImages", targetClass: SWUIKitModule.self)
}

func getCurrentBundle() -> Bundle? {
    return Bundle.resourceBundle(bundleName: "SWUIKit", targetClass: SWUIKitModule.self)
}
