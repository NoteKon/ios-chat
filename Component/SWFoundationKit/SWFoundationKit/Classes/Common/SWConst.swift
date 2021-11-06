//
//  SWConst.swift
//  SWFoundationKit
//
//  Created by ice on 2019/6/24.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

// MARK: - 基本参数
/// 屏幕宽度
public let SCREEN_WIDTH = UIScreen.main.bounds.width
/// 屏幕高度
public let SCREEN_HEIGHT = UIScreen.main.bounds.height
/// 系统版本
public let SYSTEM_VERSION = UIDevice.current.systemVersion
/// 系统版本（Int）
public let SYSTEM_VERSION_INT = UIDevice.current.systemVersion.intValue
/// 系统版本（Int）
/// 系统版本（Float）
public let SYSTEM_VERSION_FLOAT = UIDevice.current.systemVersion.floatValue
/// 系统版本（Float）

/// 是否是手机
public let IS_IPHONE = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone

let IPHONE_5  = UIScreen.instancesRespond(to:#selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width:960,height:1336), (UIScreen.main.currentMode?.size)!) : false
let IPHONE_6  = UIScreen.instancesRespond(to:#selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width:750,height:1334), (UIScreen.main.currentMode?.size)!) : false
let IPHONE_6P  = UIScreen.instancesRespond(to:#selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width:1242,height:2208), (UIScreen.main.currentMode?.size)!) : false
let IPHONE_6PBigMode = UIScreen.instancesRespond(to:#selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width:1125,height:2001), (UIScreen.main.currentMode?.size)!) : false
let IPHONE_X = UIScreen.instancesRespond(to:#selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width:1125,height:2436), (UIScreen.main.currentMode?.size)!) : false
let IPHONE_XR = UIScreen.instancesRespond(to:#selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width:828,height:1792), (UIScreen.main.currentMode?.size)!) : false
let IPHONE_XSM  = UIScreen.instancesRespond(to:#selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width:1242,height:2688), (UIScreen.main.currentMode?.size)!) : false
let IPHONE_XXL = (IPHONE_X||IPHONE_XR||IPHONE_XSM)


/// 适配参数
//let adaptParm: CGFloat = ((IPHONE_6P||IPHONE_XR||IPHONE_XSM) ? 1.12 : (IPHONE_6 ? 1.0 : (IPHONE_6PBigMode ? 1.01 : (IPHONE_X ? 1.0 : 0.85))))

public var IS_IPHONE_XSERIES: Bool {
    if #available(iOS 11, *) {
        guard let w = UIApplication.shared.delegate?.window, let unwrapedWindow = w else {
            return false
        }
        
        if unwrapedWindow.safeAreaInsets.bottom > 0 {
            print(unwrapedWindow.safeAreaInsets)
            return true
        }
    }
    return false
}

/// SafeArea 顶部边距
public let SAFEAREA_TOP_HEIGHT: CGFloat = (IS_IPHONE_XSERIES ? 88.0 : 64.0)
/// SafeArea 底部边距
public let SAFEAREA_BOTTOM_HEIGHT: CGFloat = (IS_IPHONE_XSERIES ? 34.0 : 0.0)
