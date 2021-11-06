//
//  ItemPresentViewController.swift
//  GZCList_Example
//
//  Created by Guo ZhongCheng on 2020/9/23.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SWUIKit

class ItemPresentViewController<Row: SWTypedCollectionItemType>: UIViewController, SWTypedItemControllerType {
    
    var row: SWCollectionBaseItemOf<Row.Cell.Value>! {
        didSet {
            valueLabel.text = row.value as? String
        }
    }
    
    var onDismissCallback: ((UIViewController) -> Void)?
    
    let valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("返回", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(valueLabel)
        view.addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        valueLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(backButton.snp.top).offset(-10)
        }
    }
    
    @objc func backAction() {
        onDismissCallback?(self)
    }
}
