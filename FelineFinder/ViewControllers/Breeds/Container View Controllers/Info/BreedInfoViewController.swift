//
//  BreedInfoViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/25/20.
//

import UIKit
import WebKit

class BreedInfoViewController: UIViewController, WKNavigationDelegate {

    var breed: Breed?
    
    @IBOutlet weak var wv: WKWebView!
    @IBOutlet weak var toolbar: UIToolbar!
    var progressView: UIProgressView!
    var level = 0
    var maxLevel = 0
    var websites = ["en.wikipedia.org", "en.m.wikipedia.org"]
    
    var back: UIBarButtonItem!
    var forward: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wv.navigationDelegate = self
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: wv, action: #selector(wv.reload))
        back = UIBarButtonItem(barButtonSystemItem: .rewind, target: wv, action: #selector(wv.goBack))
        forward = UIBarButtonItem(barButtonSystemItem: .fastForward, target: wv, action: #selector(wv.goForward))
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        
        back.isEnabled = false
        forward.isEnabled = false
        
        let toolBarItems = [progressButton, spacer, back!, forward!, refresh]
        toolbar.items = toolBarItems
        wv.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        if let url = URL(string: breed!.BreedHTMLURL) {
            let request = URLRequest(url: url)
            wv.load(request)
            wv.allowsBackForwardNavigationGestures = true
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(wv.estimatedProgress)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async(execute: {
            self.back.isEnabled = self.wv.canGoBack
            self.forward.isEnabled = self.wv.canGoForward
        })
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        if let host = url?.host {
            for website in websites {
                if host.contains(website) {
                    decisionHandler(.allow)
                    return
                }
            }
        }
        
        decisionHandler(.cancel)
    }
}
