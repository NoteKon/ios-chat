//
//  DGElasticPullToRefreshLoadingAnimationView.swift
//  VVLife
//
//  Created by jack on 2020/4/22.
//  Copyright © 2020 vv. All rights reserved.
//

import UIKit

class DGRefreshLoadingAnimationView: DGElasticPullToRefreshLoadingView {
    
    // MARK: Constructors
    /// 刷新背景颜色
    var refreshBackGroundColor = UIColor(hex: 0xEEEEEE) {
        didSet {
//            pullView.backgroundColor = self.refreshBackGroundColor
            backgroundColor = self.refreshBackGroundColor
        }
    }
    
//    /// 小鸟弹出动画view
//    lazy var pullView: AnimationView = {
//        let view = AnimationView(name: "sw_refresh_header_pull")
//        view.frame = CGRect(x: 0, y: 0, width: self.width, height: DGElasticPullToRefreshConstants.LoadingContentInset)
//        view.contentMode = .scaleAspectFill
//        view.backgroundBehavior = .pauseAndRestore
//        view.animationSpeed = 1.1
//        view.loopMode = .playOnce
//        view.clipsToBounds = true
//        view.backgroundColor = refreshBackGroundColor
//        return view
//    }()
    
    public override init() {
        super.init(frame: .zero)
        setUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
//        addSubview(pullView)
        
//        pullView.snp.makeConstraints { (maker) in
//            maker.left.right.top.equalToSuperview()
//            maker.height.equalTo(DGElasticPullToRefreshConstants.LoadingContentInset)
//        }
    }
    
    // MARK: Actions
    override func startAnimating() {
//        pullView.animation = Animation.named("sw_refresh_header_pull", bundle: getCurrentBundle() ?? Bundle.main)
//        pullView.play(fromProgress: 0, toProgress: 1, loopMode: .playOnce) { [weak self] (finish) in
//            self?.pullView.animation = Animation.named("sw_refresh_header_refresh", bundle: getCurrentBundle() ?? Bundle.main)
//            self?.pullView.play(fromProgress: 0, toProgress: 1, loopMode: .loop, completion: nil)
//        }
    }

    override func stopLoading() {
//        pullView.play(fromProgress: pullView.realtimeAnimationProgress, toProgress: 1, loopMode: .playOnce) { [weak self] (finish) in
//            self?.pullView.animation = Animation.named("sw_refresh_header_refresh_end", bundle: getCurrentBundle() ?? Bundle.main)
//            self?.pullView.play(fromProgress: 0, toProgress: 1, loopMode: .playOnce, completion: nil)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                NotificationCenter.default.post(name: refreshNotification, object: nil)
//            }
//        }
    }
}
