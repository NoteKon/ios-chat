//
//  GraphicCodeViewController.swift
//  SWUIKit_Example
//
//  Created by 吴桂钊 on 2021/4/12.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import SWUIKit

class GraphicCodeViewController: UIViewController {
    
    let codeView = SWGraphicCodeView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        self.view.addSubview(codeView)
        codeView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(100)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 100, height: 35))
        }
        
//        codeView.updateCodeString(code: "xsaaa")
        codeView.showLoading(loadType: .loading)
        
        codeView.isUserInteractionEnabled = true
        codeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(refreshGraphicCode)))
    }
    
    /// 刷新
    @objc func refreshGraphicCode() {
        codeView.updateCodeString(code: "xsa2fa")
    }
    
    
}
