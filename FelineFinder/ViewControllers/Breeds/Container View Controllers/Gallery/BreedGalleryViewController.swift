//
//  BreedVideosViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/25/20.
//

import UIKit
import YouTubePlayer

class BreedGalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, YouTubePlayerDelegate {

    let VIDEOSCV = 1
    let PHOTOSCV = 2
    
    var breed: Breed?
    var media: Tools!
    var youTubeVideos = [youTubeTool]()
    var images = [imageTool]()
    
    @IBOutlet weak var videos: UICollectionView!
    @IBOutlet weak var photos: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        media = Tools(breed: self.breed!, sourceView: view, obj: nil)
        media.mode = .media
        
        youTubeVideos = media.youTubeVidoes()
        images = media.images()
        
        videos.delegate = self
        videos.dataSource = self
        videos.tag = VIDEOSCV

        photos.delegate = self
        photos.dataSource = self
        photos.tag = PHOTOSCV
        
        DispatchQueue.main.async {
            self.videos.reloadData()
            self.photos.reloadData()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == VIDEOSCV {
            return youTubeVideos.count
        } else {
            return images.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == VIDEOSCV {
            let cell = self.videos.dequeueReusableCell(withReuseIdentifier: "YouTubeCell", for: indexPath) as! BreedVideoCollectionViewCell
        
            cell.configure(video: youTubeVideos[indexPath.item])
            
            return cell
        } else {
            let cell = self.photos.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! BreedPhotoCollectionViewCell
        
            cell.configure(img: images[indexPath.item])
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == VIDEOSCV {
        } else {
            let details = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AdoptDetail") as! MainTabAdoptableCatsDetailViewController

            details.pet = self.images[indexPath.item].pet
            
            details.modalPresentationStyle = .overFullScreen
            
            //details.transitioningDelegate = self
            
            present(details, animated: true, completion: nil)
        }
    }
    
    /*
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentTool = media[indexPath.item]
        self.YouTubePlayer.playerVars = [
            "playsinline": "1",
            "controls": "0",
            "showinfo": "0"
            ] as YouTubePlayerView.YouTubePlayerParameters
        let theAttributes = collectionView.layoutAttributesForItem(at: indexPath)
        let cellFrameInSuperview = collectionView.convert(theAttributes!.frame, to: collectionView.superview)
        self.YouTubePlayer.frame = cellFrameInSuperview
        self.view.bringSubviewToFront(self.YouTubePlayer)
        self.YouTubePlayer.loadVideoID((currentTool as! youTubeTool).video.videoID)
        YouTubePlayer.isHidden = false
    }
    
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        if playerState == .Ended {
            YouTubePlayer.isHidden = true
        }
    }
    
    func playerReady(_ videoPlayer: YouTubePlayerView) {
        videoPlayer.play()
    }
    */
}

extension BreedGalleryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = view.frame.size.width - (19 * 3)
        if UIDevice.current.userInterfaceIdiom == .pad {
            size /= 6
        } else {
            size /= 2
        }
        return CGSize(width: size, height: size * 1.3)
    }
}

