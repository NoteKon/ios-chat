//
//  SWActionSheetViewController.swift
//  Alamofire
//
//  Created by jack on 2020/11/26.
//

import UIKit
import SWFoundationKit

/// 选择器模型
public struct SWActionSheetModel {
    /// 名称
    public var name: String?
    /// 字体
    public var font: UIFont?
    /// 颜色
    public var color: UIColor?
    /// 高度
    public var height: CGFloat = 49.0
    
    public init(name: String? = nil, font: UIFont? = .systemFont(ofSize: 16.0), color: UIColor? = .gray, height: CGFloat? = 49) {
        self.name = name
        self.font = font
        self.color = color
        self.height = height ?? 49.0
    }
}

open class SWActionSheetController: UIViewController {
    
    private var tableView: UITableView!
    
    private var handel: ((_ index: Int) -> Void)?
    private let cellIdentifier = "sheetCellIdentifier"
    private var spaceHeight: CGFloat = 8.0
    private var bottomSafeHeight: CGFloat = 34.0
    private var contentView: UIView!
    
    private var dataAry = [SWActionSheetModel]()
    private var titleModel: SWActionSheetModel?
    private var cancelModel: SWActionSheetModel?
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showTableView()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    // MARK: UI
    
    private func setupUI() {
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.6)
        let buttton = UIButton(type: .custom)
        buttton.frame = view.bounds
        buttton.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        buttton.addTarget(self, action: #selector(dismissViewController(_:)), for: .touchUpInside)
        view.addSubview(buttton)
        
        // 计算高度
        var cellHeight: CGFloat = dataAry.reduce(0) { (sum, model) -> CGFloat in
            var total = sum
            total += model.height
            return total
        }
        var totalHeight: CGFloat = (titleModel?.height ?? 0.0) + cellHeight + (cancelModel?.height ?? 0.0)
        totalHeight += spaceHeight + SAFEAREA_BOTTOM_HEIGHT
        var canScroll = false
        let height = totalHeight - SCREEN_HEIGHT * 0.7
        if height > 0 {
            cellHeight -= height
            totalHeight = SCREEN_HEIGHT * 0.7
            canScroll = true
        }
        
        // 内容view
        let infoView = UIView(frame: CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: totalHeight))
        infoView.backgroundColor = .white
        addCorners(byRoundingCorners: [.topLeft, .topRight], radii: 16, view: infoView)
        
        self.view.addSubview(infoView)
        contentView = infoView
        
