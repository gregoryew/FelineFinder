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

class DetailViewController: UIViewController, UIWebViewDelegate, NavgationTransitionable {

    @IBOutlet weak var webView: UIWebView!
    
    //var breed: Breed?
    
    /*
    @IBAction func BreedStatsTapped(_ sender: Any) {
        let breedStats = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "breedStats") as! BreedStatsViewController
        breedStats.breed = globalBreed!
        navigationController?.tr_pushViewController(breedStats, method: DemoTransition.Slide(direction: DIRECTION.right))
    }
    
    @IBAction func AdoptACatTapped(_ sender: Any) {
        let adoptACat = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "adoptACat") as! AdoptableCatsViewController
        navigationController?.tr_pushViewController(adoptACat, method: DemoTransition.Slide(direction: DIRECTION.right))
    }
    
    @IBAction func goBack(_ sender: Any) {
        _ = navigationController?.tr_popToRootViewController()
    }
    */
    
    func configureView() {
        self.title = globalBreed?.BreedName
        let htmlString = generateDisplay(globalBreed!)
        let path = Bundle.main.bundlePath;
        let sBaseURL = URL(fileURLWithPath: path);
        blurImage(UIImage(named: (globalBreed?.FullSizedPicture)!)!)
        self.webView.loadHTMLString(htmlString as String, baseURL: sBaseURL)
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
        self.webView.allowsInlineMediaPlayback = true
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
        //self.navigationController?.setToolbarHidden(false, animated:false)
        self.configureView()
        self.webView.delegate = self
        self.webView.allowsInlineMediaPlayback = true
        self.tabBarController?.navigationItem.title = globalBreed?.BreedName
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
    }
    
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BreedStats" {
            let b = self.breed as Breed?
            (segue.destination as! BreedStatsViewController).breed = b!
        }
        //else if (segue.identifier == "petFinder") {
        //    let b = self.breed as Breed?
        //    (segue.destination as! AdoptableCatsViewController).breed = b!
        //}
    }
    */
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.linkClicked {
            UIApplication.shared.openURL(request.url!)
            return false
        } else {
            return true
        }
    }
    
    var tr_pushTransition: TRNavgationTransitionDelegate?
    /*
    @IBAction func back(_ sender: Any) {
        _ = navigationController?.tr_popToRootViewController()
    }
    */
}
