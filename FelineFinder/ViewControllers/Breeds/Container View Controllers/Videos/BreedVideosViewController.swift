//
//  BreedVideosViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/25/20.
//

import UIKit

class BreedVideosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var breed: Breed?
    var media: Tools!
    
    @IBOutlet weak var videos: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        media = Tools(breed: self.breed!, sourceView: view, obj: nil)
        media.mode = .media
        
        videos.delegate = self
        videos.dataSource = self

        DispatchQueue.main.async {
            self.videos.reloadData()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return media.youTubeVidoes().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = (self.videos.dequeueReusableCell(withReuseIdentifier: "YouTubeCell", for: indexPath) as! BreedVideoCollectionViewCell)
        
        cell.configure(video: media[indexPath.item] as! youTubeTool)
        
        return cell
    }

}
