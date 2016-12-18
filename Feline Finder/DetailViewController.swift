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
        let path = Bundle.main.bundlePath;
        let sBaseURL = URL(fileURLWithPath: path);
        blurImage(UIImage(named: (b?.FullSizedPicture)!)!)
        self.webView.loadHTMLString(htmlString as String, baseURL: sBaseURL)
    }
    
    func generateDisplay(_ b: Breed) -> String {
        var desc = b.Description.replacingOccurrences(of: "References", with: "</h5><h4>References", options: NSString.CompareOptions.literal, range: nil)
        desc = desc.replacingOccurrences(of: "\n", with: "<br/>", options: NSString.CompareOptions.literal, range: nil)
        desc = desc.replacingOccurrences(of: "\n", with: "<br/>", options: NSString.CompareOptions.literal, range: nil)
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            //var networkType = RSUtilities.ConnectionType.NONETWORK
            //if (RSUtilities.isNetworkAvailable("google.com")) {
            //    networkType = RSUtilities.networkConnectionType("google.com")
            //}
            //let autoplay = networkType == RSUtilities.ConnectionType.WIFINETWORK ? "autoplay=1&" : ""
            return "<!DOCTYPE html><html><header><style>h1 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:18px;} h2 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:18px;} h3 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:22px;} h4 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:10px;} h5 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:16px;} </style></header><body><br/><center><iframe allowtransparency=\"true\" width=\"100%\" height=\"400\" src=\"https://www.youtube.com/embed/\(b.YouTubeURL)?autoplay=1\" frameborder=\"0\" autoplay=\"autoplay\"></iframe></center><br/><h1>DESCRIPTION<h1><h5>\(desc)</h4></body></html>"
        } else {
            return "<!DOCTYPE html><html><header><style>h1 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:18px;} h2 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:18px;} h3 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:22px;} h4 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:10px;} h5 {color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:16px;} </style></header><body><br/><center><img src=\"\(b.FullSizedPicture)\" style=\"box-shadow:10px 10px 5px black\" width=\"250\"><br/><br/><br/><iframe width=\"280\" height=\"158\" src=\"https://www.youtube.com/embed/\(b.YouTubeURL)?rel=0&amp;showinfo=0\" frameborder=\"0\" allowfullscreen></iframe></center><br/><h1>DESCRIPTION<h1><h5>\(desc)</h4></body></html>"
            
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
        self.navigationController?.setToolbarHidden(false, animated:true);
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated:true);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BreedStats" {
            let b = self.breed as Breed?
            (segue.destination as! BreedStatsViewController).breed = b!
        }
        else if (segue.identifier == "petFinder") {
            let b = self.breed as Breed?
            (segue.destination as! PetFinderViewController).breed = b!
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.linkClicked {
            UIApplication.shared.openURL(request.url!)
            return false
        } else {
            return true
        }
    }
}
