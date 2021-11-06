//
//  SWGraphicCodeView.swift
//  VVLife
//
//  Created by 吴桂钊 on 2021/4/1.
//  Copyright © 2021 vv. All rights reserved.
//

import Foundation
import UIKit

class SWGraphicCodeView: UIView {
    
    var bgImgView: UIImageView!
    
    var codeString: String?
    
    var codeFont: UIFont = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        creatUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        creatUI()
    }
    
    private func creatUI() {
        bgImgView = UIImageView()
        bgImgView.backgroundColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
        bgImgView.frame = self.bounds
        self.addSubview(bgImgView)
    }
    
    public func updateCodeString(code: String) {
        self.bgImgView.subviews.forEach { (obj) in
            obj.removeFromSuperview()
        }
        self.bgImgView.layer.sublayers?.forEach { $0.removeFromSuperlayer()}
        
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
            label.textColor = UIColor.orange
            bgImgView.addSubview(label)
            
            // 旋转角度
            let r = (CGFloat.random(in: 1 ... 100) - 50.0) / 200.0
            label.transform = CGAffineTransform(rotationAngle: (CGFloat.pi * CGFloat(r)))
        }
        
        // 背景随机小点
        for index in 0..<10 {
            let path = UIBezierPath()
            print("\(index)")
            // 随机
            let pX = CGFloat(arc4random_uniform(UInt32(self.frame.size.width - 2)))
            let pY = CGFloat(arc4random_uniform(UInt32(self.frame.size.height - 2)))
            
            path.move(to: CGPoint(x: pX, y: pY))
//            let ptX = CGFloat(arc4random_uniform(UInt32(self.frame.size.width)))
//            let ptY = CGFloat(arc4random_uniform(UInt32(self.frame.size.height)))
//                path.addLine(to: CGPoint(x: ptX, y: ptY))
            path.addLine(to: CGPoint(x: pX + 2, y: pY + 2))
            
            let layer = CAShapeLayer()
            layer.strokeColor = randomBgColor(alpha: 1).cgColor
            layer.lineWidth = 1.5
            layer.strokeEnd = 1
            layer.fillColor = UIColor.clear.cgColor
            layer.path = path.cgPath
            bgImgView.layer.addSublayer(layer)
        }
    }
    
    func randomBgColor(alpha: CGFloat) -> UIColor {
        let red = CGFloat.random(in: 0.1 ... 255.0)
        let green = CGFloat.random(in: 0.1 ... 255.0)
        let blue = CGFloat.random(in: 0.1 ... 255.0)
        let color = UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
        return color
    }
}
