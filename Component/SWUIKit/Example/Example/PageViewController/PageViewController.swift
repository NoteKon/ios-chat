//
//  PageViewController.swift
//  SWUIKit_Example
//
//  Created by huang on 2019/11/6.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import SWUIKit

class PageViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    private var pageViewController: SWPageViewController!
    private var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageViewController = self.children.first as? SWPageViewController
        
        // Do any additional setup after loading the view.
        let vc1 = Demo1ViewController()
        let vc2 = Demo2ViewController()
        let vc3 = Demo3ViewController()
        
        pageViewController.viewControllers = [vc1, vc2, vc3]
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        index += 1
        pageViewController.selectPageAt(index: index%2, animated: true)
    }

}

class Demo1ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
}

class Demo2ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
    }
}

class Demo3ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
    }
}
