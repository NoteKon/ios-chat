//
//  SWBaseTableViewController.swift
//  SWUIKit
//
//  Created by ice on 2021/1/6.
//

import UIKit

open class SWBaseTableViewController: UITableViewController, UIGestureRecognizerDelegate {

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        fixScrollViewBug()
        fixiOS13ModelPresentStyle()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        setUpLeftBarButton()
        
        /// 测滑返回手势
        addPanGesture()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self is SWHideNavigationBar {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
        
        if self is SWHideNavigationShadow {
            setNavigationBarShadowHidden(true)
        } else {
            setNavigationBarShadowHidden(false)
        }
    }
    
    open func setUpLeftBarButton(image: UIImage? = nil, imageLeftInset: CGFloat? = -15.0) {
        var navImage: UIImage? = image
        if navImage == nil {
            navImage = loadImageNamed("sw_back_black")
        }
        let button: UIButton = UIButton.init(frame: CGRect(x: 0, y: 0, width: 54.0, height: 44.0))
        button.setImage(navImage, for: .normal)
        button.setImage(navImage, for: .highlighted)
        button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: imageLeftInset ?? -15.0, bottom: 0, right: 15.0)
        button.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: button)
    }
    
    @objc open func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIScreenEdgePanGestureRecognizer, self is SWDisablePanGesture {
            return false
        }
        return true
    }
}
