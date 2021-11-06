//
//  SWGraphicCodeView.swift
//  VVLife
//
//  Created by 吴桂钊 on 2021/4/1.
//  Copyright © 2021 vv. All rights reserved.
//

import Foundation
import UIKit

/// 加载类型
public enum LoadType: Int {
    case loading = 0
    case loadFailed
}

public class SWGraphicCodeView: UIView {
    
    /// 加载中的图片
    let iconImg: UIImageView = UIImageView()
    /// 提示文字
    let tipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = UIColor(hex: 0x999999)
        return label
    }()
    /// 加载中/错误信息容器
    var loadingBox: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xf2f2f2)
        return view
    }()
    
    /// 验证码背景
    var codeBox: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    /// 验证码字符串
    var codeString: String?
    
    /// 验证码的字体
    var codeFont: UIFont = UIFont.systemFont(ofSize: 20, weight: .semibold)
    
    // UI要求圆点颜色
    var pointColors: [UIColor] = [UIColor(hex: 0xAD808E), UIColor(hex: 0x749B65), UIColor(hex: 0x757664), UIColor(hex: 0x856F7D), UIColor(hex: 0x85534E), UIColor(hex: 0x5F66AB), UIColor(hex: 0x855FAB), UIColor(hex: 0xBBB1BB), UIColor(hex: 0xAAB0B0), UIColor(hex: 0xAB935F)]
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    /// 配置UI
    private func setupUI() {
        self.addSubview(loadingBox)
        loadingBox.addSubview(iconImg)
        loadingBox.addSubview(tipLabel)
        
        self.addSubview(codeBox)
        
        iconImg.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(7)
            make.size.equalTo(CGSize(width: 12, height: 12))
        }
        tipLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(iconImg.snp.right).offset(4)
            make.right.equalToSuperview().offset(-5)
        }
        
        loadingBox.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        codeBox.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    /// 根据给定的类型展示加载样式
    /// - Parameter loadType: LoadType.loading => 加载中   LoadType.loadFailed => 加载失败
    public func showLoading(loadType: LoadType) {
        self.codeBox.isHidden = true
        if loadType == .loading {
            iconImg.image = loadImageNamed("sw_loading_icon")
            tipLabel.text = localizedString("sw_graphic_code_loading")
        } else {
            iconImg.image = loadImageNamed("sw_load_failed_icon")
            tipLabel.text = localizedString("sw_graphic_code_load_failed")
        }
    }
    
    /// 根据指定的code生成验证码图层
    /// - Parameter code: code
    public func updateCodeString(code: String) {
        self.clearBgViewSubViewsAndLayer()
        self.codeBox.isHidden = false
        codeString = code
        guard !code.isEmpty else {
            return
        }
        let size = NSString(string: "W").size(withAttributes:
                                                [NSAttributedString.Key.font: codeFont])
        var randWidth = ceil((self.frame.size.width) / CGFloat(code.count) - size.width)
        let randHeight = self.frame.size.height - size.height
        if randWidth < 0 {
            randWidth = 0
        }
        for index in 0..<code.count {
            let px = index * (Int(self.frame.size.width) - 5) / code.count
            let pxValue = px + Int(arc4random_uniform(UInt32(randWidth)))
//                let py = arc4random_uniform(UInt32(randHeight)) // Y偏移
            
            let label = UILabel()
            label.frame = CGRect(x: CGFloat(pxValue) + 2, y: CGFloat(randHeight * 0.5), width: size.width, height: size.height)
            if let charString = code[index] {
                label.text = "\(charString)"
            }
            label.font = codeFont
            label.textColor = UIColor(hex: 0xffa22d)
            codeBox.addSubview(label)
            
            // 旋转角度
            let r = (CGFloat.random(in: 1 ... 100) - 50.0) / 200.0
            label.transform = CGAffineTransform(rotationAngle: (CGFloat.pi * CGFloat(r)))
        }
        

//        for index in 0..<10 {
//            let path = UIBezierPath()
//            print("\(index)")
//            // 随机划线
//            let pX = CGFloat(arc4random_uniform(UInt32(self.frame.size.width - 2)))
//            let pY = CGFloat(arc4random_uniform(UInt32(self.frame.size.height - 2)))
//
//            path.move(to: CGPoint(x: pX, y: pY))
////            let ptX = CGFloat(arc4random_uniform(UInt32(self.frame.size.width)))
////            let ptY = CGFloat(arc4random_uniform(UInt32(self.frame.size.height)))
////                path.addLine(to: CGPoint(x: ptX, y: ptY))
//            path.addLine(to: CGPoint(x: pX + 2, y: pY + 2))
//
//            let layer = CAShapeLayer()
//            layer.strokeColor = randomBgColor(alpha: 1).cgColor
//            layer.lineWidth = 1.5
//            layer.strokeEnd = 1
//            layer.fillColor = UIColor.clear.cgColor
//            layer.path = path.cgPath
//            bgImgView.layer.addSublayer(layer)
//        }
        
        // 8-15个随机点
        let times = Int.random(in: 8 ... 15)
        for _ in 0..<times {
            // 随机 小圆点
            let pX = CGFloat(arc4random_uniform(UInt32(self.frame.size.width - 2)))
            let pY = CGFloat(arc4random_uniform(UInt32(self.frame.size.height - 2)))
            
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: pX, y: pY),
                                    radius: 1,
                                    startAngle: CGFloat(0),
                                    endAngle: CGFloat(CGFloat.pi * 2),
                                    clockwise: true)
        
            let circleLayer = CAShapeLayer()
            circleLayer.path = circlePath.cgPath
            
            let count = pointColors.count - 1
            let ranIndex = Int.random(in: 1 ... count)
            circleLayer.fillColor = pointColors[ranIndex].cgColor
            codeBox.layer.addSublayer(circleLayer)
        }
    }

    /// 移除验证码的所有layer
    func clearBgViewSubViewsAndLayer() {
        self.codeBox.subviews.forEach { (obj) in
            obj.removeFromSuperview()
        }
        self.codeBox.layer.sublayers?.forEach { $0.removeFromSuperlayer()}
    }
    
    /// 产生随机颜色
    func randomBgColor(alpha: CGFloat) -> UIColor {
        let red = CGFloat.random(in: 0.1 ... 255.0)
        let green = CGFloat.random(in: 0.1 ... 255.0)
        let blue = CGFloat.random(in: 0.1 ... 255.0)
        let color = UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
        return color
    }
}
