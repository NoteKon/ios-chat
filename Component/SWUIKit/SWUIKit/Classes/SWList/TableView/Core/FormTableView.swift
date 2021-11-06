//
//  SWFormTableView.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/5.
//

import UIKit

open class SWFormTableView: UITableView, SWTableViewHandlerAnimationDelegate {
    
    // 处理tableview代理相关方法的类
    public lazy var handler: SWTableViewHandler = SWTableViewHandler()
    // handler代理, 包括cell的value改变回调以及scrollviewDelegate相关方法
    public weak var handerDelegate: SWTableViewHandlerDelegate? {
        didSet {
            handler.delegate = handerDelegate
        }
    }
    
    public var form: SWTableForm {
        return handler.form
    }
    
    // MARK:- 初始化方法
    public convenience init() {
        self.init(frame: .zero, style: .plain)
    }
    
    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        defaultSettings()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        defaultSettings()
    }
    
    func defaultSettings(){
        handler.tableView = self
        handler.animationDelegate = self
        cancelAdjustsScrollView()
    }
    
    /// 去除顶部留白
    public func cancelAdjustsScrollView() {
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
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
