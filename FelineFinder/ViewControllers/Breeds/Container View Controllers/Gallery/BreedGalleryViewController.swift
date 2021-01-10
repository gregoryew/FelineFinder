//
//  BreedVideosViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/25/20.
//

import UIKit
import YouTubePlayer

class BreedGalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, YouTubePlayerDelegate {

    var breed: Breed?
    var media: Tools!
    var youTubeVideos = [youTubeTool]()
    
    @IBOutlet weak var videos: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        media = Tools(breed: self.breed!, sourceView: view, obj: nil)
        media.mode = .media
        
        youTubeVideos = media.youTubeVidoes()
        
        videos.delegate = self
        videos.dataSource = self

        DispatchQueue.main.async {
            self.videos.reloadData()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return youTubeVideos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = (self.videos.dequeueReusableCell(withReuseIdentifier: "YouTubeCell", for: indexPath) as? BreedVideoCollectionViewCell) {
            cell.configure(tool: youTubeVideos[indexPath.item])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        youTubeVideos[indexPath.item].performAction()
    }
}

extension BreedGalleryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 100)
    }
}

