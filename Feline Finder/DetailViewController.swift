//
//  DetailViewController.swift
//  Feline Finder
//
//  Created by Gregory Williams on 6/4/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import UIKit
import TransitionTreasury
import TransitionAnimation
import WebKit

class DetailViewController: UIViewController, WKNavigationDelegate { //, NavgationTransitionable {
    var webView: WKWebView!
    
    deinit {
        print ("DetailViewController deinit")
        _ = webView?.loadHTMLString("", baseURL: nil)
        webView?.stopLoading()
        //webView.delegate = nil
        webView?.removeFromSuperview()
        webView = nil
    }
    
    func configureView() {
        self.title = globalBreed?.BreedName
        let htmlString = generateDisplay(globalBreed!)
        let path = Bundle.main.bundlePath;
        let sBaseURL = URL(fileURLWithPath: path);
        blurImage(UIImage(named: (globalBreed?.FullSizedPicture)!)!)
        
        
        let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let userScript = WKUserScript(source: jscript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let wkUController = WKUserContentController()
        wkUController.addUserScript(userScript)
        let wkWebConfig = WKWebViewConfiguration()
        wkWebConfig.userContentController = wkUController
        self.webView = WKWebView(frame: CGRect(x: 0, y: (self.navigationController?.navigationBar.frame.size.height)!, width: self.view.frame.width, height: self.view.frame.height - (self.navigationController?.navigationBar.frame.size.height)!), configuration: wkWebConfig)
        //self.webView = WKWebView()
        self.webView!.isOpaque = false
        self.webView!.backgroundColor = UIColor.clear
        self.webView!.scrollView.backgroundColor = UIColor.clear
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.webView.loadHTMLString(htmlString as String, baseURL: sBaseURL)
        self.view.addSubview(self.webView!)
        self.webView?.navigationDelegate = self
    }
    
    func generateDisplay(_ b: Breed) -> String {
        var desc = b.Description
        desc = desc.replacingOccurrences(of: "\n", with: "<br/>", options: NSString.CompareOptions.literal, range: nil)
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            return "<!DOCTYPE html><html><header><style>a {color: white} h1 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:22px;} h2 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:18px;} h3 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:12px;} h4 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:10px;} h5 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:8px;} div { width: 100%; height: 425px; border: thin solid black; overflow-x: scroll; overflow-y: scroll;} </style></header><body><br/><center><iframe allowtransparency=\"true\" width=\"100%\" height=\"400\" src=\"https://www.youtube.com/embed/\(b.YouTubeURL)?autoplay=1\" frameborder=\"0\" autoplay=\"auto6yplay\"></iframe></center><br/><h3>You can watch the YouTube video above and also watch the Cats 101 AnimalPlanet video link for <a href=\"\(b.cats101VideoURL)\">\(b.BreedName)</a></h3><h1>DESCRIPTION</h1><div><h3>\(desc)</h3></div></body></html>"
        } else {
            return "<!DOCTYPE html><html><header><style>a {color: white} h1 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:20px; height: 2px; margin-bottom: 0px; } h2 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:18px; height: 2px; margin-bottom: 0px; } h3 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:12px;} h4 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:10px;} h5 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:8px;}</style></header><body><br/><center><iframe allowtransparency=\"true\" width=\"100%\" height=\"200\" src=\"https://www.youtube.com/embed/\(b.YouTubeURL)?autoplay=1\" frameborder=\"0\" autoplay=\"autoplay\" webkit-playsinline></iframe></center><br/><h3>You can watch the YouTube video above and also watch the Cats 101 AnimalPlanet video link for <a href=\"\(b.cats101VideoURL)\">\(b.BreedName)</a></h3><h1>DESCRIPTION</h1><br/><h3>\(desc)</h3></body></html>"
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if !url.absoluteString.hasPrefix("file:") && !url.absoluteString.hasPrefix("https://www.youtube.com/embed/")  && !url.absoluteString.hasPrefix("about:blank") {
                UIApplication.shared.openURL(url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }  
    }
    
    func blurImage(_ image2: UIImage) {
        let imageView = UIImageView(image: image2)
        imageView.frame = view.bounds
        imageView.contentMode = .scaleToFill
        
        view.addSubview(imageView)
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = imageView.bounds
        view.addSubview(blurredEffectView)
        
        self.view.sendSubview(toBack: blurredEffectView)
        self.view.sendSubview(toBack: imageView)
    }

    override func viewDidDisappear(_ animated: Bool) {
        webView.loadHTMLString("", baseURL: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func webViewDidStartLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func didFailLoadWithError(_ webView: UIWebView, error:NSError) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.configureView()
        self.tabBarController?.navigationItem.title = globalBreed?.BreedName
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
    }
    
    //weak var tr_pushTransition: TRNavgationTransitionDelegate?
}
