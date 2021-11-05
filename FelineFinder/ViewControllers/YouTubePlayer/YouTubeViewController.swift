//
//  YouTubeViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 12/4/20.
//

import UIKit
import YoutubePlayerView

class YouTubeViewController: ParentViewController, YoutubePlayerViewDelegate {
    
    var youTubeVideoID: String = ""
    
    @IBOutlet weak var YouTubeVideoPlayer: YoutubePlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        YouTubeVideoPlayer.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let playerVars: [String: Any] = [
            "controls": 0,
            "modestbranding": 1,
            "playsinline": 1,
            "showinfo": 0
        ]
        YouTubeVideoPlayer.loadWithVideoId(youTubeVideoID, with: playerVars)
    }
    
    func playerView(_ playerView: YoutubePlayerView, didChangedToState state: YoutubePlayerState) {
        if state == .ended {
            dismiss(animated: false, completion: nil)
        }
    }
    
    func playerViewDidBecomeReady(_ playerView: YoutubePlayerView) {
        YouTubeVideoPlayer.play()
    }
    
    @IBAction func clloseTapped(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
}
