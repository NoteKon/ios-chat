//
//  DbgEditEnvLoader.swift
//  VVDebugKit
//
//  Created by dailiangjin on 2020/4/10.
//

import Foundation

class DbgEditEnvLoader: DbgDetailLoader {
    func debug_vc() -> UIViewController.Type? {
        return DbgEditEnvViewController.self
    }
    
    func debug_title() -> String {
        return "Edit Env"
    }
    
    func debug_action() {
        
    }
    
    func debug_group() -> String? {
        return "common"
    }
    
    func debug_comment() -> String? {
        return nil
    }
}
