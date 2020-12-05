//
//  YouTubeViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 12/4/20.
//

import UIKit
import YouTubePlayer

class YouTubeViewController: UIViewController, YouTubePlayerDelegate {
    
    var youTubeVideoID: String = ""
    
    @IBOutlet weak var YouTubeVideoPlayer: YouTubePlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        YouTubeVideoPlayer.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.YouTubeVideoPlayer.playerVars = [
            "playsinline": "1",
            "controls": "0",
            "showinfo": "0"
            ] as YouTubePlayerView.YouTubePlayerParameters
        YouTubeVideoPlayer.loadVideoID(youTubeVideoID)
    }
    
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        if playerState == .Ended {
            dismiss(animated: false, completion: nil)
        }
    }
    
    func playerReady(_ videoPlayer: YouTubePlayerView) {
        videoPlayer.play()
    }
    
    @IBAction func clloseTapped(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
}
