//
//  MainTabBarViewController.swift
//  Feline Finder
//
//  Created by gregoryew1 on 6/26/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//
import UIKit

class MainTabBarControllerViewController: UITabBarController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.tabBarController?.delegate = UIApplication.shared.delegate as? UITabBarControllerDelegate
                
        let breed: Breed = Breed(id: 0, name: "All Breeds", url: "", picture: "", percentMatch: 0, desc: "", fullPict: "", rbID: "", youTubeURL: "", cats101: "", playListID: "");
        globalBreed = breed
    }
    
    /*
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 13.0, *) {
            let statusBar = UIView(frame: view.window?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero)
        } else {
            
        }
        let blurEffect = UIBlurEffect(style: .light) // Set any style you want(.light or .dark) to achieve different effect.
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = statusBar.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        statusBar.addSubview(blurEffectView)
        view.addSubview(statusBar)
    }
    */
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}
