//
//  FPSLabel.swift
//  GZCList_Example
//
//  Created by Guo ZhongCheng on 2020/9/10.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import SWUIKit

class FPSLabel: UILabel {

    private var link:CADisplayLink?
    
    private var lastTime:TimeInterval = 0.0;
    
    private var count:Int = 0;

    override init(frame: CGRect) {
        super.init(frame: frame)

        link = CADisplayLink.init(target: self, selector: #selector(didTick(link:)))
        link?.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        link?.invalidate()
    }
    
    @objc func didTick(link:CADisplayLink){
    
        if lastTime == 0 {
            lastTime = link.timestamp
            return
        }
        count += 1
        
        let delta = link.timestamp - lastTime
        
        if delta < 1 {
            return
        }
        
        lastTime = link.timestamp
        
        // 帧数========>可以自己定义作为label显示
        let fps = Double(count) / delta
        
        
        count = 0
        
        text = String(format: "%02.0f FPS",round(fps))
        
        // 打印帧数
//        print(text ?? "0")
        
    }
}
