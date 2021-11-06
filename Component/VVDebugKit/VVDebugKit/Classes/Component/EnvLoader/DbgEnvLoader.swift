//
//  DbgEnvLoader.swift
//  Alamofire
//
//  Created by huang on 2019/9/3.
//

import Foundation
import SWBusinessKit
import SWUIKit

public protocol DbgEnvChangedEvent {
    func dbgEnvWillChanged(from: Environment, to: Environment)
}

class DbgEnvLoader: DbgLoader {    
    func debug_title() -> String {
        return "Choose Env..."
    }
    
    func debug_action() {
        let env = EnvironmentManager.default.env
        let title = "Current: \(env)"
        let options = Environment.allCases.map { (env) -> String in
            let urlString = EnvironmentManager.default.get(.vdc_vv_com_sg, env: env)
            let url = URL(string: urlString)
            let host = url?.host ?? ""
            if let port = url?.port {
                return "\(env) (\(host):\(port))"
            } else {
                return "\(env) (\(host))"
            }
        }
        SWAlert.showActionSheet(title: title, message: "Restart is required after env changed.", cancel: "Cancel", others: options, using: VVDebugKit.default.currentViewController) { (index) in
            guard index >= 0 else { return }
            let desc = String(options[index].split(separator: " ").first ?? "")
            if let newEnv = Environment(desc: desc) {
                //SWToast.shared.makeToastActivity(VVDebugKit.default.rootWindow)
                print("TODO: FIX")
                if let proto = VVDebugKit.default as? DbgEnvChangedEvent {
                    proto.dbgEnvWillChanged(from: EnvironmentManager.default.env, to: newEnv)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    EnvironmentManager.default.env = newEnv
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        exitApplication()
                    }
                }
            }
        }
    }
    
    func debug_group() -> String? {
        return "common"
    }
    
    func debug_comment() -> String? {
        let env = EnvironmentManager.default.env
        return "Current: \(env)\n"
    }
}

private func exitApplication() {
    SWKeyChain.deleteValue(key: "com.vv.life")
    SWNetWorking.authorization = nil
    SWNetWorking.userCode = nil
    
    let window = UIApplication.shared.delegate!.window!!
    UIView.animate(withDuration: 0.5, animations: {
        window.alpha = 0
        window.frame = CGRect(x: window.bounds.size.width/2, y: window.bounds.size.height/2, width: 0, height: 0)
    }) { (finished) in
        exit(0)
    }
}
