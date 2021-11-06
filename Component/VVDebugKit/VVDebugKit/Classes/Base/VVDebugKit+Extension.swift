//
//  VVDebugKit+Extension.swift
//  VVDebugKit
//
//  Created by dailiangjin on 2020/3/10.
//

import Foundation

extension VVDebugKit {
    func addLoader(_ loader: DbgLoader) {
        var loaders: [DbgLoader] = []
        if let others = self.loaders {
            loaders.append(contentsOf: others)
        }
        loaders.append(loader)
        self.loaders = loaders
    }
    
    public func addLoader(title: String, group: String? = nil, comment: String? = nil,
                          action: @escaping () -> Void) {
        let loader = DbgLoaderImpl()
        loader.title = title
        loader.group = group
        loader.comment = comment
        loader.actionBlock = action
        addLoader(loader)
    }
    
    public func addSwitchLoader(title: String, group: String? = nil, comment: String? = nil,
                                enable: @escaping () -> Bool, action: @escaping () -> Void) {
        let loader = DbgSwitchLoaderImpl()
        loader.title = title
        loader.group = group
        loader.comment = comment
        loader.enableBlock = enable
        loader.actionBlock = action
        addLoader(loader)
    }
    
    public func addDetailLoader(title: String, group: String? = nil, comment: String? = nil,
                                viewController: UIViewController.Type) {
        let loader = DbgDetailLoaderImpl()
        loader.title = title
        loader.group = group
        loader.comment = comment
        loader.viewController = viewController
        addLoader(loader)
    }
}

class DbgLoaderImpl: DbgLoader {
    var title: String?
    var group: String?
    var comment: String?
    var actionBlock: (() -> Void)?
    var enableBlock: (() -> Bool)?
    var viewController: UIViewController.Type?
    
    func debug_title() -> String {
        return title ?? ""
    }
    
    func debug_action() {
        actionBlock?()
    }
    
    func debug_group() -> String? {
        return group
    }
    
    func debug_comment() -> String? {
        return comment
    }
    
    func debug_enable() -> Bool {
        return enableBlock?() ?? false
    }
    
    func debug_vc() -> UIViewController.Type? {
        return viewController
    }
}

class DbgSwitchLoaderImpl: DbgLoaderImpl, DbgSwitchLoader {
    
}

class DbgDetailLoaderImpl: DbgLoaderImpl, DbgDetailLoader {
    
}
