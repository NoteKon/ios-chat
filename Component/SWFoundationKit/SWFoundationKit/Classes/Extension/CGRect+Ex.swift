//
//  CGRect+Ex.swift
//  SWFoundationKit
//
//  Created by ice on 2020/6/4.
//

import Foundation

extension CGRect {
    
    public var center: CGPoint {
        get {
            return CGPoint(x: self.midX, y: self.midY)
        }
        set {
            self.origin.x = newValue.x - self.size.width / 2
            self.origin.y = newValue.y - self.size.height / 2
        }
    }
    
}
