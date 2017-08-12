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
    @IBOutlet var picturesCountLabel: UILabel!
    
    weak var tr_presentTransition: TRViewControllerTransitionDelegate?
    
    var youTubeVideos: [YouTubeVideo] = []
    var pictures: [breedPicture] = []
    
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
        
        
        let layout2: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        //let width = UIScreen.main.bounds.width
        layout2.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout2.itemSize = CGSize(width: 100, height: 95)
        layout2.minimumInteritemSpacing = 0
        layout2.minimumLineSpacing = 10
        photoGalleryCollectionView!.collectionViewLayout = layout2
        if globalBreed?.Picture.count == 0 {
            BreedInfoGalleryPhotoAPI().loadPhotos(bn: globalBreed!, completion: { (pics) in
            self.pictures = pics
            globalBreed?.Picture = pics
            DispatchQueue.main.async { [unowned self] in
                self.photoGalleryCollectionView?.reloadData()
            }
            })
        } else {
            self.pictures = (globalBreed?.Picture)!
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
            picturesCountLabel.text = "Photo (\(pictures.count) Photos)"
            return self.pictures.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == youTubeVideosList {
            let cell = youTubeVideosList.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! YouTubeCollectionViewCell
        
            let imgURL = URL(string: youTubeVideos[indexPath.row].pictureURL)
            cell.YouTubePicture.sd_setImage(with: imgURL, placeholderImage: UIImage(named: "NoCatImage"))
        
            return cell
        } else {
            let cell2 = photoGalleryCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell2", for: indexPath) as! BreedInfoGalleryPhotoCollectionViewCell2

            let imgURL = URL(string: pictures[indexPath.row].PictureURL)
            cell2.Photo.sd_setImage(with: imgURL, placeholderImage: UIImage(named: "NoCatImage"))

            return cell2
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
            if pictures.count == 0 {
                return
            }
            let FelineDetail = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AdoptableCatsDetail") as! CatDetailViewController
            FelineDetail.petID = pictures[indexPath.row].PetID
            FelineDetail.petName = pictures[indexPath.row].Name
            FelineDetail.breedName = globalBreed!.BreedName
            FelineDetail.modalDelegate = self // Don't forget to set modalDelegate
            tr_presentViewController(FelineDetail, method: DemoPresent.CIZoom(transImage: .cat), completion: {
                print("Present finished.")
            })
        }
    }
}
