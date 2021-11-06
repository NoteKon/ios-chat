//
//  UIEdgeInsets+Ex.swift
//  VVLife
//
//  Created by huangxianhui on 2020/9/3.
//  Copyright © 2020 vv. All rights reserved.
//

import Foundation

public extension UIEdgeInsets {
    var horizontal: CGFloat {
        return self.left + self.right
    }
    var vertical: CGFloat {
        return self.top + self.bottom
    }
}
