//
//  String+Locale.swift
//  VVLife
//
//  Created by vv_ice on 2020/1/13.
//  Copyright © 2020 vv. All rights reserved.
//

import Foundation

public extension String {
    
    func localizedImageName(isH5Image: Bool = false) -> String {
        let locale = UIDevice.currentLocale().languageCode ?? kLanguageEn
        if locale == kLanguageZh {
            return self + "_zh"
        } else {
            return isH5Image ? self + "_\(locale)" : self
        }
    }
    
    func localizedUrl() -> String {
        var localizedStr = self
        if self.contains("?") {
            localizedStr += "&lang=\(UIDevice.currentLocale().genericIdentifier)"
        } else {
            localizedStr += "?lang=\(UIDevice.currentLocale().genericIdentifier)"
        }
        return localizedStr
    }
}
