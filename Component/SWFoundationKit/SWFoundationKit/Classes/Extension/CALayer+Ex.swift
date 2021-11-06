//
//  CALayer+Ex.swift
//  SWFoundationKit
//
//  Created by ice on 2020/6/4.
//

import Foundation

extension CALayer {
    public var borderUIColor: UIColor? {
        get {
            if let borderColor = borderColor {
                return UIColor(cgColor: borderColor)
            }
            return nil
        }
        set {
            borderColor = newValue?.cgColor
        }
    }
}
