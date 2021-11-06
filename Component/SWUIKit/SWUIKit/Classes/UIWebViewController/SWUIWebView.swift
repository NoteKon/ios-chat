//
//  SWUIWebView.swift
//  SWUIKit
//
//  Created by huang on 2019/11/29.
//

import UIKit
import WebKit

open class SWUIWebView: WKWebView {

    override public init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        commonInit()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {

        if #available(iOS 13.0, *) {
            scrollView.automaticallyAdjustsScrollIndicatorInsets = false
        } else {
            // Fallback on earlier versions
            if #available(iOS 11.0, *) {
                scrollView.contentInsetAdjustmentBehavior = .automatic
            } else {
                // Fallback on earlier versions
            }
        }
    }
}
