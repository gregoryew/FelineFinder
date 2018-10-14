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


class YouTubeViewController: UIViewController, WKYTPlayerViewDelegate {
    var youtubeid: String?

    weak var tr_presentTransition: TRViewControllerTransitionDelegate?
    weak var modalDelegate: ModalViewControllerDelegate?
    
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
        modalDelegate?.modalViewControllerDismiss(callbackData: nil)
    }
    
    weak var tr_pushTransition: TRNavgationTransitionDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //let h = self.navigationController!.navigationBar.frame.height
        //let r = CGRectMake(0, h, self.view.bounds.width, self.view.bounds.height - h)
        
        let rect = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        //videoPlayer = WKYTPlayerView(frame: rect)
        videoPlayer?.frame = rect
        self.view.addSubview(videoPlayer!)
        videoPlayer?.load(withVideoId: youtubeid!, playerVars: ["origin": "http://www.youtube.com"])
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
        if state == .ended || state == .paused {
            videoPlayer?.stopVideo()
            modalDelegate?.modalViewControllerDismiss(callbackData: nil)
        }
    }
    
    func playerView(_ playerView: WKYTPlayerView, receivedError error: WKYTPlayerError) {        videoPlayer?.stopVideo()
        modalDelegate?.modalViewControllerDismiss(callbackData: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
         viewDisappeared = true
        videoPlayer?.stopVideo()
        videoPlayer?.removeFromSuperview()
    }
}
