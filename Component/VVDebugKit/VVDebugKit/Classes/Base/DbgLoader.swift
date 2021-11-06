//
//  DbgLoader.swift
//  Alamofire
//
//  Created by dailiangjin on 2019/9/3.
//

import Foundation

public protocol DbgLoader {    
    func debug_title() -> String
    func debug_action()
    
    func debug_group() -> String?
    func debug_comment() -> String?
}

public protocol DbgSwitchLoader: DbgLoader {
    func debug_enable() -> Bool
}

public protocol DbgDetailLoader: DbgLoader {
    func debug_vc() -> UIViewController.Type?
}
