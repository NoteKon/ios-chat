//
//  TableExtension.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/7.
//

import UIKit

extension UIView {

    public func formCell() -> SWTableCell? {
        if self is UITableViewCell {
            return self as? SWTableCell
        }
        return superview?.formCell()
    }
    
}
