//
//  SWTableRowPresenter.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/9.
//

import Foundation

/**
 *  SWTableRow弹出控制器的关联协议
 */
public protocol  SWTypedRowControllerType: SWRowControllerType {
    associatedtype RowValue: Equatable

    /// 弹出这个控制器的Row
    var row: SWTableBaseRowOf<Self.RowValue>! { get set }
}


/**
 *  弹出控制器的Row遵守的协议
 */
public protocol  SWTypedPresenterControllerRowType: SWTypedTableRowType {

    associatedtype PresentedControllerType : UIViewController,  SWTypedRowControllerType

    /// 定义视图控制器的弹出方式
    var presentationMode: SWPresentationMode<PresentedControllerType>? { get set }

    /// 跳转完成的回调Block
    var onPresentCallback: ((UIViewController, PresentedControllerType) -> Void)? { get set }
}

extension  SWTypedPresenterControllerRowType {
    /**
     设置跳转完成的回调
     
     - parameter callback: 回调Block
     
     - returns: 当前Row
     */
    @discardableResult
    public func onPresent(_ callback: ((UIViewController, PresentedControllerType) -> Void)?) -> Self {
        onPresentCallback = callback
        return self
    }
}
