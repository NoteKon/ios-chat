//
//  DbgRootViewController.swift
//  Alamofire
//
//  Created by dailiangjin on 2019/9/4.
//

import UIKit
import SWFoundationKit

protocol DbgRootViewControllerDelegate: AnyObject {
    
}

class DbgRootViewController: UIViewController {
    weak var delegate: DbgRootViewControllerDelegate?
    private var toolbar: DbgToolbar?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .clear
        let kSize = CGFloat(44)
        let frame = CGRect(x: 0, y: UIScreen.main.bounds.height/2, width: kSize, height: kSize)
        self.toolbar = DbgToolbar(frame: frame)
        self.view.addSubview(self.toolbar!)
    }
    
    func shouldReceiveTouchAtWindowPoint(point: CGPoint) -> Bool {
        var shouldReceiveTouch = false
        let localPoint = self.view.convert(point, to: nil)
        
        if self.toolbar!.frame.contains(localPoint) {
            shouldReceiveTouch = true
        }
        
        if !shouldReceiveTouch && self.presentedViewController != nil {
            shouldReceiveTouch = true
        }
        
        return shouldReceiveTouch
    }
}
