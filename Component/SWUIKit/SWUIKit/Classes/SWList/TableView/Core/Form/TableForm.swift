//
//  SWTableForm.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/3.
//

import Foundation

public final class SWTableForm: SWForm<SWTableSection> {
    /// 定义何时隐藏内联行的默认选项，仅当“inlineRowHideOptions”为nil时才适用。
    public static var defaultInlineRowHideOptions = SWInlineRowHideOptions.FirstResponderChanges.union(.AnotherInlineRowIsShown)

    /// 定义何时隐藏内联行的选项。如果为空，则使用“defaultInlineRowHideOptions”
    public var inlineRowHideOptions: SWInlineRowHideOptions?
    
    /// 刷新
    public func reload() {
        guard let handler = delegate as? SWTableViewHandler else {
            return
        }
        handler.tableView?.reloadData()
    }
}
