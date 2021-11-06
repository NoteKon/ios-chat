//
//  CGFloat+Ex.swift
//  SWFoundationKit
//
//  Created by ice on 2021/8/28.
//

/// 纯代码适配方案
import Foundation
extension NSInteger {
    /// 按设计稿屏幕宽度缩放比例，默认iPhoneX
    /// - Returns: 宽度缩放比例
    public func scaleW(designWidth: CGFloat = 375) -> CGFloat {
        return SCREEN_WIDTH / designWidth * CGFloat(self)
    }
    
    /// 按设计稿屏幕高度缩放比例，默认iPhoneX
    /// - Returns: 高度缩放比例
    public func scaleH(designHeight: CGFloat = 812) -> CGFloat {
        return SCREEN_HEIGHT / designHeight * CGFloat(self)
    }
}

extension CGFloat {
    /// 按设计稿屏幕宽度缩放比例，默认iPhoneX
    /// - Returns: 宽度缩放比例
    public func scaleW(designWidth: CGFloat = 375) -> CGFloat {
        return SCREEN_WIDTH / designWidth * CGFloat(self)
    }
    
    /// 按设计稿屏幕高度缩放比例，默认iPhoneX
    /// - Returns: 高度缩放比例
    public func scaleH(designHeight: CGFloat = 812) -> CGFloat {
        return SCREEN_HEIGHT / designHeight * CGFloat(self)
    }
}
