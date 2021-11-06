//
//  DbgBaseViewController.swift
//  Alamofire
//
//  Created by dailiangjin on 2019/9/3.
//

import UIKit

class DbgBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func getBundle() -> Bundle? {
        let bundle = Bundle.resourceBundle(bundleName: "VVDebugKit", targetClass: DbgNetViewController.self)
        return bundle
    }
}
