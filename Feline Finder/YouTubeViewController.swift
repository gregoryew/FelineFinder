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

class YouTubeViewController: UIViewController, YouTubePlayerDelegate {
    var youtubeid: String?
    var videoPlayer: YouTubePlayerView?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //let h = self.navigationController!.navigationBar.frame.height
        //let r = CGRectMake(0, h, self.view.bounds.width, self.view.bounds.height - h)
        videoPlayer = YouTubePlayerView(frame: self.view.frame)
        self.view.addSubview(videoPlayer!)
        videoPlayer?.loadVideoID(youtubeid!)
        videoPlayer?.delegate = self
    }
    
/*
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
*/
 
    func playerReady(_ videoPlayer: YouTubePlayerView) {
        videoPlayer.play()
    }
    
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        if playerState == YouTubePlayerState.Ended {
            performSegue(withIdentifier: "back", sender: nil)
        }
    }
    
    func playerQualityChanged(_ videoPlayer: YouTubePlayerView, playbackQuality: YouTubePlaybackQuality) {
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        videoPlayer?.stop()
    }
}
