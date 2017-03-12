//
//  OnboardingVideoViewController.swift
//  Feline Finder
//
//  Created by gregoryew1 on 3/11/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import Foundation
import YouTubePlayer
import UIKit
import TransitionTreasury
import TransitionAnimation

class OnboardingVideoViewController: UIViewController, YouTubePlayerDelegate, NavgationTransitionable {

    var youtubeid: String?
    var videoPlayer: YouTubePlayerView?
    var viewDisappeared = false
    
    @IBAction func doneTapped(_ sender: Any) {
        videoPlayer?.stop()
        _ = navigationController?.tr_popViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var tr_pushTransition: TRNavgationTransitionDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let rect = CGRect(x: 0, y: 30, width: self.view.frame.width, height: self.view.frame.height - 30)
        videoPlayer = YouTubePlayerView(frame: rect)
        self.view.addSubview(videoPlayer!)
        videoPlayer?.loadVideoID("_lUl9mp8r2U")
        videoPlayer?.delegate = self
    }
    
    func playerReady(_ videoPlayer: YouTubePlayerView) {
        if !viewDisappeared {
            videoPlayer.play()
        }
    }
    
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        if playerState == YouTubePlayerState.Ended {
            _ = navigationController?.tr_popViewController()
        }
    }
    
    func playerQualityChanged(_ videoPlayer: YouTubePlayerView, playbackQuality: YouTubePlaybackQuality) {
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        viewDisappeared = true
        videoPlayer?.stop()
    }
}
