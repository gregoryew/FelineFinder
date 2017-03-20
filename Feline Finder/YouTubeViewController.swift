//
//  YouTubeViewController.swift
//  Feline Finder
//
//  Created by Gregory Williams on 9/3/16.
//  Copyright © 2016 Gregory Williams. All rights reserved.
//

import Foundation
import YouTubePlayer
import UIKit
import TransitionTreasury
import TransitionAnimation


class YouTubeViewController: UIViewController, WKYTPlayerViewDelegate, NavgationTransitionable {
    var youtubeid: String?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var viewDisappeared = false
    
    deinit {
        print("YouTubeViewController deinit")
        videoPlayer?.delegate = nil
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        videoPlayer?.stopVideo()
        _ = navigationController?.tr_popViewController()
    }
    
    weak var tr_pushTransition: TRNavgationTransitionDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //let h = self.navigationController!.navigationBar.frame.height
        //let r = CGRectMake(0, h, self.view.bounds.width, self.view.bounds.height - h)
        
        let rect = CGRect(x: 0, y: 30, width: self.view.frame.width, height: self.view.frame.height - 30)
        //videoPlayer = WKYTPlayerView(frame: rect)
        videoPlayer?.frame = rect
        self.view.addSubview(videoPlayer!)
        videoPlayer?.load(withVideoId: youtubeid!)
        videoPlayer?.delegate = self
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
