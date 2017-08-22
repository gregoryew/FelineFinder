//
//  MainTabIntoVideoViewController.swift
//  Feline Finder
//
//  Created by gregoryew1 on 8/17/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import UIKit

class MainTabIntoVideoViewController: UIViewController, WKYTPlayerViewDelegate {

    @IBOutlet weak var IntroVideo: WKYTPlayerView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IntroVideo?.load(withVideoId: "E5ArKwFUgJw")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IntroVideo?.stopVideo()
    }
    
    func playerView(_ playerView: WKYTPlayerView, didChangeTo state: WKYTPlayerState) {
        if state == .ended {
            IntroVideo?.load(withVideoId: "E5ArKwFUgJw")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
