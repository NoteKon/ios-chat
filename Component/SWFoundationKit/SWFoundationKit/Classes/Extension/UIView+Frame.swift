//
//  UIView+Ex.swift
//  SWFoundationKit
//
//  Created by ice on 2019/8/1.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

extension UIView {
    public var left: CGFloat {
        get {
            return self.frame.origin.x
        }
        set(newLeft) {
            var frame = self.frame
            frame.origin.x = newLeft
            self.frame = frame
        }
    }
    
    public var top: CGFloat {
        get {
            return self.frame.origin.y
        }
        
        set(newTop) {
            var frame = self.frame
            frame.origin.y = newTop
            self.frame = frame
        }
    }
    
    public var width: CGFloat {
        get {
            return self.frame.size.width
        }
        
        set(newWidth) {
            var frame = self.frame
            frame.size.width = newWidth
            self.frame = frame
        }
    }
    
    public var height: CGFloat {
        get {
            return self.frame.size.height
        }
        
        set(newHeight) {
            var frame = self.frame
            frame.size.height = newHeight
            self.frame = frame
        }
    }
    
    public var right: CGFloat {
        get {
            return self.left + self.width
        }
        set(newRight) {
            var frame = self.frame
            frame.origin.x = newRight - frame.size.width
            self.frame = frame
        }
    }
    
    public var bottom: CGFloat {
        get {
            return self.top + self.height
        }
        set(newBottom) {
            var frame = self.frame
            frame.origin.y = newBottom - frame.size.height
            self.frame = frame
        }
    }
    
    public var centerX: CGFloat {
        get {
            return self.center.x
        }
        
        set(newCenterX) {
            var center = self.center
            center.x = newCenterX
            self.center = center
        }
    }
    
    public var centerY: CGFloat {
        get {
            return self.center.y
        }
        
        set(newCenterY) {
            var center = self.center
            center.y = newCenterY
            self.center = center
        }
    }
    
    public var size: CGSize {
        get {
            return self.frame.size
        }
        
        set(newSize) {
            var frame = self.frame
            frame.size = newSize
            self.frame = frame
        }
    }
    
    public var origin: CGPoint {
        get {
            return self.frame.origin
        }
        set(newOrigin) {
            var frame = self.frame
            frame.origin = newOrigin
            self.frame = frame
        }
    }
}
