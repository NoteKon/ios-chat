//
//  HtmlInfoRow.swift
//  GZCList
//
//  Created by Guo ZhongCheng on 2020/9/10.
//

import WebKit
import SnapKit

// 带webview的cell，用于展示html代码
open class HtmlInfoCell : SWTableCellOf<String> {
    
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
    
    var isLayouted: Bool = false
    public var contentInsets: UIEdgeInsets = .zero {
        didSet {
            updateInsets()
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
        if #available(iOS 11.0, *) {
            webview.scrollView.contentInsetAdjustmentBehavior = .never
        }
        return webview
    }()

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    open override func setup() {
        super.setup()
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        textLabel?.isHidden = true
        contentView.addSubview(htmlView)
        
        htmlView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0)
    }

    var currentContent: String?

    open override func update() {
        guard let content = row?.value else {
            return
        }
        htmlView.navigationDelegate = row as? HtmlInfoRow
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
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if !isLayouted {
            updateInsets()
        }
        isLayouted = true
    }
    
    func updateInsets() {
        htmlView.frame = CGRect(
            x: contentInsets.left,
            y: contentInsets.top,
            width: contentView.bounds.width - contentInsets.left - contentInsets.right,
            height: contentView.bounds.height - contentInsets.top - contentInsets.bottom
        )
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

extension HtmlInfoRow: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        /// 修改高度
        cell?.htmlView.evaluateJavaScript("document.body.scrollWidth/document.body.scrollHeight") {[weak self] (value, error) in
            guard let ratio = value as? CGFloat else {
                return
            }
            if self?.actualRatio != ratio {
                self?.actualRatio = ratio
                self?.updateLayout()
            }
        }
    }
}

// 带webview的row，用于展示html代码，会根据网页内容大小和用户设置自动调整最终展示大小
public final class HtmlInfoRow: SWTableRowOf<HtmlInfoCell>, SWRowType{
    
    public override var identifier: String {
        return "HtmlInfoRow"
    }
    
    /// 预估大小
    public var estimatedSize: CGSize?
    /// 实际网页高度
    private var actualHeight: CGFloat?
    /// 实际内容比例 (宽/高)
    private var actualRatio: CGFloat?
    
    /// 根据预估大小返回首次的高度
    var _cellHeight: CGFloat?
    public override var cellHeight: CGFloat? {
        set {
            _cellHeight = newValue
        }
        get {
            if _cellHeight == nil {
                guard
                    let size = estimatedSize,
                    let tableView = (section?.form?.delegate as? SWTableViewHandler)?.tableView else {
                    return _cellHeight
                }
                _cellHeight = max(0, CGFloat(Int((tableView.frame.width - contentInsets.left - contentInsets.right) * size.height / size.width)) + contentInsets.top + contentInsets.bottom)
            }
            return _cellHeight
        }
    }
    
    func updateLayout() {
        if
            let ratio = actualRatio,
            let cell = cell
        {
            let actualWidth = cell.frame.width - contentInsets.left - contentInsets.right
            actualHeight = actualWidth / ratio
            cell.htmlView.frame = CGRect(
                x: cell.htmlView.frame.minX,
                y: cell.htmlView.frame.minY,
                width: actualWidth,
                height: actualHeight!
            )
            cell.updateHeight(actualHeight! + contentInsets.top + contentInsets.bottom)
        }
    }
    
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
}
