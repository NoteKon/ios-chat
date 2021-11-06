//
//  SWPopMenuView.swift
//  VVPartner
//
//  Created by julian on 2019/11/26.
//  Copyright © 2019 vv. All rights reserved.
//

import UIKit

public class SWPopMenuView: UIView {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var contentView: SWPopMenuView!
    @IBOutlet weak var wrapperView: UIView!
    
    /// 修改小三角右侧距父视图的距离
    @IBOutlet weak var triangleTrailingConstraint: NSLayoutConstraint!
    /// 修改弹窗menuview头部侧距父视图的距离
    @IBOutlet weak var wrapperViewAlignTopConstraint: UIView!
    /// 修改弹窗menuview右侧距父视图的距离
    @IBOutlet weak var wrapperViewAlignTrailingConstraint: NSLayoutConstraint!
    /// 弹窗最大高度
    @IBOutlet weak var maxWrapperViewHeight: NSLayoutConstraint!
    /// 弹窗宽度
    @IBOutlet weak var wrapperViewWidthConstraint: NSLayoutConstraint!
    /// 行高
    public var rowHeight: CGFloat = 48
    /// 文字字体
    public var font: UIFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    /// 文字颜色
    public var textColor: UIColor = UIColor(hex: 0x333333)
    /// 图标大小
    public var iconSize: CGSize = CGSize(width: 18, height: 18)
    /// 弹窗圆角
    public var wrapperViewCornerRadius: CGFloat = 8
    /// 弹窗宽度
    public var wrapperViewWidth: CGFloat = 144
    
    /// 控制器切换回调
    public typealias PageBlock = (_ selectedIndex: Int) -> Void
    public var pageBlock: PageBlock?
    
    /// 数据源
    public var dataArray: [SWPopupMenuModel] = []
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
    }
    
    func initViews() {
        let bundle = Bundle.resourceBundle(bundleName: "SWUIKit", targetClass: SWPopMenuView.self)
        loadNibNamed("SWPopMenuView", owner: self, options: nil)
        self.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        self.maxWrapperViewHeight.constant = CGFloat.greatestFiniteMagnitude
        
        tableView.register(UINib(nibName: "SWPopMenuCell", bundle: bundle),
                           forCellReuseIdentifier: SWPopMenuCell.kReuseIdentifier)
        
        self.alpha = 0
    }
    
    public func show(_ menus: [SWPopupMenuModel]?) {
        if let window = UIApplication.shared.delegate?.window! {
            window.addSubview(self)
            self.frame = window.bounds
            wrapperViewWidthConstraint.constant = wrapperViewWidth
            self.tableView.layer.cornerRadius = self.wrapperViewCornerRadius
            
            if let menus = menus {
                self.dataArray = menus
                self.tableView.reloadData()
                self.alpha = 1
                self.maxWrapperViewHeight.constant = min(CGFloat(menus.count * Int(self.rowHeight) + 6), 198)
            }
        }
    }
    
    public func hide() {
        self.alpha = 0
        self.removeFromSuperview()
    }
}

extension SWPopMenuView: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SWPopMenuCell.kReuseIdentifier, for: indexPath) as! SWPopMenuCell
        
        if indexPath.row < dataArray.count {
            
            cell.titleLabel.font = font
            cell.titleLabel.textColor = textColor
            cell.iconImageViewWidthConstraint.constant = iconSize.width
            cell.iconImageViewHeightConstraint.constant = iconSize.height
            
            cell.model = dataArray[indexPath.row]
            
            if indexPath.row < dataArray.count - 1 && dataArray.count > 1 {
                cell.seprateLine.isHidden = false
            } else {
                cell.seprateLine.isHidden = true
            }
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < dataArray.count, let pageBlock = pageBlock {
            pageBlock(indexPath.row)
        }
        
        hide()
    }
}

extension SWPopMenuView {
    @IBAction func viewTaped(_ sender: Any) {
        hide()
    }
}
