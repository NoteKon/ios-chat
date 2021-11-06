//
//  DbgWindow.swift
//  Alamofire
//
//  Created by dailiangjin on 2019/9/4.
//

import Foundation
import UIKit

protocol DbgWindowEventDelegate: AnyObject {
    func shouldHandleTouchAtPoint(point: CGPoint) -> Bool
}

class DbgWindow: UIWindow {
    weak var eventDelegate: DbgWindowEventDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        #if swift(>=4.2)
        self.windowLevel = UIWindow.Level.alert
        #else
        self.windowLevel = UIWindowLevelAlert
        #endif
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var pointInside = false
        if let delegate = eventDelegate, delegate.shouldHandleTouchAtPoint(point: point) {
            pointInside = super.point(inside: point, with: event)
        }
        return pointInside
    }
}
