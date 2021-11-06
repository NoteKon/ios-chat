//
//  SWRefreshViewController.swift
//  SWUIKit_Example
//
//  Created by jack on 2020/4/27.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import SWUIKit

class SWRefreshViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        // Do any additional setup after loading the view.
    }
    
    func setUI() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "刷新", style: .plain, target: self, action: #selector(refreshData))
        
        self.scrollView.alwaysBounceVertical = true
        self.scrollView.backgroundColor = .white
        
        scrollView.sw_header = SWRefreshHeader.headerView { [weak self] in
            print("loaddata")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self?.scrollView.sw_header?.endRefreshing()
            }
        }
//        self.scrollView.contentInset = UIEdgeInsets(top: -UIApplication.shared.statusBarFrame.height, left: 0, bottom: 0, right: 0)
//        if #available(iOS 11.0, *) {
//            scrollView.contentInsetAdjustmentBehavior = .never
//        } else {
//            // Fallback on earlier versions
//            self.automaticallyAdjustsScrollViewInsets = false
//        }
//        scrollView.sw_header?.addTopInset = UIApplication.shared.statusBarFrame.height
    }
    
    @objc func refreshData() {
        print("refreshData")
        self.scrollView.sw_header?.beginRefreshing()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
