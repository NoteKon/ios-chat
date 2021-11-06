//
//  SWTableRowSwipeActions.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/7.
//

import Foundation
import UIKit

public typealias SWSwipeActionHandler = (SWSwipeAction, SWTableRow, ((Bool) -> Void)?) -> Void

public class SWSwipeAction: SWContextualAction {
    let handler: SWSwipeActionHandler
    let style: Style

    public var actionBackgroundColor: UIColor?
    public var image: UIImage?
    public var title: String?

    @available (*, deprecated, message: "Use actionBackgroundColor instead")
    public var backgroundColor: UIColor? {
        get { return actionBackgroundColor }
        set { self.actionBackgroundColor = newValue }
    }

    public init(style: Style, title: String?, handler: @escaping SWSwipeActionHandler){
        self.style = style
        self.title = title
        self.handler = handler
    }

    func contextualAction(forRow: SWTableRow) -> SWContextualAction {
        var action: SWContextualAction
        if #available(iOS 11, *){
            action = UIContextualAction(style: style.contextualStyle as! UIContextualAction.Style, title: title){ [weak self] action, view, completion -> Void in
                guard let strongSelf = self else{ return }
                strongSelf.handler(strongSelf, forRow) { shouldComplete in
                    if #available(iOS 13, *) { // starting in iOS 13, completion handler is not removing the row automatically, so we need to remove it ourselves
                        if shouldComplete && action.style == .destructive {
                            guard let section = forRow.section as? SWTableSection else {
                                return
                            }
                            section.remove(row: forRow)
                        }
                    }
                    completion(shouldComplete)
                }
            }
        } else {
            action = UITableViewRowAction(style: style.contextualStyle as! UITableViewRowAction.Style,title: title){ [weak self] (action, indexPath) -> Void in
                guard let strongSelf = self else{ return }
                strongSelf.handler(strongSelf, forRow) { _ in
                    DispatchQueue.main.async {
                        guard action.style == .destructive else {
                            forRow._cell?.tableHandler()?.tableView?.setEditing(false, animated: true)
                            return
                        }
                        guard let section = forRow.section as? SWTableSection else {
                            return
                        }
                        section.remove(row: forRow)
                    }
                }
            }
        }
        if let color = self.actionBackgroundColor {
            action.actionBackgroundColor = color
        }
        if let image = self.image {
            action.image = image
        }
        return action
    }
    
    public enum Style {
        case normal
        case destructive
        
        var contextualStyle: SWContextualStyle {
            if #available(iOS 11, *){
                switch self{
                case .normal:
                    return UIContextualAction.Style.normal
                case .destructive:
                    return UIContextualAction.Style.destructive
                }
            } else {
                switch self{
                case .normal:
                    return UITableViewRowAction.Style.normal
                case .destructive:
                    return UITableViewRowAction.Style.destructive
                }
            }
        }
    }
}

public struct SWSwipeConfiguration {
    
    unowned var row: SWTableRow
    
    init(_ row: SWTableRow){
        self.row = row
    }
    
    public var performsFirstActionWithFullSwipe = false
    public var actions: [SWSwipeAction] = []
}

extension SWSwipeConfiguration {
    @available(iOS 11.0, *)
    var contextualConfiguration: UISwipeActionsConfiguration? {
        let contextualConfiguration = UISwipeActionsConfiguration(actions: self.contextualActions as! [UIContextualAction])
        contextualConfiguration.performsFirstActionWithFullSwipe = self.performsFirstActionWithFullSwipe
        return contextualConfiguration
    }

    var contextualActions: [SWContextualAction]{
        return self.actions.map { $0.contextualAction(forRow: self.row) }
    }
}

protocol SWContextualAction {
    var actionBackgroundColor: UIColor? { get set }
    var image: UIImage? { get set }
    var title: String? { get set }
}

extension UITableViewRowAction: SWContextualAction {
    public var image: UIImage? {
        get { return nil }
        set { return }
    }

    public var actionBackgroundColor: UIColor? {
        get { return backgroundColor }
        set { self.backgroundColor = newValue }
    }
}

@available(iOS 11.0, *)
extension UIContextualAction: SWContextualAction {

    public var actionBackgroundColor: UIColor? {
        get { return backgroundColor }
        set { self.backgroundColor = newValue }
    }

}

public protocol SWContextualStyle{}
extension UITableViewRowAction.Style: SWContextualStyle {}

@available(iOS 11.0, *)
extension UIContextualAction.Style: SWContextualStyle {}
