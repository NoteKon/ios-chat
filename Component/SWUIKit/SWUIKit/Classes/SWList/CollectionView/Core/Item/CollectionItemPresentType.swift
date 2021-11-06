//
//  CollectionPresentType.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/23.
//

import Foundation

/**
 *  SWTableRow弹出控制器的关联协议
 */
public protocol SWTypedItemControllerType: SWRowControllerType {
    associatedtype RowValue: Equatable

    /// 弹出这个控制器的Row
    var row:  SWCollectionBaseItemOf<Self.RowValue>! { get set }
}


/**
 *  弹出控制器的Row遵守的协议
 */
public protocol  SWTypedPresenterControllerItemType:  SWTypedCollectionItemType {

    associatedtype PresentedControllerType : UIViewController, SWTypedItemControllerType

    /// 定义视图控制器的弹出方式
    var presentationMode: SWPresentationMode<PresentedControllerType>? { get set }

    /// 跳转完成的回调Block
    var onPresentCallback: ((UIViewController, PresentedControllerType) -> Void)? { get set }
}

extension  SWTypedPresenterControllerItemType {
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
