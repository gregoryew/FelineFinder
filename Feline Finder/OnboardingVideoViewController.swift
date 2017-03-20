//
//  OnboardingVideoViewController.swift
//  Feline Finder
//
//  Created by gregoryew1 on 3/11/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit
import TransitionTreasury
import TransitionAnimation

class OnboardingVideoViewController: UIViewController, NavgationTransitionable, WKYTPlayerViewDelegate {
    
    var viewDisappeared = false
    
    deinit {
        print("OnboardingVideoViewController deinit")
        videoPlayer?.delegate = nil
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        videoPlayer?.stopVideo()
        _ = navigationController?.tr_popViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !Utilities.isNetworkAvailable() {
            Utilities.displayAlert("Feline Finder Requires Internet", errorMessage: "Sorry you need to connect to the internet in order to use this app.  Most functionality will not work without access to the internet.")
            _ = navigationController?.tr_popViewController()
        } else {
            let rect = CGRect(x: 0, y: 30, width: self.view.frame.width, height: self.view.frame.height - 30)
            //videoPlayer = WKYTPlayerView(frame: rect)
            videoPlayer?.frame = rect
            self.view.addSubview(videoPlayer!)
            videoPlayer?.load(withVideoId: "_lUl9mp8r2U")
            videoPlayer?.delegate = self
        }
    }
    
    weak var tr_pushTransition: TRNavgationTransitionDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        if !viewDisappeared {
            //videoPlayer.clear()
            videoPlayer?.playVideo()
        }
    }
    
    func playerView(_ playerView: WKYTPlayerView, didChangeTo state: WKYTPlayerState) {
        if state == .ended {
            videoPlayer?.stopVideo()
            _ = navigationController?.tr_popViewController()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        viewDisappeared = true
        videoPlayer?.stopVideo()
        videoPlayer?.removeFromSuperview()
    }
}
