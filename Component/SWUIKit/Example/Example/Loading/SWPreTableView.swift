//
//  SWPreTableView.swift
//  SWUIKit_Example
//
//  Created by ice on 2019/11/4.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

@objc protocol SWTableViewDataSource: NSObjectProtocol {
    @objc func swPreviewTableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    @objc func swPreviewTableView(tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    @objc func registerCell() -> UITableViewCell
    
    @objc optional func numberOfSectionsInSWPreviewTableView(tableView: UITableView) -> Int
}

class SWPreTableView: UITableView {
    public var preViewCellCount: Int = 10
    public var preViewCellColor: UIColor = UIColor.init(hex: 0x999999)
    public weak var swDataSource: SWTableViewDataSource?
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dataSource = self
    }
}

extension SWPreTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.swDataSource != nil && (self.swDataSource?.responds(to: #selector(SWTableViewDataSource.swPreviewTableView(tableView:numberOfRowsInSection:))))! {
            if self.swDataSource?.swPreviewTableView(tableView: tableView, numberOfRowsInSection: section) == 0 {
                return self.preViewCellCount
            }else {
                return (self.swDataSource?.swPreviewTableView(tableView: tableView, numberOfRowsInSection: section))!
            }
        }
        return self.preViewCellCount
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.swDataSource != nil && (self.swDataSource?.responds(to: #selector(SWTableViewDataSource.numberOfSectionsInSWPreviewTableView(tableView:))))! {
            return (self.swDataSource?.numberOfSectionsInSWPreviewTableView!(tableView: tableView))!
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.swDataSource != nil && (self.swDataSource?.responds(to: #selector(SWTableViewDataSource.swPreviewTableView(tableView:numberOfRowsInSection:))))! && (self.swDataSource?.swPreviewTableView(tableView: tableView, numberOfRowsInSection: indexPath.section) == 0) && (self.swDataSource?.responds(to: #selector(SWTableViewDataSource.registerCell)))! {
            let cell = self.swDataSource?.registerCell()
            cell?.selectionStyle = .none
            for s in (cell?.contentView.subviews)! {
                if s.isKind(of: UILabel.self){
                    (s as! UILabel).text = " "
                }
                s.backgroundColor = self.preViewCellColor
            }
            return cell!
            
        } else {
            if self.swDataSource != nil && (self.swDataSource?.responds(to: #selector(SWTableViewDataSource.swPreviewTableView(tableView:cellForRowAtIndexPath:))))! {
                let cell = self.swDataSource?.swPreviewTableView(tableView: tableView, cellForRowAtIndexPath: indexPath)
                for s in (cell?.contentView.subviews)! {
                    if s.backgroundColor == UIColor.init(red: 239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 1) {
                        s.backgroundColor = UIColor.white
                    }
                }
                return cell!
            }
        }
        return UITableViewCell.init()
    }
    
}
