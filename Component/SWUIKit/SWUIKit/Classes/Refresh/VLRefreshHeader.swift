//
//  SWRefreshHeader.swift
//  SWUIKit
//
//  Created by ice on 2019/7/11.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import MJRefresh
//import Lottie
import SWBusinessKit

//public class SWRefreshHeader {
//    public static func headerView(bgColor: UIColor = UIColor(hex: 0xEEEEEE), pullColor: UIColor = .white, callback:@escaping() -> Void) -> DGElasticPullToRefreshView {
//
//        let loadingView = DGRefreshLoadingAnimationView()
//        let pullToRefreshView = DGElasticPullToRefreshView()
//        pullToRefreshView.actionHandler = callback
//        pullToRefreshView.loadingView = loadingView
//
////        pullToRefreshView.observing = true
//        pullToRefreshView.fillColor = bgColor
//        pullToRefreshView.backgroundColor = pullColor
//
//        return pullToRefreshView
//    }
//}

/// MJ下啦动画头view
//public class SWRefreshAnimationHeader: MJRefreshStateHeader {
//    /// 开始凹陷的距离
//    var pullDist: CGFloat {
//        return 95 + safeTop
//    }
//    /// 凹陷的最大高度
//    let bendDist: CGFloat = 40
//    /// 安全区域高度
//    var safeTop: CGFloat {
//        if #available(iOS 11.0, *) {
//            return safeAreaInsets.top
//        } else {
//            return 0
//        }
//    }
//    /// 刷新背景颜色
//    var refreshBackGroundColor = UIColor(hex: 0xEEEEEE) {
//        didSet {
//            pullView.backgroundColor = self.refreshBackGroundColor
//            refreshView.backgroundColor = self.refreshBackGroundColor
//            refreshEndView.backgroundColor = self.refreshBackGroundColor
//            waveView.backgroundColor = self.refreshBackGroundColor
//            backgroundColor = self.refreshBackGroundColor
//        }
//    }
//    /// 凹陷的背景色
//    public var bendColor: UIColor  = .white {
//        didSet {
//            waveView.layerColor = self.bendColor
//        }
//    }
//    /// 停止凹陷的总高度
//    var stopPos: CGFloat {
//        return pullDist + bendDist
//    }
//    /// 小鸟弹出动画view
//    lazy var pullView: AnimationView = {
//        let view = AnimationView()
//        let bundle = getCurrentBundle() ?? Bundle.main
//        view.animation = Animation.named("sw_refresh_header_pull", bundle: bundle)
//        view.frame = CGRect(x: 0, y: 0, width: self.width, height: self.pullDist)
//        view.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
//        view.backgroundBehavior = .pauseAndRestore
//        view.loopMode = .playOnce
//        view.isHidden = true
//        view.backgroundColor = refreshBackGroundColor
//        return view
//    }()
//    /// 小鸟循环飞行动画view
//    lazy var refreshView: AnimationView = {
//        let view = AnimationView()
//        let bundle = getCurrentBundle() ?? Bundle.main
//        view.animation = Animation.named("sw_refresh_header_refresh", bundle: bundle)
//        view.frame = CGRect(x: 0, y: 0, width: self.width, height: self.pullDist)
//        view.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
//        view.backgroundBehavior = .pauseAndRestore
//        view.loopMode = .loop
//        view.isHidden = true
//        view.backgroundColor = refreshBackGroundColor
//        return view
//    }()
//    /// 小鸟飞出动画view
//    lazy var refreshEndView: AnimationView = {
//        let view = AnimationView()
//        let bundle = getCurrentBundle() ?? Bundle.main
//        view.animation = Animation.named("sw_refresh_header_refresh_end", bundle: bundle)
//        view.frame = CGRect(x: 0, y: 0, width: self.width, height: self.pullDist)
//        view.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
//        view.backgroundBehavior = .pauseAndRestore
//        view.loopMode = .playOnce
//        view.isHidden = true
//        view.backgroundColor = refreshBackGroundColor
//        return view
//    }()
//    /// 底部凹陷动画view
//    lazy var waveView: SWWaveView = {
//        let view = SWWaveView(frame: CGRect(x: 0, y: self.pullDist, width: self.width, height: self.height - self.pullDist), bounceDuration: 0.6, color: bendColor)
//        view.backgroundColor = refreshBackGroundColor
//        return view
//    }()
//
//    public override var state: MJRefreshState {
//        didSet {
////            SWLogger.debug("status: \(state.rawValue)")
//            switch self.state {
//            case .idle:
//                break
//            case .refreshing:
//                waveView.didRelease(amountX: 0, amountY: bendDist)
//                self.refreshEndView.isHidden = true
//                self.refreshView.isHidden = true
//                self.pullView.isHidden = false
//                self.pullView.play(fromProgress: 0, toProgress: 1, loopMode: .playOnce) {[weak self] (finish) in
//                    self?.pullView.stop()
//                    self?.refreshView.play(fromProgress: 0, toProgress: 1, loopMode: .loop, completion: nil)
//                    self?.refreshView.isHidden = false
//                    self?.pullView.isHidden = true
//                }
////                }
//            default:
//                break
//            }
//        }
//    }
//
//    public override func prepare() {
//        super.prepare()
//        self.height = pullDist
//        self.clipsToBounds = false
//        addSubview(pullView)
//        addSubview(refreshView)
//        addSubview(refreshEndView)
//        addSubview(waveView)
//        backgroundColor = refreshBackGroundColor
//        pullView.snp.makeConstraints { (maker) in
//            maker.left.right.equalToSuperview()
//            maker.height.equalTo(pullDist)
//        }
//        refreshView.snp.makeConstraints { (maker) in
//            maker.left.right.top.equalToSuperview()
//            maker.height.equalTo(pullDist)
//        }
//        refreshEndView.snp.makeConstraints { (maker) in
//            maker.left.right.top.equalToSuperview()
//            maker.height.equalTo(pullDist)
//        }
//        waveView.snp.makeConstraints { (maker) in
//            maker.left.right.equalToSuperview()
//            maker.top.equalTo(pullDist)
//            maker.height.equalTo(bendDist)
//        }
//    }
//
//    public override func safeAreaInsetsDidChange() {
//        guard #available(iOS 11.0, *) else {
//            return
//        }
//        super.safeAreaInsetsDidChange()
//        waveView.snp.updateConstraints { (maker) in
//            maker.top.equalTo(pullDist)
//        }
//    }
//
//    public override func placeSubviews() {
//        super.placeSubviews()
//        lastUpdatedTimeLabel?.isHidden = true
//        stateLabel?.isHidden = true
//    }
//
//    public override func endRefreshing() {
////        SWLogger.debug("realtimeAnimationProgress: \(refreshView.realtimeAnimationProgress)")
//
//        guard refreshView.isAnimationPlaying else {
//            super.endRefreshing()
//            self.refreshView.stop()
//            self.refreshView.isHidden = true
//            self.pullView.isHidden = true
//            self.refreshEndView.isHidden = true
//            waveView.wave(0)
//            return
//        }
//        // 播完以后再播小鸟飞出
//        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(1 - refreshView.realtimeAnimationProgress) * 1000)) {
//            self.refreshView.stop()
//            // 延迟执行super方法
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                super.endRefreshing()
//            }
//            self.refreshEndView.play()
//            self.pullView.isHidden = true
//            self.refreshView.isHidden = true
//            self.refreshEndView.isHidden = false
//        }
//
//    }
    
