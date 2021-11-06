//
//  UITextView+Ex.swift
//  VVLife
//
//  Created by jack on 2020/6/17.
//  Copyright © 2020 vv. All rights reserved.
//

import UIKit

public extension UITextView {
    // 限制字符输入,按英文，数字来判断，中文算2个
    func limitTextCount(_ limitCount: Int, endEditing: Bool = true, closure: (() -> Void)? = nil) -> Int {
        // 总的数量
        let allCount = self.text.count
        // 高亮的数量
        var markedCount = 0
        if let markedRange = self.markedTextRange, let markedText = self.text(in: markedRange) {
            markedCount = markedText.count
        }
        // 剩下在显示的文本数量
        let remainCount = allCount - markedCount
        let remainText = String(self.text.prefix(remainCount))
        // 计算总数
        var totalCount = 0
        var showText = ""
        let patternChinese = "[\\u4e00-\\u9fa5]|[\\u3000-\\u301e\\ufe10-\\ufe19\\ufe30-\\ufe44\\ufe50-\\ufe6b\\uFF01-\\uFFEE]"
        var regex: NSRegularExpression?
        do {
            regex = try NSRegularExpression(pattern: patternChinese, options: .caseInsensitive)
        } catch {
            
        }
        
        for char in remainText {
            var addCount = char.utf8.count
            let checkStr = String(char)
            
            // 中文字符串算2个字符
            if let _ = regex?.firstMatch(in: checkStr, options: [], range: NSRange(location: 0, length: checkStr.count)) {
                addCount = 2
            }
            
            totalCount += addCount
            if totalCount <= limitCount {
                showText.append(char)
            } else {// 超出的时候减回去
                totalCount -= addCount
                closure?()
                if endEditing { self.endEditing(true) }
                break
            }
        }
        if remainText != showText {
            self.text = showText
        }
        return totalCount
    }
    
    func maxTextCount(_ limitCount: Int, endEditing: Bool = true, closure: (() -> Void)?) -> Int {
        return limitTextCount(limitCount, endEditing: endEditing, closure: closure)
    }
}
