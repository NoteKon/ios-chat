//
//  FormCollectionDemo.swift
//  GZCList_Example
//
//  Created by Guo ZhongCheng on 2020/9/16.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SWUIKit

class DemoCollectionHeaderView: UICollectionReusableView {
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    let titleLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class FormCollectionDemo: SWFormCollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let multivalusedSection = SWCollectionMultivalusedSection(multivaluedOptions: [.Reorder, .Delete], header: "可展开item的Section", footer: "可展开item的Section结束", { (section) in
            section.header?.shouldSuspension = true
            section.contentInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        })
        for i in 0 ... 10 {
            multivalusedSection <<< CollectionInlineRootItem() { row in
                let value = DemoItem(imageUrl: ImageUrlsHelper.getNumberImage(i), title: "标题\(i+1)")
                row.value = value
                row.inlineRowOpenBlock = { r in
                    let value = DemoItem(imageUrl: "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1600428814333&di=913f844659946d7fb7d6ed1f1f67a72e&imgtype=0&src=http%3A%2F%2Fa1.att.hudong.com%2F05%2F00%2F01300000194285122188000535877.jpg", title: "打开的\(i)")
                    r.value = value
                }
                row.canMoveRow = true
            }
        }
        form +++ multivalusedSection
        
        let multivalusedSection2 = SWCollectionMultivalusedSection(multivaluedOptions: [.Reorder, .Delete], header: "长按可拖动的Section", footer: "长按可拖动的Section结束", { (section) in
            section.header?.shouldSuspension = true
        })
        for i in 0 ... 10 {
            multivalusedSection2 <<< DemoCollectionItem() { row in
                let value = DemoItem(imageUrl: ImageUrlsHelper.getNumberImage(i), title: "标题\(i+1)")
                row.value = value
                row.canMoveRow = true
            }
        }
        form +++ multivalusedSection2
        
        for j in 0 ... 10 {
            let section = SWCollectionSection() { sec in
                // 自定义header
                var headerProvider = SWCollectionHeaderFooterView<DemoCollectionHeaderView>.init { (view) in
                    view.title = "Header\(j)"
                    view.backgroundColor = .cyan
                }
                headerProvider.height = { 40 }
                headerProvider.shouldSuspension = j%2 == 0
                sec.header = headerProvider

                // 自定义footer
                var footerProvider = SWCollectionHeaderFooterView<DemoCollectionHeaderView>.init { (view) in
                    view.title = "Footer\(j)"
                    view.backgroundColor = .blue
                }
                footerProvider.height = { 40 }
                footerProvider.shouldSuspension = j%2 == 0
                sec.footer = footerProvider
                sec.column = j%3 * 10 + 1
            }
            
            for i in 0...15 {
                section <<< DemoCollectionItem() { row in
                    let value = DemoItem(imageUrl: "https://t8.baidu.com/it/u=2247852322,986532796&fm=79&app=86&size=h300&n=0&g=4n&f=jpeg?sec=1600831298&t=9b23a91ebe39109f56b5d708fd648ed6", title: "标题\(i)")
                    row.value = value
                }.onCellSelection {[weak self] (c, r) in
                    /// 闭包中，外部的所有section、row、self请务必加上weak，防止循环引用
                    guard
                        let newRows = self?.replaceRows(),
                        let section = r.section as? SWCollectionSection
                    else {
                        return
                    }
                    let rowIndex = r.indexPath!.row
                    section >>> (rowIndex ..< rowIndex + 1, newRows)
                }
            }
            form +++ section
            
        }
    }
    
    /// 插入的行
    func replaceRows() -> [SWCollectionItem] {
        var rows = [SWCollectionItem]()
        let random = arc4random() % 10 + 10
        for i in 0...random {
            rows.append(DemoCollectionItem() { row in
                let value = DemoItem(imageUrl: "https://t8.baidu.com/it/u=3571592872,3353494284&fm=79&app=86&size=h300&n=0&g=4n&f=jpeg?sec=1600843457&t=05dd81b261f02129496e491177693d20", title: "替换了\(i)")
                row.value = value
            }.onCellSelection {[weak self] (c, row) in
                guard
                    let newRows = self?.replaceRows(),
                    let section = row.section as? SWCollectionSection
                else {
                    return
                }
                let rowIndex = row.indexPath!.row
                if i == 10 {
                    section >>> newRows
                } else {
                    section >>> (rowIndex ..< rowIndex + 1, newRows)
                }
            })
        }
        return rows
    }

}
