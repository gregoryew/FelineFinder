//
//  BreedInfoGalleryViewController.swift
//  Feline Finder
//
//  Created by gregoryew1 on 7/16/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import UIKit
import TransitionTreasury
import TransitionAnimation

class BreedInfoGalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ModalTransitionDelegate {
    
    @IBOutlet var youTubeVideosList: UICollectionView!
    @IBOutlet var photoGalleryCollectionView: UICollectionView!

    @IBOutlet var videosCountLabel: UILabel!
    
    weak var tr_presentTransition: TRViewControllerTransitionDelegate?
    
    var youTubeVideos: [YouTubeVideo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        //let width = UIScreen.main.bounds.width
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.itemSize = CGSize(width: 120, height: youTubeVideosList.bounds.height)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 10
        youTubeVideosList!.collectionViewLayout = layout
        
        if globalBreed?.YouTubeVideos.count == 0 {
        
            YouTubeAPI().getYouTubeVideos(playList: (globalBreed?.YouTubePlayListID)!, completion: {(ytl, error) -> Void in
                self.youTubeVideos = ytl
                globalBreed?.YouTubeVideos = ytl
            
                DispatchQueue.main.async { [unowned self] in
                self.youTubeVideosList?.reloadData()
                }
            })
        } else {
            youTubeVideos = (globalBreed?.YouTubeVideos)!
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == youTubeVideosList {
            return 1
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == youTubeVideosList {
            videosCountLabel.text = "Video (\(youTubeVideos.count) Videos)"
            return youTubeVideos.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == youTubeVideosList {
            let cell = youTubeVideosList.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! YouTubeCollectionViewCell
        
            let imgURL = URL(string: youTubeVideos[indexPath.row].pictureURL)
            cell.YouTubePicture.sd_setImage(with: imgURL, placeholderImage: UIImage(named: "NoCatImage"))
        
            return cell
        } else {
            let cell = youTubeVideosList.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! BreedInfoGalleryPhotoCollectionViewCell2
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if collectionView == youTubeVideosList {
            if youTubeVideos.count == 0 {
                return
            }
    
            let youTube = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "YouTube") as! YouTubeViewController
    
            youTube.youtubeid = youTubeVideos[indexPath.row].videoID
    
            youTube.modalDelegate = self
            tr_presentViewController(youTube, method: DemoPresent.CIZoom(transImage: .cat), completion: {
                print("Present finished.")
            })
        } else {
            
        }
    }
}
