//
//  ViewController.swift
//  SWBusinessKit
//
//  Created by huangguiyang on 09/02/2019.
//  Copyright (c) 2019 huangguiyang. All rights reserved.
//

import UIKit
import SWFoundationKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        testScreen()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func testScreen() {
        let height = Int(SCREEN_HEIGHT * UIScreen.main.scale)
        let widht = Int(SCREEN_WIDTH * UIScreen.main.scale)
        SWLogger.debug("screen:\(height) \(widht)")
    }

}

