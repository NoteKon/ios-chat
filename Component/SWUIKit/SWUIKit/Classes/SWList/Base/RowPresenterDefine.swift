//
//  SWRowPresenterDefine.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/9.
//

import Foundation
import UIKit

/**
 *  SWRow弹出的Controller的基础协议
 */
public protocol SWRowControllerType: NSObjectProtocol {

    /// Controller消失时回调的block
    var onDismissCallback: ((UIViewController) -> Void)? { get set }
}

/**
 定义应如何创建控制器的枚举

 - Callback -> VCType:    由block代码的返回值创建控制器
 - NibFile:                         由xib文件创建控制器
 - StoryBoard:                  由StoryBoard中的storyboard id创建控制器
 */
public enum SWControllerProvider<VCType: UIViewController> {

    /// 指定block中创建控制器
    case callback(builder: (() -> VCType))

    /// 指定xibName和Bundle
    case nibFile(name: String, bundle: Bundle?)

    /// 指定storyboardName、Bundle和其中的storyboard id
    case storyBoard(storyboardId: String, storyboardName: String, bundle: Bundle?)

    func makeController() -> VCType {
        switch self {
            case .callback(let builder):
                return builder()
            case .nibFile(let nibName, let bundle):
                return VCType.init(nibName: nibName, bundle:bundle ?? Bundle(for: VCType.self))
            case .storyBoard(let storyboardId, let storyboardName, let bundle):
                let sb = UIStoryboard(name: storyboardName, bundle: bundle ?? Bundle(for: VCType.self))
                return sb.instantiateViewController(withIdentifier: storyboardId) as! VCType
        }
    }
}

/**
 定义控制器如何显示

 - Show?:                     使用`show(_:sender:)`方法跳转（自动选择push和present）
 - PresentModally?:     使用Present方式跳转
 - SegueName?:          使用StoryBoard中的Segue identifier跳转
 - SegueClass?:           使用UIStoryboardSegue类跳转
 - popover?:                  使用popoverPresentationController方式展示
 */
public enum SWPresentationMode<VCType: UIViewController> {

    /// 根据指定的Provider创建控制器，并使用`show(_:sender:)`方法进行跳转
    case show(controllerProvider: SWControllerProvider<VCType>, onDismiss: ((UIViewController) -> Void)?)

    /// 根据指定的Provider创建控制器，并使用Present方式跳转
    case presentModally(controllerProvider: SWControllerProvider<VCType>, onDismiss: ((UIViewController) -> Void)?)

    /// 使用StoryBoard中的Segue identifier跳转
    case segueName(segueName: String, onDismiss: ((UIViewController) -> Void)?)

    /// 使用UIStoryboardSegue类执行跳转
    case segueClass(segueClass: UIStoryboardSegue.Type, onDismiss: ((UIViewController) -> Void)?)

    /// popoverPresentationController(小窗口)方式展示到tableView上
    case popover(controllerProvider: SWControllerProvider<VCType>, onDismiss: ((UIViewController) -> Void)?)

    public var onDismissCallback: ((UIViewController) -> Void)? {
        switch self {
            case .show(_, let completion):
                return completion
            case .presentModally(_, let completion):
                return completion
            case .segueName(_, let completion):
                return completion
            case .segueClass(_, let completion):
                return completion
            case .popover(_, let completion):
                return completion
        }
    }

    /**
     自定义Row的点击事件中调用此方法进行跳转
     
     - parameter viewController:           跳转目标控制器
     - parameter row:                      关联的Row
     - parameter presentingViewController: 跳转来源，通常当前控制器
     */
    public func present(_ viewController: VCType!, row: SWBaseRow, presentingController: UIViewController) {
        switch self {
            case .show(_, _):
                presentingController.show(viewController, sender: row)
            case .presentModally(_, _):
                presentingController.present(viewController, animated: true)
            case .segueName(let segueName, _):
                presentingController.performSegue(withIdentifier: segueName, sender: row)
            case .segueClass(let segueClass, _):
                let segue = segueClass.init(identifier: row.tag, source: presentingController, destination: viewController)
                presentingController.prepare(for: segue, sender: row)
                segue.perform()
            case .popover(_, _):
                guard viewController.popoverPresentationController != nil else {
                    fatalError()
                }
                presentingController.present(viewController, animated: true)
            }

    }

    /**
     自定义Row中获取控制器的方法，会根据当前枚举的值获取对应的控制器

     - returns: 创建好的控制器，或nil
     */
    public func makeController() -> VCType? {
        switch self {
            case .show(let controllerProvider, let completionCallback):
                let controller = controllerProvider.makeController()
                let completionController = controller as? SWRowControllerType
                if let callback = completionCallback {
                    completionController?.onDismissCallback = callback
                }
                return controller
            case .presentModally(let controllerProvider, let completionCallback):
                let controller = controllerProvider.makeController()
                let completionController = controller as? SWRowControllerType
                if let callback = completionCallback {
                    completionController?.onDismissCallback = callback
                }
                return controller
            case .popover(let controllerProvider, let completionCallback):
                let controller = controllerProvider.makeController()
                controller.modalPresentationStyle = .popover
                let completionController = controller as? SWRowControllerType
                if let callback = completionCallback {
                    completionController?.onDismissCallback = callback
                }
                return controller
            default:
                return nil
        }
    }
}
