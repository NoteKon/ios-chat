//
//  SWTableSectionHeaderFooterView.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/7.
//

import Foundation
import UIKit

/**
 *  tableView的header和footer需要实现的协议
 *  header和footer可以设置为String或View
 */
public protocol TableHeaderFooterViewRepresentable {

    /**
     调用此方法来获取指定section的header或footer相对应的view
     
     - parameter section:    要获取view的section
     - parameter type:       类型（header或footer）
     
     - returns: 对应的view
     */
    func viewForSection(_ section: SWTableSection, type: HeaderFooterType) -> UIView?

    /// 如果Section的Header或Footer是用字符串创建的，则它将存储在title中，需要在viewForSection中实现具体展示
    var title: String? { get set }

    /// 高度
    var height: (() -> CGFloat)? { get set }
}

/**
 *  用于字符串生成header或footer
 */
public struct TableHeaderFooterView<ViewType: UIView> : ExpressibleByStringLiteral, TableHeaderFooterViewRepresentable {

    /// 标题
    public var title: String?
    /// view的生成器
    public var viewProvider: HeaderFooterProvider<ViewType>?
    /// view创建完成的回调
    public var onSetupView: ((_ view: ViewType, _ section: SWTableSection) -> Void)?
    /// view的高度
    public var height: (() -> CGFloat)?

    /**
     调用此方法来获取section中的headerView或footerView
     
     - parameter section:    目标section
     - parameter type:       header 或 footer.
     
     - returns: view
     */
    public func viewForSection(_ section: SWTableSection, type: HeaderFooterType) -> UIView? {
        var view: ViewType?
        if type == .header {
            view = section.headerView as? ViewType ?? {
                            let result = viewProvider?.createView()
                            section.headerView = result
                            return result
                        }()
        } else {
            view = section.footerView as? ViewType ?? {
                            let result = viewProvider?.createView()
                            section.footerView = result
                            return result
                        }()
        }
        guard let v = view else { return nil }
        onSetupView?(v, section)
        return v
    }

    /**
     用title字符串初始化
     */
    public init?(title: String?) {
        guard let t = title else { return nil }
        self.init(stringLiteral: t)
    }

    /**
     使用枚举类型初始化，适用于自定义的header/footer
     */
    public init(_ provider: HeaderFooterProvider<ViewType>) {
        viewProvider = provider
    }

    /**
     字面量初始化
     */
    public init(unicodeScalarLiteral value: String) {
        self.title  = value
    }

    /**
     字面量初始化
     */
    public init(extendedGraphemeClusterLiteral value: String) {
        self.title = value
    }

    /**
     字面量初始化
     */
    public init(stringLiteral value: String) {
        self.title = value
    }
}
