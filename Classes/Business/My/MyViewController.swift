//
//  MyViewController.swift
//  YunZaiApp
//
//  Created by ice on 2021/11/11.
//

import UIKit
import SWFoundationKit
@objc class MyViewController: UIViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var statueLabel: PaddingLabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        createBannerView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //bannerView.addCorners([.allCorners], radius: 10)
        //bottomView.addCorners([.allCorners], radius: 8)
    }
    
    func setUI() {
        headerView.layer.borderWidth = 0.5
        headerView.layer.borderColor = UIColor(hex: 0x78F5F4).cgColor
        headerView.layer.cornerRadius = 8
        //headerView.clipsToBounds = true
        
        bannerView.layer.cornerRadius = 10
        let shadowColor = UIColor(hex: 0xBBBBBB, alpha: 0.65)
        let offset = CGSize(width: 0, height: 2)
        bannerView.addShadow(color: shadowColor, offset: offset, opacity: 1, radius: 10)
        
        bottomView.layer.cornerRadius = 8
        bottomView.addShadow(color: shadowColor, offset: offset, opacity: 1, radius: 8)
        
        statueLabel.backgroundColor = UIColor(hex: 0xFEE394)
        statueLabel.layer.cornerRadius = 9
        statueLabel.clipsToBounds = true
        statueLabel.padding = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
    }
    
    func createBannerView() {
        let bannerArr = [("my_banner_msg", "消息"), ("my_banner_theme", "主题"), ("my_banner_new", "动态"), ("my_banner_fav", "收藏")]
        
        var lastView: UIView? = nil
        let offsetX = (SCREEN_WIDTH - 21 * 2 - 16 * 2 - 45 * 4) / 3
        for i in 0..<bannerArr.count {
            let item = bannerArr[i]
            let subView = UIView()
            
            bannerView.addSubview(subView)
            subView.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.width.equalTo(45)
                if lastView != nil {
                    make.left.equalTo(lastView!.snp.right).offset(offsetX)
                } else {
                    make.left.equalTo(bannerView.snp.left).offset(21)
                }
            }
            
            lastView = subView
            
            let btn = UIButton(frame: CGRect(x: 0, y: 14, width: 45, height: 45))
            btn.tag = 100 + i
            btn.setImage(UIImage(named: item.0), for: .normal)
            btn.addTarget(self, action: #selector(bannerClickAction(_:)), for: .touchUpInside)
            subView.addSubview(btn)
            
            let label = UILabel(frame: CGRect(x: 0, y: 68, width: 45, height: 15))
            label.font = UIFont.pingFangRegular(size: 16)
            label.textColor = UIColor(hex: 0x343434)
            label.text = item.1
            label.textAlignment = .center
            subView.addSubview(label)
        }
        
        if let lastView = lastView {
            bannerView.snp.makeConstraints { make in
                make.right.equalTo(lastView.snp.right).offset(21)
            }
        }
    }
    
    @objc func bannerClickAction(_ button: UIButton) {
        
    }
}

extension MyViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell") as? UITableViewCell
        cell?.textLabel?.text = "\(indexPath.row)"
        return cell!
    }
}
