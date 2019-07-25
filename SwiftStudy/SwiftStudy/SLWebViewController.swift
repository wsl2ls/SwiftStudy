//
//  SLWebViewController.swift
//  SwiftStudy
//
//  Created by wsl on 2019/7/25.
//  Copyright © 2019 https://github.com/wsl2ls/WKWebView All rights reserved.
//

import UIKit
import WebKit

class SLWebViewController: UIViewController {
    
    lazy var webView: WKWebView = {
        let webView = WKWebView()
        // UI代理
        webView.uiDelegate = self
        // 导航代理
        webView.navigationDelegate = self
        //添加监测网页标题title的观察者
        webView.addObserver(self, forKeyPath: "title", options: NSKeyValueObservingOptions.new, context: nil)
        //监测进度
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)
        return webView
    }()
    lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.tintColor = UIColor.blue
        progressView.trackTintColor = UIColor.clear
        return progressView
    }()
    //默认值
    var urlStr: String = "https://www.jianshu.com/u/e15d1f644bea"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        webView.removeObserver(self, forKeyPath: "title")
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    // MARK: UI
    func setupUI() {
        self.view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        let request: URLRequest = URLRequest(url: URL(string: urlStr)!)
        webView.load(request)
        self.view.addSubview(progressView)
    }
    //安全距离什么时候被改变
    override func viewSafeAreaInsetsDidChange() {
        // 考虑安全距离
        let insets: UIEdgeInsets = self.view.safeAreaInsets
        progressView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(insets.top)
            make.height.equalTo(2)
        }
    }
    
    // MARK: Events Handle
    // kvo 监听回调
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            print("进度 \(webView.estimatedProgress)")
            progressView.progress = Float(webView.estimatedProgress)
            if (progressView.progress >= 1.0) {
                let deadline = DispatchTime.now() + 0.3
                DispatchQueue.global().asyncAfter(deadline: deadline) {
                    DispatchQueue.main.async {
                        self.progressView.progress = 0;
                    }
                }
            }
        } else if keyPath == "title" {
            self.navigationItem.title = webView.title;
        }
    }
}
  // MARK: WKUIDelegate, WKNavigationDelegate
extension SLWebViewController: WKUIDelegate, WKNavigationDelegate {
    // 页面加载失败时调用
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
    }
    // 页面加载完成之后调用
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
    }
    //提交发生错误时调用
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressView.progress = 0
    }
    // 根据WebView对于即将跳转的HTTP请求头信息和相关信息来决定是否跳转
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let urlStr: String = navigationAction.request.url!.absoluteString
        print("网页内链接 \(urlStr)")
        //允许跳转
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    // 根据客户端受到的服务器响应头以及response相关信息来决定是否可以跳转
    private func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        //允许跳转
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
}
