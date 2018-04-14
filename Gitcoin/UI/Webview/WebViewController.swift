//
//  WebViewController.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 1/11/18.
//  Copyright © 2018 Gitcoin. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    var currentURL:URL?
    
    lazy fileprivate var refreshControl: UIRefreshControl! = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshOptions(sender:)), for: .valueChanged)
        
        return refresh
    }()
    
    lazy internal var activityIndicator: UIActivityIndicatorView! = {
        return self.createActivityIndicator()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.scrollView.addSubview(refreshControl)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.backgroundColor = webView.backgroundColor
        webView.scrollView.alwaysBounceHorizontal = false
        
        loadCurrentUrl()
    }
    
    @objc func refreshOptions(sender:UIRefreshControl){
        webView!.reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if currentURL == nil {
            loadCurrentUrl()
        }
    }
    
    func createActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100.0, height: 100.0))
        let screen = UIScreen.main.bounds
        let heightOffset:CGFloat = 0.0
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        activityIndicator.layer.cornerRadius = 05
        activityIndicator.isOpaque = false
        activityIndicator.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        self.view.addSubview(activityIndicator)
        activityIndicator.center = CGPoint(x: screen.width / 2, y: (screen.height / 2) + heightOffset)
        
        return activityIndicator
    }
    
    fileprivate func loadCurrentUrl(){
        guard let currentURL = currentURL else { return }
        
        webView.load(URLRequest(url: currentURL))
    }
}

extension WebViewController: WKUIDelegate {
    
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let url = navigationAction.request.url {
            
            if url.absoluteString.contains("authorization-callback") {
                OctokitManager.shared.oAuthConfig.handleOpenURL(url: url, completion: { (token) in
                    OctokitManager.shared.tokenConfiguration = token
                    
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                })
            }
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        if !refreshControl.isRefreshing{
            activityIndicator.startAnimating()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        activityIndicator.stopAnimating()
        refreshControl.endRefreshing()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        activityIndicator.stopAnimating()
        refreshControl.endRefreshing()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
        activityIndicator.stopAnimating()
        refreshControl.endRefreshing()
    }
}
