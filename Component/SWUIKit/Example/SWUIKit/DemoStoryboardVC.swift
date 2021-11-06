//
//  DemoStoryboardVC.swift
//  SWUIKit_Example
//
//  Created by Guo ZhongCheng on 2021/4/12.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SWUIKit

class DemoStoryboardVC: UIViewController {
    @IBOutlet weak var tableView: SWFormTableView!
    
    @IBOutlet weak var collectionView: SWFormCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableSection = SWTableSection("StoryBoard创建的Row")
        for i in 0 ..< 100 {
            tableSection <<< DemoStoryboardRow("测试\(i)下")
        }
        tableView.form +++ tableSection
        
//        collectionView.arrangement = .flow
        let collectionSection = SWCollectionSection("StoryBoard创建的Item") { section in
            section.column = 2
            section.lineSpace = 10
            section.itemSpace = 10
            section.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
        for i in 0 ..< 100 {
            collectionSection <<< DemoStoryboardItem(
                title: ImageUrlsHelper.getNumberImage(i),
                value: i
            )
        }
        collectionView.form +++ collectionSection
    }
}
