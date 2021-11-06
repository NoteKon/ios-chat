//
//  SWAlert.swift
//  SWUIKit
//
//  Created by huang on 2019/9/3.
//  Copyright © 2019 vv. All rights reserved.
//

import Foundation
import UIKit
import SWFoundationKit

public typealias UIAlertViewHandler = (Int) -> Void

public class SWAlert {
    
}

extension SWAlert {
    public class func quickAlert(title: String?) {
        quickAlert(title: title, message: nil, cancel: nil)
    }
    
    public class func quickAlert(message: String?) {
        quickAlert(title: nil, message: message, cancel: nil)
    }
    
    public class func quickAlert(title: String?, message: String?) {
        quickAlert(title: title, message: message, cancel: nil)
    }
    
    public class func quickAlert(title: String?, message: String?, cancel: String?,
                                 using: UIViewController? = nil, animated: Bool = true) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: cancel ?? localizedString("sw_ok"), style: .default, handler: nil)
        vc.addAction(action)
        if let fromVC = using {
            fromVC.present(vc, animated: animated, completion: nil)
        } else {
            SWRouter.present(vc, animated: animated, completion: nil)
        }
    }
}

extension SWAlert {
    @discardableResult
    public class func showActionSheet(title: String?,
                                      message: String?,
                                      cancel: String?,
                                      others: [String]?,
                                      animated: Bool = true,
                                      using: UIViewController? = nil,
                                      handler: UIAlertViewHandler?) -> UIAlertController {
        return show(title: title, message: message, cancel: cancel, others: others,
                    preferredStyle: .actionSheet, using: using, animated: animated, handler: handler)
    }
    
    @discardableResult
    public class func showAlert(title: String?,
                                message: String?,
                                cancel: String?,
                                others: [String]?,
                                preferredAction: Int = -1,
                                animated: Bool = true,
                                using: UIViewController? = nil,
                                handler: UIAlertViewHandler?) -> UIAlertController {
        return show(title: title, message: message, cancel: cancel, others: others, preferredStyle: .alert,
                    preferredAction: preferredAction, using: using, animated: animated, handler: handler)
    }
    
    @discardableResult
    private class func show(title: String?,
                            message: String?,
                            cancel: String?,
                            others: [String]?,
                            preferredStyle: UIAlertController.Style,
                            preferredAction: Int = -1,
                            using: UIViewController? = nil,
                            animated: Bool = true,
                            handler: UIAlertViewHandler?) -> UIAlertController {
        let vc = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        if let otherStrs = others {
            for (index, elment) in otherStrs.enumerated() {
                let action = UIAlertAction(title: elment, style: .default) { (act) in
                    handler?(index)
                }
                action.setTextColor(UIColor(hex: 0x333333))
                vc.addAction(action)
                if index == preferredAction {
                    vc.preferredAction = action
                }
            }
        }
        if let str = cancel {
            let action = UIAlertAction(title: str, style: .cancel) { (act) in
                handler?(-1)
            }
            action.setTextColor(UIColor(hex: 0x666666))
            vc.addAction(action)
        }
        
        if let fromVC = using {
            fromVC.present(vc, animated: animated, completion: nil)
        } else {
            SWRouter.present(vc, animated: animated, completion: nil)
        }
        
        return vc
    }
}

extension SWAlert {
    @discardableResult
    public class func showMessageAlert(title: String?,
                                       titleColor: UIColor? = UIColor(hex: 0x333333),
                                       titleFont: UIFont? = UIFont.pingFangMedium(size: 18.0),
                                       message: String?,
                                       messageColor: UIColor? = UIColor(hex: 0x333333),
                                       messageFont: UIFont? = UIFont.pingFangRegular(size: 14.0),
                                       confirm: String?,
                                       confirmColor: UIColor? = UIColor(hex: 0x37CC89),
                                       confirmFont: UIFont? = UIFont.pingFangMedium(size: 16.0),
                                       cancel: String?,
                                       cancelColor: UIColor? = UIColor(hex: 0x666666),
                                       cancelFont: UIFont? = UIFont.pingFangMedium(size: 16.0),
                                       using: UIViewController? = nil,
                                       animated: Bool = true,
                                       handler: ((Bool) -> Void)?) -> SWControlAlertController {
        let vc = SWControlAlertController(title: title, message: message)
        vc.textAlignment = .center
        vc.titleFont = titleFont
        vc.titleColor = titleColor
        vc.messageFont = messageFont
        vc.messageColor = messageColor
        
        if let str = confirm {
            let action = SWControlAlertAction(title: str, style: .default) { [unowned vc] (act) in
                vc.dismiss(animated: animated) {
                    handler?(true)
                }
            }
            if let color = confirmColor {
                action.textColor = color
            }
            if let font = confirmFont {
                action.textFont = font
            }
            vc.addAction(action)
        }
        if let str = cancel {
            let action = SWControlAlertAction(title: str, style: .cancel) { [unowned vc] (act) in
                vc.dismiss(animated: animated) {
                    handler?(false)
                }
            }
            if let color = cancelColor {
                action.textColor = color
            }
            if let font = cancelFont {
                action.textFont = font
            }
            vc.addAction(action)
        }
        
        if let fromVC = using {
            fromVC.present(vc, animated: animated, completion: nil)
        } else {
            SWRouter.present(vc, animated: animated, completion: nil)
        }
        
        return vc
    }
//    public class func showMessageAlert(title: String?,
//                                       message: String?,
//                                       confirm: String?,
//                                       confirmColor: UIColor? = UIColor(hex: 0xFFA22D),
//                                       cancel: String?,
//                                       cancelColor: UIColor? = UIColor(hex: 0x666666),
//                                       using: UIViewController? = nil,
//                                       animated: Bool = true,
//                                       handler: ((Bool) -> Void)?) -> UIAlertController {
//        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        if let acancel = cancel {
//            let cancelAction = UIAlertAction.init(title: acancel, style: .default) { (action) in
//                handler?(false)
//            }
//            if let aCancelColor = cancelColor {
//                cancelAction.setTextColor(aCancelColor)
//            }
//            alertVC.addAction(cancelAction)
//        }
//
//        if let aconfirm = confirm {
//            let confirmAction = UIAlertAction.init(title: aconfirm, style: .default) { (action) in
//                handler?(true)
//            }
//            if let aConfirmColor = confirmColor {
//                confirmAction.setTextColor(aConfirmColor)
//            }
//            alertVC.addAction(confirmAction)
//        }
//
//        if let fromVC = using {
//            fromVC.present(alertVC, animated: animated, completion: nil)
//        } else {
//            SWRouter.present(alertVC, animated: animated, completion: nil)
//        }
//
//        return alertVC
//    }
}

extension UIAlertAction {
    
    /// 设置文字颜色
    func setTextColor(_ color: UIColor) {
        let key = "_titleTextColor"
        guard isPropertyExisted(key) else {
            return
        }
        self.setValue(color, forKey: key)
    }
    
    /// 取属性列表
    static var propertyNames: [String] {
        var outCount: UInt32 = 0
        guard let ivars = class_copyIvarList(self, &outCount) else {
            return []
        }
        var result = [String]()
        let count = Int(outCount)
        for i in 0..<count {
            let pro = ivars[i]
            guard let ivarName =  ivar_getName(pro) else {
                continue
            }
            guard let name = String(utf8String: ivarName) else {
                continue
            }
            result.append(name)
        }
        return result
    }
    
    /// 是否存在某个属性
    func isPropertyExisted(_ propertyName: String) -> Bool {
        for name in UIAlertAction.propertyNames where name == propertyName {
            return true
        }
        return false
    }
}