        // 标题
        if let title = titleModel {
            let titleView = UIView()
            titleView.frame = CGRect(x: 0, y: 0, width: infoView.width, height: title.height)
            infoView.addSubview(titleView)
            
            //文本
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: titleView.width, height: title.height))
            titleLabel.text = title.name
            titleLabel.textAlignment = .center
            titleLabel.font = title.font
            titleLabel.textColor = title.color
            titleView.addSubview(titleLabel)
            
            //分隔线
            let line = UIView(frame: CGRect(x: 0, y: title.height - 1, width: titleView.width, height: 1))
            line.backgroundColor = UIColor(hex: 0xF2F2F2)
            titleView.addSubview(line)
            
        }
        
        // 单元格
        if dataAry.count > 0 {
            tableView = UITableView(frame: CGRect(x: 0, y: titleModel?.height ?? 0, width: infoView.width, height: cellHeight))
            
            tableView.isScrollEnabled = canScroll
            tableView.dataSource = self
            tableView.delegate = self
            
            if #available(iOS 11.0, *) {
                tableView.contentInsetAdjustmentBehavior = .never
            } else {
                automaticallyAdjustsScrollViewInsets = false
            }
            tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            tableView.separatorColor = UIColor(hex: 0xF2F2F2)
            tableView.reloadData()
            infoView.addSubview(tableView)
        }
        
        // 底部取消
        let bottomView = UIView()
        bottomView.frame = CGRect(x: 0, y: tableView.frame.maxY, width: infoView.width, height: CGFloat(cancelModel?.height ?? 0) + spaceHeight + SAFEAREA_BOTTOM_HEIGHT)
        infoView.addSubview(bottomView)
        //隔离线
        if spaceHeight > 0 {
            let line = UIView(frame: CGRect(x: 0, y: 0, width: bottomView.width, height: spaceHeight))
            line.backgroundColor = UIColor(hex: 0xFAFAFA)
            bottomView.addSubview(line)
        }
        
        //取消按钮
        if let model = cancelModel {
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: 0, y: spaceHeight, width: bottomView.width, height: model.height)
            button.setTitle(model.name, for: .normal)
            button.setTitleColor(model.color, for: .normal)
            button.titleLabel?.font = model.font
            button.addTarget(self, action: #selector(dismissViewController(_:)), for: .touchUpInside)
            bottomView.addSubview(button)
        }
        
    }
    
    private func showTableView() {
        var rect = contentView.frame
        rect.origin.y = self.view.frame.height - rect.height
        UIView.animate(withDuration: 0.25) {
            self.contentView.frame = rect
        }
    }
    
    @objc private func dismissViewController(_ sender: Any) {
        var rect = contentView.frame
        rect.origin.y = self.view.frame.height
        UIView.animate(withDuration: 0.25, animations: {
            self.contentView.frame = rect
        }) { (finish) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func addCorners(byRoundingCorners corners: UIRectCorner, frame: CGRect? = nil, radii: CGFloat, view: UIView) {
        let cornnerFrame = frame ?? view.bounds
        let maskPath = UIBezierPath(roundedRect: cornnerFrame, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = cornnerFrame
        maskLayer.path = maskPath.cgPath
        
        view.layer.mask = maskLayer
    }
        
    // MARK: 调用方法显示
    
    static public func showTitle(titleString: String? = nil, titleColor: UIColor? = nil, confirm: String? = nil, confirmColor: UIColor? = nil, cancel: String? = nil, cancelColor: UIColor? = nil, superVC: UIViewController? = nil, clickBlock: ((_ index: Int) -> Void)?) {
        
        let vc = SWActionSheetController()
        if let titleString = titleString {
            var titleModel = SWActionSheetModel()
            titleModel.name = titleString
            titleModel.color = UIColor(hex: 0x999999)
            vc.titleModel = titleModel
        }
        if let titleColor = titleColor {
            vc.titleModel?.color = titleColor
        }
        if let confirm = confirm {
            var model = SWActionSheetModel()
            model.name = confirm
            model.color = UIColor(hex: 0xF43530)
            vc.dataAry.append(model)
        }
        if let confirmColor = confirmColor {
            if vc.dataAry.count > 0, var model = vc.dataAry.first {
                model.color = confirmColor
                vc.dataAry[0] = model
            }
            
        }
        if let cancel = cancel {
            var cancelModel = SWActionSheetModel()
            cancelModel.name = cancel
            cancelModel.color = UIColor(hex: 0x333333)
            vc.cancelModel = cancelModel
        } else {
            vc.spaceHeight = 0
        }
        if let cancelColor = cancelColor {
            vc.cancelModel?.color = cancelColor
        }
        vc.handel = clickBlock
        
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        if let superVC = superVC {
            superVC.present(vc, animated: true, completion: nil)
        } else {
            SWRouter.present(vc, animated: true)
        }
    }
    
    static public func showActionSheet(title: SWActionSheetModel? = nil, contentAry: [SWActionSheetModel]? = nil, cancel: SWActionSheetModel? = nil, superVC: UIViewController? = nil, clickBlock: ((_ index: Int) -> Void)?) {
        let vc = SWActionSheetController()
        vc.titleModel = title
        vc.cancelModel = cancel
        if cancel == nil {
            vc.spaceHeight = 0
        }
        if let list = contentAry {
            vc.dataAry.append(contentsOf: list)
        }
        vc.handel = clickBlock
        
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        if let superVC = superVC {
            superVC.present(vc, animated: true, completion: nil)
        } else {
            SWRouter.present(vc, animated: true)
        }
        
    }
    
}

extension SWActionSheetController: UITableViewDataSource, UITableViewDelegate {
    // MARK: UITableViewDataSource, UITableViewDelegate
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataAry.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        let model = dataAry[indexPath.row]
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
            cell?.textLabel?.textAlignment = .center
        }
        cell?.textLabel?.textColor = model.color
        cell?.textLabel?.font = model.font
        cell?.textLabel?.text = model.name
        
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true) { [weak self] in
            self?.handel?(indexPath.row)
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataAry[indexPath.row].height
    }
    
}