//    public override func scrollViewContentOffsetDidChange(_ change: [AnyHashable : Any]?) {
//        super.scrollViewContentOffsetDidChange(change)
//        scrollView?.sendSubviewToBack(self)
//        guard let value = change?[NSKeyValueChangeKey.newKey] as? CGPoint else {
//            return
//        }
////        SWLogger.debug("value: \(value.y)")
//        guard value.y <= 0 else {
//            return
//        }
//        let y = -value.y
//        // 异步更新约束，所以需要多10来适配，不会漏出背景
//        waveView.snp.updateConstraints { (maker) in
//            maker.height.equalTo(max(0, y - pullDist + 10))
//        }
//        if state == .pulling || state == .idle {
//            if y < pullDist {
//                waveView.wave(0)
//            } else if y < stopPos {
//                waveView.wave(y - pullDist)
//            } else if y > stopPos {
//                waveView.wave(bendDist)
//            }
//        }
////        else if state == .idle {
//////            waveView.wave(0)
////        }
//        if y >= self.height {
//            ignoredScrollViewContentInsetTop = y - self.height
//        }
//        
//    }
    
//}

public class SWRefreshFooter: MJRefreshAutoNormalFooter {
    lazy var refreshButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = self.bounds
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        button.setTitle(localizedString("sw_refresh_footer_not_netword"), for: .normal)
        button.setTitleColor(UIColor(hex: 0x999999), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setImage(UIImage(named: "sw_footer_refresh"), for: .normal)
        button.addTarget(self, action: #selector(refresh), for: .touchUpInside)
        button.isHidden = true
        button.titleEdgeInsets.left = 6
        return button
    }()
    
    public override var state: MJRefreshState {
        didSet {
            switch self.state {
            case .idle:
                if SWNetworking.reachabilityStatus() == .notReachable, scrollView?.contentSize.height ?? 0 > 10 {
                    self.isHidden = false
                    self.refreshButton.isHidden = false
                } else {
                    self.refreshButton.isHidden = true
                }
            default:
                self.refreshButton.isHidden = true
            }
        }
    }
    
    public override func prepare() {
        super.prepare()
        self.setTitle("", for: .idle)
        self.setTitle(localizedString("sw_refresh_footer_not_more_data"), for: .noMoreData)
        self.setTitle(localizedString("sw_refresh_loading"), for: .refreshing)
        self.frame.size.height = 64
        self.addSubview(refreshButton)
    }
    
    public override func placeSubviews() {
        super.placeSubviews()
        self.stateLabel?.font = UIFont.systemFont(ofSize: 12)
        self.stateLabel?.textColor = UIColor(hex: 0x999999, alpha: 1)
        self.labelLeftInset = 16
    }
    
    @objc func refresh() {
        executeRefreshingCallback()
    }

}

public class VLRefreshBackFooter: MJRefreshBackNormalFooter {
    public override func prepare() {
        super.prepare()
        
        self.setTitle("", for: .idle)
        self.setTitle("", for: .pulling)
        self.setTitle(localizedString("sw_refresh_footer_not_more_data"), for: .noMoreData)
        self.setTitle(localizedString("sw_refresh_loading"), for: .refreshing)
        self.frame.size.height = 64
    }
    
    public override func placeSubviews() {
        super.placeSubviews()
        self.arrowView?.mj_x += self.labelLeftInset
        self.stateLabel?.font = UIFont.pingFangMedium(size: 12)
        self.stateLabel?.textColor = UIColor.init(hex: 0x999999, alpha: 1)
    }

}
