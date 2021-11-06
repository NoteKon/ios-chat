//
//  SWTouchExButton.swift
//  SWUIKit
//
//  Created by huang on 2019/12/6.
//

import UIKit

public protocol SWTouchExtensible {
    var touchExInsets: UIEdgeInsets { get set }
}

open class SWTouchExButton: UIButton, SWTouchExtensible {
    public var touchExInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var exbounds = self.bounds
        exbounds.origin.x -= touchExInsets.left
        exbounds.origin.y -= touchExInsets.top
        exbounds.size.width += touchExInsets.left + touchExInsets.right
        exbounds.size.height += touchExInsets.top + touchExInsets.bottom
        
        return exbounds.contains(point)
    }

}
