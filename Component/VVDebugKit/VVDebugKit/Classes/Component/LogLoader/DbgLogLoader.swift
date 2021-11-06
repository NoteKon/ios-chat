//
//  DbgLogLoader.swift
//  VVDebugKit
//
//  Created by dailiangjin on 2019/11/28.
//

import Foundation

class DbgLogLoader: DbgDetailLoader {    
    func debug_vc() -> UIViewController.Type? {
        return DbgLogViewController.self
    }
    
    func debug_title() -> String {
        return "Logs"
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
