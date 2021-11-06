//
//  InlineRowType.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/18.
//

import Foundation

// 定义内联行何时应折叠的选项
public struct SWInlineRowHideOptions: OptionSet {

    private enum _InlineRowHideOptions: Int {
        case never = 0, anotherInlineRowIsShown = 1, firstResponderChanges = 2
    }
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue}
    private init(_ options: _InlineRowHideOptions ) { self.rawValue = options.rawValue }

    /// 永远不要自动折叠（仅当用户点击内联行时才会收起）
    public static let Never = SWInlineRowHideOptions(.never)

    /// 当另一个内联行展开时自动折叠（一次只能展开一行）
    public static let AnotherInlineRowIsShown = SWInlineRowHideOptions(.anotherInlineRowIsShown)

    /// 失去焦点时自动折叠
    public static let FirstResponderChanges = SWInlineRowHideOptions(.firstResponderChanges)
}

// 内联Row协议基类
public protocol  SWBaseInlineRowType {
    /// 展开（打开）内联行
    func expandInlineRow()

    /// 折叠（关闭）内联行
    func collapseInlineRow()

    /// 更改内联行的状态（展开/折叠）
    func toggleInlineRow()
}
