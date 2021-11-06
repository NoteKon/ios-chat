//
//  SWFormTableViewController.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/6/2.
//

import UIKit

open class SWFormTableViewController: UIViewController, SWTableViewHandlerAnimationDelegate {
    // tableView
    @IBOutlet public var tableView: UITableView!
    // tableView的样式，在didLoad之前设置
    private var tableViewStyle: UITableView.Style = .plain
    
    
    // tableView代理处理类
    public var handler: SWTableViewHandler = SWTableViewHandler()
    // handler代理, 包括cell的value改变回调以及scrollviewDelegate相关方法
    public weak var handerDelegate: SWTableViewHandlerDelegate? {
        didSet {
            handler.delegate = handerDelegate
        }
    }
    
    public var form: SWTableForm {
        return handler.form
    }
    
    public init(style: UITableView.Style) {
        super.init(nibName: nil, bundle: nil)
        tableViewStyle = style
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        if tableView == nil {
            tableView = UITableView(frame: view.bounds, style: tableViewStyle)
            tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            tableView.cellLayoutMarginsFollowReadableWidth = false
        }
        if tableView.superview == nil {
            view.addSubview(tableView)
        }
        handler.tableView = self.tableView
        handler.animationDelegate = self
        cancelAdjustsScrollView()
    }
    
    /// 去除顶部留白
    public func cancelAdjustsScrollView() {
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    // MARK:- SWTableViewHandlerAnimationDelegate
    open func insertAnimation(forRows rows: [SWTableRow]) -> UITableView.RowAnimation {
       .automatic
    }

    open func deleteAnimation(forRows rows: [SWTableRow]) -> UITableView.RowAnimation {
       .automatic
    }

    open func reloadAnimation(oldRows: [SWTableRow], newRows: [SWTableRow]) -> UITableView.RowAnimation {
       .automatic
    }

    open func insertAnimation(forSections sections: [SWTableSection]) -> UITableView.RowAnimation {
       .automatic
    }

    open func deleteAnimation(forSections sections: [SWTableSection]) -> UITableView.RowAnimation {
       .automatic
    }

    open func reloadAnimation(oldSections: [SWTableSection], newSections: [SWTableSection]) -> UITableView.RowAnimation {
       .automatic
    }
}
