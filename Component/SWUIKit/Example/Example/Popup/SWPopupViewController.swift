//
//  SWPopupViewController.swift
//  SWUIKit_Example
//
//  Created by julian on 2020/5/6.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import SWUIKit

class SWPopupViewController: UIViewController {

    lazy var menuView: SWPopMenuView = {
        let view = SWPopMenuView()
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func showPopUp(_ sender: Any) {
        var menus: [SWPopupMenuModel] = []
        for i in 0..<5 {
            let model = SWPopupMenuModel()
            model.text = String(format: "title_%d", i)
            model.icon = "sw_icon_dropdown"
            menus.append(model)
        }
        
        menuView.show(menus)
    }
    
}
