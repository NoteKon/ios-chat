//
//  HtmlInfoItem.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/23.
//

import WebKit
import SnapKit

// 带webview的cell，用于展示html代码
open class CollectionHtmlInfoCell : SWCollectionCellOf<String> {
    
    // 设置展示区域,html的内容不用一次性全部展示,减少卡顿
    open var showRect: CGRect = .zero {
        didSet {
            if showRect.minY + showRect.height <= contentView.frame.height {
                htmlView.frame = CGRect(
                    x: contentInsets.left,
                    y: max(contentInsets.top, showRect.minY),
                    width: contentView.bounds.width - contentInsets.left - contentInsets.right,
                    height: min(contentView.frame.height,showRect.height)
                )
                htmlView.scrollView.contentOffset = CGPoint(x: 0, y: max(0, showRect.minY - contentInsets.top))
            }
        }
    }
    
    public var contentInsets: UIEdgeInsets = .zero {
        didSet {
            htmlView.frame = CGRect(
                x: contentInsets.left,
                y: contentInsets.top,
                width: contentView.bounds.width - contentInsets.left - contentInsets.right,
                height: contentView.bounds.height - contentInsets.top - contentInsets.bottom
            )
        }
    }
    
    public lazy var htmlView: WKWebView = {
        let config = WKWebViewConfiguration()
        let preference = WKPreferences()
        preference.minimumFontSize = 40
        config.preferences = preference
        let webview = WKWebView(frame: .zero, configuration: config)
        webview.isUserInteractionEnabled = false
        webview.scrollView.isScrollEnabled = false
        webview.scrollView.bounces = false
        webview.isOpaque = false
        webview.scrollView.showsVerticalScrollIndicator = false
        webview.scrollView.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            webview.scrollView.contentInsetAdjustmentBehavior = .never
        }
        return webview
    }()

    open override func setup() {
        super.setup()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(htmlView)
        
        htmlView.frame = contentView.bounds
    }

    var currentContent: String?

    open override func update() {
        guard let content = row?.value else {
            return
        }
        htmlView.navigationDelegate = row as? HtmlInfoItem
        let formatStr = formatHtml(content)
        if currentContent == formatStr {
            return
        }
        currentContent = formatStr

        /// 先一个异步再同步加载，降低优先级，减少滑动卡顿
        DispatchQueue.global(qos: .background).async { [weak self] in
            DispatchQueue.main.async {
                self?.htmlView.loadHTMLString(formatStr, baseURL: nil)
            }
        }
    }

    func formatHtml(_ body: String) -> String {
        // 设置图片样式
        return  """
        <html>
            <head>
            <meta charset="UTF-8">
            <meta name='viewport' content='width=device-width, initial-scale=1'>
            <style type="text/css">
                html{
                    margin:0;
                    padding:0;
                    -webkit-text-size-adjust:none;
                }
                body{
                    margin: 0;
                    padding: 0;
                }
                img{
                    width: 100%;
                    height: auto;
                    display: block;
                    margin-left: auto;
                    margin-right: auto;
                }
            </style>
            </head>
            <body>
                \(body)
            </body>
        </html>
        """
    }
}

// 带webview的row，用于展示html代码，会根据网页内容大小和用户设置自动调整最终展示大小
public final class HtmlInfoItem: SWCollectionItemOf<CollectionHtmlInfoCell>, SWRowType{
    
    public override var identifier: String {
        return "HtmlInfoItem"
    }
    
    /// 预估大小
    public var estimatedSize: CGSize?
    /// 实际网页高度
    private var actualHeight: CGFloat?
    /// 实际内容比例 (宽/高)
    private var actualRatio: CGFloat?
    
    public override func customUpdateCell() {
        super.customUpdateCell()
        guard let cell = cell else {
            return
        }
        cell.backgroundColor = backgroundColor
        cell.htmlView.backgroundColor = backgroundColor
        cell.contentInsets = contentInsets
        cell.htmlView.frame = CGRect(
            x: cell.htmlView.frame.minX,
            y: cell.htmlView.frame.minY,
            width: cell.htmlView.frame.width,
            height: actualHeight ?? 0
        )
    }
    
    public override func cellWidth(for height: CGFloat) -> CGFloat {
        if let ratio = actualRatio {
            actualHeight = height - contentInsets.top - contentInsets.bottom
            let width = min(UIScreen.main.bounds.width, height * ratio)
            if let cell = cell {
                cell.htmlView.frame = CGRect(
                    x: cell.htmlView.frame.minX,
                    y: cell.htmlView.frame.minY,
                    width: cell.htmlView.frame.width,
                    height: actualHeight!
                )
            }
            return width
        }
        if estimatedSize != nil {
            let width = height * estimatedSize!.width / estimatedSize!.height
            return width
        }
        if  let aspectWidth = aspectWidth(height) {
            return aspectWidth
        }
        return 20
    }
    
    public override func cellHeight(for width: CGFloat) -> CGFloat {
        if let ratio = actualRatio {
            let actualWidth = width - contentInsets.left - contentInsets.right
            actualHeight = actualWidth / ratio
            if let cell = cell {
                cell.htmlView.frame = CGRect(
                    x: cell.htmlView.frame.minX,
                    y: cell.htmlView.frame.minY,
                    width: cell.htmlView.frame.width,
                    height: actualHeight!
                )
            }
            return actualHeight! + contentInsets.top + contentInsets.bottom
        }
        if estimatedSize != nil {
            let height = (width - contentInsets.left - contentInsets.right) * estimatedSize!.height / estimatedSize!.width + contentInsets.top + contentInsets.bottom
            return height
        }
        if  let aspectHeight = aspectHeight(width) {
            return aspectHeight
        }
        return 10
    }
}

extension HtmlInfoItem: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if actualRatio != nil {
            return
        }
        /// 修改高度
        webView.evaluateJavaScript("document.body.scrollWidth/document.body.scrollHeight") {[weak self] (value, error) in
            guard let ratio = value as? CGFloat else {
                return
            }
            self?.actualRatio = ratio
            self?.updateLayout()
        }
    }
}
