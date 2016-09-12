//
//  DetailViewController.swift
//  Feline Finder
//
//  Created by Gregory Williams on 6/4/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    var breed: Breed?

    func configureView() {
        let b = self.breed as Breed?
        self.title = b!.BreedName
        let htmlString = generateDisplay(b!)
        let path = NSBundle.mainBundle().bundlePath;
        let sBaseURL = NSURL.fileURLWithPath(path);
        blurImage(UIImage(named: (b?.FullSizedPicture)!)!)
        self.webView.loadHTMLString(htmlString as String, baseURL: sBaseURL)
    }
    
    
    func generateDisplay(b: Breed) -> String {
        var desc = b.Description.stringByReplacingOccurrencesOfString("References", withString: "</h5><h4>References", options: NSStringCompareOptions.LiteralSearch, range: nil)
        desc = desc.stringByReplacingOccurrencesOfString("\n", withString: "<br/>", options: NSStringCompareOptions.LiteralSearch, range: nil)
        desc = desc.stringByReplacingOccurrencesOfString("\n", withString: "<br/>", options: NSStringCompareOptions.LiteralSearch, range: nil)
        return "<!DOCTYPE html><html><header><style>h1 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:18px;} h2 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:18px;} h3 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:22px;} h4 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:10px;} h5 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:16px;} </style></header><body><br/><center><img src=\"\(b.FullSizedPicture)\" style=\"box-shadow:10px 10px 5px black\" width=\"250\"></center><br/><h1>DESCRIPTION<h1><h5>\(desc)</h4></body></html>"
    }

    func blurImage(image2: UIImage) {
        let imageView = UIImageView(image: image2)
        imageView.frame = view.bounds
        imageView.contentMode = .ScaleToFill
        
        view.addSubview(imageView)
        
        let blurEffect = UIBlurEffect(style: .Dark)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = imageView.bounds
        view.addSubview(blurredEffectView)
        
        self.view.sendSubviewToBack(blurredEffectView)
        self.view.sendSubviewToBack(imageView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        self.webView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func webViewDidStartLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func didFailLoadWithError(webView: UIWebView, error:NSError) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated:true);
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated:true);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "BreedStats" {
            let b = self.breed as Breed?
            (segue.destinationViewController as! BreedStatsViewController).breed = b!
        }
        else if (segue.identifier == "petFinder") {
            let b = self.breed as Breed?
            (segue.destinationViewController as! PetFinderViewController).breed = b!
        }
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        }
        return true
    }
}