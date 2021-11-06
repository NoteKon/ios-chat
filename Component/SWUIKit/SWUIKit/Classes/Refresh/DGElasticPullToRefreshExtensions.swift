/*

The MIT License (MIT)

Copyright (c) 2015 Danil Gontovnik

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

import UIKit
import ObjectiveC

// MARK: -
// MARK: (NSObject) Extension

public extension NSObject {
    
    // MARK: -
    // MARK: Vars
    
    fileprivate struct DGAssociatedKeys {
        static var observersArray = "observers"
    }
    
    fileprivate var dg_observers: [[String: NSObject]] {
        get {
            if let observers = objc_getAssociatedObject(self, &DGAssociatedKeys.observersArray) as? [[String: NSObject]] {
                return observers
            } else {
                let observers = [[String: NSObject]]()
                self.dg_observers = observers
                return observers
            }
        } set {
            objc_setAssociatedObject(self, &DGAssociatedKeys.observersArray, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: -
    // MARK: Methods
    
    func dg_addObserver(_ observer: NSObject, forKeyPath keyPath: String) {
        let observerInfo = [keyPath: observer]
        
        if dg_observers.firstIndex(where: { $0 == observerInfo }) == nil {
            dg_observers.append(observerInfo)
            addObserver(observer, forKeyPath: keyPath, options: .new, context: nil)
        }
    }
    
    func dg_removeObserver(_ observer: NSObject, forKeyPath keyPath: String) {
        let observerInfo = [keyPath: observer]
        
        if let index = dg_observers.firstIndex(where: { $0 == observerInfo}) {
            dg_observers.remove(at: index)
            removeObserver(observer, forKeyPath: keyPath)
        }
    }
    
}

// MARK: -
// MARK: (UIScrollView) Extension

public extension UIScrollView {
    
    // MARK: - Vars

    struct DGAssociatedKeys {
        static var sw_header = "sw_header"
    }

    var sw_header: DGElasticPullToRefreshView? {
        get {
            return objc_getAssociatedObject(self, &DGAssociatedKeys.sw_header) as? DGElasticPullToRefreshView
        }

        set {
            guard let newView = newValue, self.sw_header != newValue else {
                return
            }
            self.sw_header?.removeFromSuperview()
            addSubview(newView)
            newView.observing = true
            isMultipleTouchEnabled = false
            panGestureRecognizer.maximumNumberOfTouches = 1
            objc_setAssociatedObject(self, &DGAssociatedKeys.sw_header, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: - Methods (Public)

    func dg_isRefreshing() -> Bool {
        return sw_header?.state == .loading
    }
    
    func dg_deallocPullRefresh() {
        sw_header?.disassociateDisplayLink()
        sw_header?.observing = false
        sw_header?.removeFromSuperview()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil, sw_header != nil {
            dg_deallocPullRefresh()
        }
    }
    
}

// MARK: -
// MARK: (UIView) Extension

public extension UIView {
    func dg_center(_ usePresentationLayerIfPossible: Bool) -> CGPoint {
        if usePresentationLayerIfPossible, let presentationLayer = layer.presentation() {
            // Position can be used as a center, because anchorPoint is (0.5, 0.5)
            return presentationLayer.position
        }
        return center
    }
}

// MARK: -
// MARK: (UIPanGestureRecognizer) Extension

public extension UIPanGestureRecognizer {
    func dg_resign() {
        isEnabled = false
        isEnabled = true
    }
}

// MARK: -
// MARK: (UIGestureRecognizerState) Extension

public extension UIGestureRecognizer.State {
    func dg_isAnyOf(_ values: [UIGestureRecognizer.State]) -> Bool {
        return values.contains(where: { $0 == self })
    }
}
