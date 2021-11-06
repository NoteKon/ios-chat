//
//  String+UrlParse.swift
//  VVLife
//
//  Created by vv on 2019/9/18.
//  Copyright © 2019 vv. All rights reserved.
//

import Foundation

public extension String {
    
    func parseURLParams() -> [String: String] {
        var params = [String: String]()
        let pairs = self.components(separatedBy: "&")
        for pair in pairs {
            let comps = pair.components(separatedBy: "=")
            if comps.count == 2 {
                params[comps[0]] = comps[1].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            }
        }
        
        return params
    }
    
}
