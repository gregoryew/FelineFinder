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
import SwiftLocation
import CoreLocation

class BreedInfoGalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ModalTransitionDelegate {
    
    @IBOutlet var youTubeVideosList: UICollectionView!
    @IBOutlet var photoGalleryCollectionView: UICollectionView!

    @IBOutlet var videosCountLabel: UILabel!
    @IBOutlet var picturesCountLabel: UILabel!
    
    weak var tr_presentTransition: TRViewControllerTransitionDelegate?
    
    var youTubePlayList: YouTubeVideos = []
    var pictures: [breedPicture] = []
    var observer : Any!
    
    typealias YouTubeVideos = [YouTubeVideo]
    typealias BreedPictures = [breedPicture]
    
    deinit {
        NotificationCenter.default.removeObserver(observer)
        print("deinit BreedInfoGalleryViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.itemSize = CGSize(width: 100, height: 95)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 10
        self.photoGalleryCollectionView!.collectionViewLayout = layout
        
        let layout2: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout2.scrollDirection = .horizontal
        layout2.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout2.itemSize = CGSize(width: 120, height: self.youTubeVideosList.bounds.height)
        layout2.minimumInteritemSpacing = 0
        layout2.minimumLineSpacing = 10
        self.youTubeVideosList!.collectionViewLayout = layout2
        
        let nc = NotificationCenter.default
        observer = nc.addObserver(forName:youTubePlayListLoadedMessage, object:nil, queue:nil) { [weak self] notification in
            self?.youTubeLoaded(notification: notification)
        }

        observer = nc.addObserver(forName:breedPicturesLoadedMessage, object:nil, queue:nil) { [weak self] notification in
            self?.picturesLoaded(notification: notification)
        }
        
        DownloadManager.loadYouTubePlayList(playListID: (globalBreed?.YouTubePlayListID)!)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if zipCodeGlobal == "" {
            getZipCode()
        } else {
            DownloadManager.loadPetPictures(breed: globalBreed!)
        }
    }
    
    func youTubeLoaded(notification:Notification) -> Void {
        print("youTbueLoaded notification")
        
        guard let userInfo = notification.userInfo,
            let youTube = userInfo["playList"] as? YouTubeVideos
            else {
                print("No youtubeapi userInfo found in notification")
                return
        }
        
        self.youTubePlayList = youTube
        
        DispatchQueue.main.async { [unowned self] in
            self.youTubeVideosList?.reloadData()
        }
    }
    
    func picturesLoaded(notification:Notification) -> Void {
        print("pictureLoaded notification")
        
        guard let userInfo = notification.userInfo,
            let pics = userInfo["breedPictures"] as? BreedPictures
            else {
                print("No BreedPictuers userInfo found in notification")
                return
        }
        
        self.pictures = pics
        
        DispatchQueue.main.async { [unowned self] in
            self.photoGalleryCollectionView?.reloadData()
        }
    }
    
    func getZipCode() {
        let keyStore = NSUbiquitousKeyValueStore()
        zipCode = keyStore.string(forKey: "zipCode") ?? ""
        if zipCode != "" {
            self.setFilterDisplay()
            self.pets?.loading = true
            DownloadManager.loadPetList()
            self.setupReloadAndScroll()
            return
        }
        
        LocationManager2.sharedInstance.getCurrentReverseGeoCodedLocation { (location:CLLocation?, placemark:CLPlacemark?, error:NSError?) in
            if error != nil {
                self.askForZipCode()
                return
            }
            
            guard let _ = location else {
                return
            }
            
            zipCode = placemark?.postalCode ?? "19106"
            zipCodeGlobal = zipCode
            DownloadManager.loadPetPictures(breed: globalBreed!)
            print("Found \(placemark?.postalCode ?? "")")
        }
    }
    
    func askForZipCode() {
        let alert2 = UIAlertController(title: "Please Enter Zip Code", message: "Please enter a zip code for the area you want to search?", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert2.addTextField { (textField) in
            textField.text = ""
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (btn) in
            let textField = alert2.textFields![0] // Force unwrapping because we know it exists.
            zipCode = (textField.text)!
            zipCodeGlobal = zipCode
            let keyStore = NSUbiquitousKeyValueStore()
            keyStore.set(zipCode, forKey: "zipCode")
            if DatabaseManager.sharedInstance.validateZipCode(zipCode: zipCode) {
                DownloadManager.loadPetPictures(breed: globalBreed!)
            } else {
                let alert3 = UIAlertController(title: "Error", message: "You have not allowed Feline Finder to know where you are located so it cannot find cats which are closest to you.  The zip code has been set to the middle of the US population.  Zip code 66952.  You can change it from the find screen.  You can allow the app to use location services again by fliping the switch for Feline Finder in the iOS app system preferences.", preferredStyle: .alert)
                alert3.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert3, animated: true, completion: nil)
                zipCode = "66952"
                zipCodeGlobal = zipCode
                DownloadManager.loadPetPictures(breed: globalBreed!)
            }
        }))
        
        // 4. Present the alert.
        self.present(alert2, animated: true, completion: nil)
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
            videosCountLabel.text = "Video (\(youTubePlayList.count) Videos)"
            return youTubePlayList.count
        } else {
            picturesCountLabel.text = "Photo (\(pictures.count) Photos)"
            return self.pictures.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == youTubeVideosList {
            let cell = youTubeVideosList.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! YouTubeCollectionViewCell
        
            let imgURL = URL(string: youTubePlayList[indexPath.row].pictureURL)
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
            if youTubePlayList.count == 0 {
                return
            }
    
            let youTube = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "YouTube") as! YouTubeViewController
    
            youTube.youtubeid = youTubePlayList[indexPath.row].videoID
    
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
