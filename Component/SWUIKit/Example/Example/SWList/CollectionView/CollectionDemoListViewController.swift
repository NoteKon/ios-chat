//
//  CollectionDemoListViewController.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 06/01/2020.
//  Copyright (c) 2020 Guo ZhongCheng. All rights reserved.
//

import SWUIKit

class CollectionDemoListViewController: SWFormTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "CollectionView"
        
        form +++ SWTableSection("竖直方向")
            <<< ButtonRow("瀑布流") { row in
                row.presentationMode = .show(controllerProvider: .callback(builder: { () -> UIViewController in
                    let vc = FormCollectionDemo()
                    vc.modalPresentationStyle = .fullScreen
                    vc.hidesBottomBarWhenPushed = true
                    vc.title = "瀑布流"
                    vc.arrangement = .flow
                    vc.lineSpace = 0
                    return vc
                }), onDismiss: { (vc) in
                    vc.dismiss(animated: true)
                })
            }
            <<< ButtonRow("系统样式") { row in
                row.presentationMode = .show(controllerProvider: .callback(builder: { () -> UIViewController in
                    let vc = FormCollectionDemo()
                    vc.modalPresentationStyle = .fullScreen
                    vc.hidesBottomBarWhenPushed = true
                    vc.title = "系统样式"
                    vc.arrangement = .system
                    return vc
                }), onDismiss: { (vc) in
                    vc.dismiss(animated: true)
                })
            }
            <<< ButtonRow("固定行高自动换行") { row in
                row.presentationMode = .show(controllerProvider: .callback(builder: { () -> UIViewController in
                    let vc = FormCollectionDemo()
                    vc.modalPresentationStyle = .fullScreen
                    vc.hidesBottomBarWhenPushed = true
                    vc.title = "自动换行"
                    vc.lineHeight = 50
                    vc.arrangement = .aline(aligment: .center, direction: .startToEnd)
                    return vc
                }), onDismiss: { (vc) in
                    vc.dismiss(animated: true)
                })
            }
        +++ SWTableSection("水平方向")
            <<< ButtonRow("瀑布流") { row in
                row.presentationMode = .show(controllerProvider: .callback(builder: { () -> UIViewController in
                    let vc = FormCollectionDemo()
                    vc.modalPresentationStyle = .fullScreen
                    vc.hidesBottomBarWhenPushed = true
                    vc.title = "瀑布流"
                    vc.scrollDirection = .horizontal
                    vc.arrangement = .flow
                    return vc
                }), onDismiss: { (vc) in
                    vc.dismiss(animated: true)
                })
            }
            <<< ButtonRow("系统样式") { row in
                row.presentationMode = .show(controllerProvider: .callback(builder: { () -> UIViewController in
                    let vc = FormCollectionDemo()
                    vc.modalPresentationStyle = .fullScreen
                    vc.hidesBottomBarWhenPushed = true
                    vc.title = "系统样式"
                    vc.scrollDirection = .horizontal
                    vc.arrangement = .system
                    return vc
                }), onDismiss: { (vc) in
                    vc.dismiss(animated: true)
                })
            }
            <<< ButtonRow("固定行高自动换行") { row in
                row.presentationMode = .show(controllerProvider: .callback(builder: { () -> UIViewController in
                    let vc = FormCollectionDemo()
                    vc.modalPresentationStyle = .fullScreen
                    vc.hidesBottomBarWhenPushed = true
                    vc.title = "自动换行"
                    vc.scrollDirection = .horizontal
                    vc.lineHeight = 50
                    vc.arrangement = .aline(aligment: .end, direction: .endToStart)
                    return vc
                }), onDismiss: { (vc) in
                    vc.dismiss(animated: true)
                })
            }
        +++ SWTableSection("自带样式举例")
            <<< ButtonRow("混合排列（垂直）") { row in
                row.presentationMode = .show(controllerProvider: .callback(builder: { () -> UIViewController in
                    let vc = FormItemsDemo()
                    vc.modalPresentationStyle = .fullScreen
                    vc.hidesBottomBarWhenPushed = true
                    vc.title = "自带样式"
                    return vc
                }), onDismiss: { (vc) in
                    vc.dismiss(animated: true)
                })
            }
            <<< ButtonRow("混合排列（水平）") { row in
                row.presentationMode = .show(controllerProvider: .callback(builder: { () -> UIViewController in
                    let vc = FormItemsDemo()
                    vc.modalPresentationStyle = .fullScreen
                    vc.hidesBottomBarWhenPushed = true
                    vc.title = "自带样式"
                    vc.scrollDirection = .horizontal
                    return vc
                }), onDismiss: { (vc) in
                    vc.dismiss(animated: true)
                })
            }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
