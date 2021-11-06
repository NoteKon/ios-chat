//
//  UIViewController+TranslucentMask.swift
//  SWUIKit
//
//  Created by ice on 2019/7/4.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import SnapKit

var key: Void?

extension UIViewController {
    
    var transflucentView: UIView? {
        get {
            return objc_getAssociatedObject(self, &key) as? UIView
        }
        
        set {
            objc_setAssociatedObject(self, &key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func addTranslucentMask() {
        let view: UIView = UIView.init()
        self.view.addSubview(view)
        view.snp.makeConstraints({ (make) in
            make.top.bottom.right.left.equalTo(self.view)
        })
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        self.transflucentView = view
        
        self.view.bringSubviewToFront(view)
    }
    
    public func removeTranslucentMask() {
        self.transflucentView?.alpha = 1
        UIView.animate(withDuration: 0.25, animations: {
            self.transflucentView?.alpha = 0
        }) { (isFinish) in
            self.transflucentView?.removeFromSuperview()
        }
    }
}
