//
//  UIViewControlller+CartAnimation.swift
//  VVLife
//
//  Created by jack on 2020/7/24.
//  Copyright © 2020 vv. All rights reserved.
//

import UIKit

var animatonViewKey = "animatonViewKey"
var cartFinishBlockKey = "cartFinishBlockKey"

extension UIViewController: CAAnimationDelegate {
    
    // MARK: CAAnimationDelegate
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        if let addCarAnimationView = cartAnimationView {
            addCarAnimationView.removeFromSuperview()
            cartAnimationView = nil
            cartAnimatonFinishBlock?()
            cartAnimatonFinishBlock = nil
        }
    }
    
    private var cartAnimationView: UIView? {
        get {
            if let cartView = objc_getAssociatedObject(self, &animatonViewKey) as? UIView {
                return cartView
            }
            return nil
        }
        
        set {
            objc_setAssociatedObject(self, &animatonViewKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var cartAnimatonFinishBlock: (() -> Void)? {
        get {
            if let block = objc_getAssociatedObject(self, &cartFinishBlockKey) as? () -> Void {
                return block
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &cartFinishBlockKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    /// 开始购物车动画
    /// - Parameters:
    ///   - imageView: 加入购物车的商品view
    ///   - cartView: 购物车的view
    ///   - finish: 动画结束回调
    public func beginCartAnimation(_ imageView: UIView, cartView: UIView, finish: (() -> Void)?) {
        guard cartAnimationView == nil else { return }
        cartAnimatonFinishBlock = finish
        let duration = 1.0
        
        let viewRect = imageView.convert(imageView.bounds, to: self.view)
        let startPoint = CGPoint(
            x: viewRect.origin.x + viewRect.size.width / 2,
            y: viewRect.origin.y + viewRect.size.height / 2
        )
        
        // 购物车中点
        let desViewRect = cartView.convert(cartView.bounds, to: self.view)
        let desPoint = CGPoint(
            x: desViewRect.origin.x + desViewRect.size.width / 2,
            y: desViewRect.origin.y + desViewRect.size.height / 2
        )
        
        let controlPoint = CGPoint(x: (startPoint.x + desPoint.x) / 5, y: (startPoint.y + desPoint.y) / 2 )
        let path  = UIBezierPath()
        path.move(to: startPoint)
        path.addQuadCurve(to: desPoint, controlPoint: controlPoint)
        
        animationImageToCard(sourceView: imageView, viewRect: viewRect, path: path, duration: duration)
    }
    
    /// 从商品图片位置，截图进入购物车
    private func animationImageToCard(sourceView: UIView, viewRect: CGRect, path: UIBezierPath, duration: CFTimeInterval) {
        // 获取贝塞尔曲线的路径
        let pathAnimation = CAKeyframeAnimation.init(keyPath: "position")
        pathAnimation.path = path.cgPath
        pathAnimation.beginTime = 0.3
        pathAnimation.duration = duration - 0.3
        pathAnimation.delegate = self
        pathAnimation.fillMode = CAMediaTimingFillMode.forwards
        pathAnimation.isRemovedOnCompletion = false
        
        //缩小图片到0
        let scaleAnimation = CAKeyframeAnimation.init(keyPath: "transform.scale")
        scaleAnimation.values = [1.0, 0.3, 0.4, 0.3, 0.0]
        scaleAnimation.keyTimes = [NSNumber(value: 0.0), NSNumber(value: 0.2), NSNumber(value: 0.3), NSNumber(value: 0.4), NSNumber(value: 1.0)]
        scaleAnimation.duration = duration
        
        let alphaAnimation = CAKeyframeAnimation.init(keyPath: "alpha")
        alphaAnimation.values = [0.0, 0.1, 0.0]
        alphaAnimation.keyTimes = [NSNumber(value: 0.0), NSNumber(value: 0.2), NSNumber(value: 1.0)]
        alphaAnimation.duration = duration
        
        //组合动画
        let animationGroup: CAAnimationGroup = CAAnimationGroup()
        animationGroup.animations = [pathAnimation, scaleAnimation, alphaAnimation]
        animationGroup.duration = duration
        animationGroup.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animationGroup.delegate = self
        animationGroup.fillMode = CAMediaTimingFillMode.forwards
        animationGroup.isRemovedOnCompletion = false
        
        // 初始化动画view
        let copyImage = sourceView.asImage()
        cartAnimationView = UIImageView(image: copyImage)
        cartAnimationView?.tintColor = UIColor(hex: 0xFFA22C)
        cartAnimationView?.frame = viewRect
        let mask = CALayer()
        mask.backgroundColor = UIColor.black.cgColor
        mask.frame = CGRect(
            x: viewRect.size.width / 2 - viewRect.size.height / 2,
            y: 0,
            width: viewRect.size.height,
            height: viewRect.size.height
        )
        mask.cornerRadius = mask.frame.width / 2
        cartAnimationView?.layer.mask = mask
        
        self.view.addSubview(cartAnimationView!)
        
        cartAnimationView?.layer.add(animationGroup, forKey: "add_cart_infresh_animation")
    }
    
    /// 开始抖动动画
    public func shakeCartAnimation(view: UIView) {
        //购物车抖动
        let shakeAnimation = CABasicAnimation.init(keyPath: "transform.scale")
        shakeAnimation.duration = 0.5/2.0
        shakeAnimation.fromValue = NSNumber.init(value: 1)
        shakeAnimation.toValue = NSNumber.init(value: 1.2)
        shakeAnimation.autoreverses = true
        view.layer.add(shakeAnimation, forKey: "shake_cart_infresh_animation")
    }
}
