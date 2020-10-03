//
//  OnboardingVideoViewController.swift
//  Feline Finder
//
//  Created by gregoryew1 on 3/11/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit

class OnboardingVideoViewController: ZoomAnimationViewController, WKYTPlayerViewDelegate {
    
    var viewDisappeared = false
    
    deinit {
        print("OnboardingVideoViewController deinit")
        videoPlayer?.delegate = nil
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        videoPlayer?.stopVideo()
        presentingViewController?.dismiss(animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        if !Utilities.isNetworkAvailable() {
            Utilities.displayAlert("Feline Finder Requires Internet", errorMessage: "Sorry you need to connect to the internet in order to use this app.  Most functionality will not work without access to the internet.")
        } else {
            let rect = CGRect(x: 0, y: 30, width: self.view.frame.width, height: self.view.frame.height - 30)
            videoPlayer = WKYTPlayerView(frame: rect)
            videoPlayer?.frame = rect
            self.view.addSubview(videoPlayer!)
            
            videoPlayer?.delegate = self
            
            videoPlayer?.load(withVideoId: "2zJO2iQrNe0")
        }
    }
    
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        if !viewDisappeared {
            videoPlayer?.playVideo()
        }
    }
    
    func playerView(_ playerView: WKYTPlayerView, didChangeTo state: WKYTPlayerState) {
        if (state == .ended || state == .paused) {
            videoPlayer?.stopVideo()
            presentingViewController?.dismiss(animated: false, completion: nil)
        }
    }

    func playerView(_ playerView: WKYTPlayerView, receivedError error: WKYTPlayerError) {
        videoPlayer?.stopVideo()
        presentingViewController?.dismiss(animated: false, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        viewDisappeared = true
        videoPlayer?.stopVideo()
        videoPlayer?.removeFromSuperview()
    }
}
