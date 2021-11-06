//
//  DbgLangLoader.swift
//  Pods
//
//  Created by dailiangjin on 2021/06/21.
//

import Foundation
import UIKit

class DbgNetLoader: DbgDetailLoader {
    func debug_vc() -> UIViewController.Type? {
        return DbgNetViewController.self
    }
    
    func debug_title() -> String {
        return "网络监控"
    }
    
    func debug_action() {
        
    }
    
    func debug_group() -> String? {
        return "logger"
    }
    
    func debug_comment() -> String? {
        return nil
    }
}
