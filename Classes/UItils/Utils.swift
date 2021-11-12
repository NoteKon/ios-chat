//
//  Utils.swift
//  YunZaiApp
//
//  Created by ice on 2021/11/12.
//

import Foundation
/***********多语言****************/
func localizedString(_ key: String, bundleName: String? = "YunZaiApp") -> String {
    return Bundle.localizedString(key: key, value: "", bundleName: bundleName ?? "YunZaiApp", targetClass: nil)
}
