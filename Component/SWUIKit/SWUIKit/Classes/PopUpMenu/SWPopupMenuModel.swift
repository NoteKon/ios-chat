//
//  SWPopupMenuModel.swift
//  Pods
//
//  Created by julian on 2020/5/6.
//

import UIKit
import HandyJSON

public class SWPopupMenuModel: HandyJSON {
    /// 图标名
    public var icon: String?
    /// 文本
    public var text: String?
    /// 资源bundle名，如用户端"VVLife"
    public var bundleName: String?
    /// 资源bundle(for: aclass)
    public var targetClass: AnyClass?
    
    public required init() {}
    
    init(icon: String?, text: String?, bundleName: String?, targetClass: AnyClass?) {
        self.icon = icon
        self.text = text
        self.bundleName = bundleName
        self.targetClass = targetClass
    }
}
