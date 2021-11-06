//
//  SWPageViewController.swift
//  VVPartner
//
//  Created by huang on 2019/10/9.
//  Copyright © 2019 vv. All rights reserved.
//

import UIKit

public protocol SWPageViewControllerDelegate: class {
    func pageViewController(_ pageViewController: SWPageViewController, didEndScrollAtIndex: Int)
}

open class SWPageViewController: UIViewController {
    private var pageViewController: UIPageViewController!
    private var viewHasAppeared: Bool = false
    private var preferredIndex: Int = -1
    
    open weak var delegate: SWPageViewControllerDelegate?
    
    open var _defaultSelectedIndex: Int = 0
    
    open var viewControllers: [UIViewController]?
    
    public private(set) var selectedIndex: Int = 0
    
    open var _isScrollEnabled: Bool = true {
        didSet {
            updateScrollEnabled()
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if viewHasAppeared == false {
            viewHasAppeared = true
            let index = preferredIndex >= 0 ? preferredIndex : _defaultSelectedIndex
            selectPageAt(index: index, animated: false)
        }
    }
    
    private func initUI() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        addChild(pageViewController)
        self.view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        pageViewController.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        updateScrollEnabled()
    }
    
    private var isPageViewLoaded: Bool {
        guard self.isViewLoaded else {
            return false
        }
        guard let pageViewController = pageViewController, pageViewController.isViewLoaded else {
            return false
        }
        return true
    }
    
    private func updateScrollEnabled() {
        guard isPageViewLoaded else { return }
        
        for view in pageViewController.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.isScrollEnabled = _isScrollEnabled
            }
        }
    }
    
    open func selectPageAt(index: Int, animated: Bool) {
        guard let viewControllers = self.viewControllers else {
            return
        }
        guard index >= 0 && index < viewControllers.count else {
            return
        }
        guard isPageViewLoaded && viewHasAppeared else {
            preferredIndex = index
            return
        }
        
        let currentVC = viewControllers[index]
        var direction: UIPageViewController.NavigationDirection = .forward
        if let oldVC = pageViewController.viewControllers?.last,
            let oldIndex = viewControllers.firstIndex(of: oldVC), oldIndex > index {
            direction = .reverse
        }
        pageViewController.setViewControllers([currentVC], direction: direction, animated: animated, completion: nil)
        selectedIndex = index
    }
}

extension SWPageViewController: UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllers = self.viewControllers else {
            return nil
        }
        guard let index = viewControllers.firstIndex(of: viewController) else {
            return nil
        }
        if index <= 0 {
            return nil
        }
        return viewControllers[index-1]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllers = self.viewControllers else {
            return nil
        }
        guard let index = viewControllers.firstIndex(of: viewController) else {
            return nil
        }
        if index >= viewControllers.count - 1 {
            return nil
        }
        return viewControllers[index+1]
    }
}

extension SWPageViewController: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentVC = pageViewController.viewControllers?.first,
            let index = viewControllers?.firstIndex(of: currentVC) {
            selectedIndex = index
            delegate?.pageViewController(self, didEndScrollAtIndex: index)
        }
    }
}
