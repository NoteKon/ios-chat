//
//  MyViewController.swift
//  YunZaiApp
//
//  Created by ice on 2021/11/11.
//

import UIKit
import SWFoundationKit
import AVFoundation
@objc class MyViewController: UIViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var accountImage: UIImageView!
    @IBOutlet weak var accountName: UILabel!
    
    @IBOutlet weak var accountIdLabel: UILabel!
    
    @IBOutlet weak var statueLabel: PaddingLabel!
    
    @IBOutlet weak var accountItemView: UIView!
    @IBOutlet weak var integralItemView: UIView!
    @IBOutlet weak var myearningsItemView: UIView!
    @IBOutlet weak var settingItemView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        createBannerView()
        addAction()
    }
    
    func setUI() {
        headerView.layer.borderWidth = 0.5
        headerView.layer.borderColor = UIColor(hex: 0x78F5F4).cgColor
        headerView.layer.cornerRadius = 8
        //headerView.clipsToBounds = true
        
        bannerView.layer.cornerRadius = 10
        let shadowColor = UIColor(hex: 0xE7E7E7, alpha: 0.65)
        let offset = CGSize(width: 0, height: 0.2)
        bannerView.addShadow(color: shadowColor, offset: offset, opacity: 1, radius: 10)
        
        bottomView.layer.cornerRadius = 8
        bottomView.addShadow(color: shadowColor, offset: offset, opacity: 1, radius: 8)
        
        statueLabel.backgroundColor = UIColor(hex: 0xFEE394)
        statueLabel.layer.cornerRadius = 9
        statueLabel.clipsToBounds = true
        statueLabel.padding = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
        
        let myInfo = WFCCIMService.sharedWFCIM().getUserInfo(WFCCNetworkService.sharedInstance().userId, refresh: true)
        accountImage.loadImage(imageUrl: myInfo?.portrait, placeholder: UIImage(named: "PersonalChat"))
        accountName.text = myInfo?.displayName
        accountIdLabel.text = localizedString("my_account_id") + " \(myInfo?.name ?? "")"
    }
    
    func createBannerView() {
        let bannerArr = [("my_banner_msg", localizedString("my_banner_msg")), ("my_banner_theme", localizedString("my_banner_theme")), ("my_banner_new", localizedString("my_banner_new")), ("my_banner_fav", localizedString("my_banner_fav"))]
        
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
    
    func addAction() {
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(headerClickAction))
        headerView.addGestureRecognizer(tap)
        
        let accountTap = UITapGestureRecognizer()
        accountTap.addTarget(self, action: #selector(accountSafeClickAction))
        accountItemView.addGestureRecognizer(accountTap)
        
        let integralTap = UITapGestureRecognizer()
        integralTap.addTarget(self, action: #selector(integralClickAction))
        integralItemView.addGestureRecognizer(integralTap)
        
        let myearningsTap = UITapGestureRecognizer()
        myearningsTap.addTarget(self, action: #selector(myearningsClickAction))
        myearningsItemView.addGestureRecognizer(myearningsTap)
        
        let settingTap = UITapGestureRecognizer()
        settingTap.addTarget(self, action: #selector(settingClickAction))
        settingItemView.addGestureRecognizer(settingTap)
    }
    
    /// 查看个人主页
    @objc func headerClickAction() {
        let viewController = WFCUMyProfileTableViewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    /// 查看消息、主题、动态、收藏模块
    @objc func bannerClickAction(_ button: UIButton) {
        print("Banner \(button.tag)")
        if button.tag == 103 {
            let viewController = WFCFavoriteTableViewController()
            viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
        } else {
            showTip()
        }
    }
    
    /// 账号安全
    @objc func accountSafeClickAction() {
        showTip()
//        let viewController = WFCSecurityTableViewController()
//        viewController.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(viewController, animated: true)
    }
    /// 积分
    @objc func integralClickAction() {
        showTip()
    }
    /// 我的收益
    @objc func myearningsClickAction() {
        showTip()
    }
    /// 设置
    @objc func settingClickAction() {
        let viewController = WFCSettingTableViewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showTip() {
        self.view.makeToast("敬请期待")
    }
}
