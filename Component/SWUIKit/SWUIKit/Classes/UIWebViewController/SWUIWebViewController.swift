//
//  SWUIWebViewController.swift
//  VVLife
//
//  Created by ice on 2019/11/20.
//  Copyright © 2019 vv. All rights reserved.
//

import Foundation
import WebKit
import SWFoundationKit
import MessageUI

public protocol SWUIWebViewControllerDelegate: class {
    func webViewController(_ webViewController: SWUIWebViewController, titleDidChanged title: String?)
    func webViewController(_ webViewController: SWUIWebViewController, error: Error?)
}

open class SWUIWebViewController: SWBaseViewController {
    private var webView: SWUIWebView?
    open var url: String?
    open weak var delegate: SWUIWebViewControllerDelegate?
    private var showError: Bool = true
    
    deinit {
        webView?.removeObserver(self, forKeyPath: "title")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        webView = SWUIWebView(frame: CGRect(x: 0, y: SAFEAREA_TOP_HEIGHT, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-SAFEAREA_TOP_HEIGHT))
        webView?.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        webView?.navigationDelegate = self
        self.view.addSubview(webView!)
//        webView?.snp.makeConstraints({ (make) in
//            make.edges.equalToSuperview()
//        })
        
        loadUrl(urlStr: self.url)
    }
    
    public func loadUrl(urlStr: String?) {
        if let webView = self.webView, let newUrlStr = urlStr, let url = URL(string: newUrlStr) {
            var request = URLRequest(url: url)
            request.cachePolicy = .reloadIgnoringCacheData
            webView.load(request)
        }
    }
}

extension SWUIWebViewController {
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "title" {
            self.title = self.webView?.title
            self.delegate?.webViewController(self, titleDidChanged: self.webView?.title)
        }
    }
}

extension SWUIWebViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        let url = navigationAction.request.url
        let scheme = url?.scheme
        guard let schemeStr = scheme else { return  }
        if schemeStr == "mailto", let url = url {
            if !MFMailComposeViewController.canSendMail() {
                SWAlert.quickAlert(message: localizedString("sw_mail_error"))
                decisionHandler(.cancel)
                return
            }
            showError = false
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if showError {
            self.delegate?.webViewController(self, error: error)
        }
    }
}
