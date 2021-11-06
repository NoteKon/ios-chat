//
//  ViewController.swift
//  SWUIKit
//
//  Created by ice on 2019/8/8.
//  Copyright © 2019 vv. All rights reserved.
//

import UIKit
import SWUIKit

class ViewController: SWFormTableViewController {
    
    var addedFPS: Bool = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /// 添加帧数监听
        if !addedFPS, let window = UIApplication.shared.keyWindow {
            let fpsLabel = FPSLabel(frame: CGRect(x: view.frame.width - 150, y: 40, width: 100, height: 40))
            fpsLabel.textColor = .green
            fpsLabel.textAlignment = .center
            fpsLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            window.addSubview(fpsLabel)
            addedFPS = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .singleLine
        
        form +++ SWTableSection()
            <<< pushXibRow(title: "Toast", xibName: "ToastViewController")
            <<< pushXibRow(title: "输入框", xibName: "TextInputVC")
            <<< pushXibRow(title: "无网络页", xibName: "NetErrorViewController")
            <<< pushXibRow(title: "PageViewController", xibName: "PageViewController")
            <<< ButtonRow("WebViewController"){ row in
                row.cellHeight = 50
            }.onCellSelection({[weak self] (cell, row) in
                let controller = SWUIWebViewController()
                controller.url = "https://www.baidu.com"
                self?.navigationController?.pushViewController(controller, animated: true)
            })
            <<< pushXibRow(title: "下拉刷新", xibName: "SWRefreshViewController")
            <<< ButtonRow("SWControlAlert"){ row in
                row.cellHeight = 50
            }.onCellSelection({ (cell, row) in
                let vc = SWControlAlert.show(title: "SWControlAlert", message: "content", cancel: "Cancel", others: ["Confirm", "test"]) { (index) -> Bool in
                    print("index: \(index)")
                    return true
                }
                vc.clickBackgroundToDismiss = true
            })
            <<< ButtonRow("actionSheet"){ row in
                row.cellHeight = 50
            }.onCellSelection({ (cell, row) in
                let title = SWActionSheetModel(name: "标题", font: UIFont.systemFont(ofSize: 16), color: UIColor.red, height: 49.0)
                let cancelAction = SWActionSheetModel(name: "取消", font: .pingFangRegular(size: 16.0), color: UIColor.gray)
                let backAction = SWActionSheetModel(name: "返回", font: .pingFangRegular(size: 16.0), color: UIColor(rgb: 0x333333))
                let quitAction = SWActionSheetModel(name: "继续", font: .pingFangRegular(size: 16.0), color: UIColor(rgb: 0xF43530))

                SWActionSheetController.showActionSheet(title: title, contentAry: [backAction, quitAction], cancel: cancelAction, superVC: self) { (index) in
                    print("index: \(index)")
                }
            })
            <<< ButtonRow("appUpdate"){ row in
                row.cellHeight = 50
            }.onCellSelection({ (cell, row) in
                let message = "发现新版本 v1.13.4 (983) 可用\n[发现]通讯接入，"
                SWControlAlert.show(title: "更新提示", message: message, cancel: "我知道了", others: ["立即更新"], textAlignment: .left, preferredAction: -1, animated: true, style: .appUpdate) { (index) -> Bool in
                    print("index: \(index)")
                    return true
                }
            })
            <<< pushVCRow(title: "图形验证码", vc: GraphicCodeViewController())
            <<< pushVCRow(title: "SWList -> TableView", vc: FormTableDemo())
            <<< pushVCRow(title: "SWList -> CollectionView", vc: CollectionDemoListViewController())
            <<< pushXibRow(title: "storyboard创建的Row/Item", xibName: "DemoStoryboardVC")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func pushXibRow(title: String, xibName: String) -> ButtonRow {
        return ButtonRow(title){ row in
            row.cellHeight = 50
        }.onCellSelection {[weak self] (cell, row) in
            if let controller = self?.storyboard?.instantiateViewController(withIdentifier: xibName) {
                self?.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    func pushVCRow<T: UIViewController>(title: String, vc: T) -> ButtonRow {
        return ButtonRow(title){ row in
            row.cellHeight = 50
        }.onCellSelection {[weak self] (cell, row) in
            self?.navigationController?.pushViewController(T(), animated: true)
        }
    }
}
