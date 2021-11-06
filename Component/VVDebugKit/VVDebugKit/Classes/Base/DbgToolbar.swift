//
//  DbgToolbar.swift
//  Alamofire
//
//  Created by huang on 2019/9/4.
//

import UIKit
import SWFoundationKit

class DbgToolbar: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .orange
        self.isUserInteractionEnabled = true
        self.alpha = 0.5
        self.layer.cornerRadius = frame.size.width/2
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toolbarTapAction(_:))))
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(toolbarPanAction(_:))))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func toolbarTapAction(_ gesture: UITapGestureRecognizer) {
        SWRouter.router(kDebugKitURL)
    }
    
    @objc func toolbarPanAction(_ gesture: UIPanGestureRecognizer) {
        var point = gesture.location(in: nil)
        let size = self.frame.size
        let kTopHeight = UIApplication.shared.statusBarFrame.height
        let kBottomHeight = SAFEAREA_BOTTOM_HEIGHT
        
        if point.x < size.width/2 {
            point.x = size.width/2
        }
        if point.x + size.width/2 > SCREEN_WIDTH {
            point.x = SCREEN_WIDTH - size.width/2
        }
        if point.y - size.height/2 < kTopHeight {
            point.y = kTopHeight + size.height/2
        }
        if point.y + size.height/2 > SCREEN_WIDTH - kBottomHeight {
            point.y = SCREEN_WIDTH - kBottomHeight - size.height/2
        }
        
        if gesture.state == .ended {
            let h1 = point.x
            let h2 = SCREEN_WIDTH - point.x
            let v1 = point.y - kTopHeight
            let v2 = SCREEN_WIDTH - kBottomHeight - point.y
            let x = min(h1, h2, v1, v2)
            
            switch x {
            case h2:
                point.x = SCREEN_WIDTH - size.width/2
            case v1:
                point.y = kTopHeight + size.height/2
            case v2:
                point.y = SCREEN_WIDTH - kBottomHeight - size.height/2
            // case h1:
            default:
                point.x = size.width/2
            }
            
            self.layer.removeAllAnimations()
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
                self.center = point
            }, completion: nil)
        } else {
            self.center = point
        }
    }
}
