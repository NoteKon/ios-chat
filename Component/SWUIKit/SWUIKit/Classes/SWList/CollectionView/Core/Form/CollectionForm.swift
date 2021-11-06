//
//  SWCollectionForm.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/15.
//

import Foundation

public final class SWCollectionForm: SWForm<SWCollectionSection> {
    /// 定义何时隐藏内联行的默认选项，仅当“inlineRowHideOptions”为nil时才适用。
    public static var defaultInlineRowHideOptions = SWInlineRowHideOptions.Never
//    SWInlineRowHideOptions.FirstResponderChanges.union(.AnotherInlineRowIsShown)

    /// 定义何时隐藏内联行的选项。如果为空，则使用“defaultInlineRowHideOptions”
    public var inlineRowHideOptions: SWInlineRowHideOptions?
    
    /// 刷新
    public func reload() {
        guard let handler = delegate as? SWCollectionViewHandler else {
            return
        }
        handler.reloadCollection()
    }
}
