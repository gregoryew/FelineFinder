//
//  MainTabAdoptableCatsMainTVCell.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/3/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

/*
import Foundation
import SDWebImage
import YouTubePlayer

var selectedBreedImages = [Int](repeating: 0, count: 66)

class MainTabBreedTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, CAAnimationDelegate, YouTubePlayerDelegate {
    
    @IBOutlet weak var MainCatImage: UIImageView!
    @IBOutlet weak var SubCatCV: UICollectionView!
    @IBOutlet weak var BreedNameLabel: UILabel!
    @IBOutlet weak var YouTubeVideo: YouTubePlayerView!
    
    private var breedData: Breed!
    private var tools: Tools!
    private var media = [Tool]()
    private var mediaCount = 0
    
    var CGWidths = [CGFloat]()
    
    var observer : Any!
    
    func configure(breed: Breed?, sourceView: UIView) {
        if let b = breed {
                        
            self.breedData = b

            tools = Tools(breed: b, sourceView: sourceView, obj: self)
                        
            media = []
            media.append(contentsOf: tools.images())
            media.append(contentsOf: tools.youTubeVidoes())
            
            mediaCount = tools.images().count + tools.youTubeVidoes().count
            setup()
                                                
            YouTubeVideo.delegate = self
            
            //let urlString: String? = breedData.FullSizedPicture
            
            BreedNameLabel.text = breedData.BreedName
            
            //if urlString == "" {
            //    MainCatImage?.image = UIImage(named: "NoCatImage")
            //} else {
                //let urlString2 = urlString!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "" //This will fill the spaces with the %20
                //let imgURL = URL(string: urlString2)
                //MainCatImage.sd_setImage(with: imgURL, placeholderImage: UIImage(named: "NoCatImage"))
            //}
            
            MainCatImage.image = UIImage(named: breedData.FullSizedPicture)
            
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(curlLeftAnimation))
            gesture.direction = .right
            MainCatImage.addGestureRecognizer(gesture)

            let gesture2 = UISwipeGestureRecognizer(target: self, action: #selector(curlRightAnimation))
            gesture2.direction = .left
            MainCatImage.addGestureRecognizer(gesture2)
            
            MainCatImage.layer.borderWidth = 6
            MainCatImage.layer.borderColor = UIColor(red: 0.5, green: 0.47, blue: 0.25, alpha: 1.0).cgColor
        }
    }
    
    func setup() {
        SubCatCV.dataSource = self
        SubCatCV.delegate = self
                
        SubCatCV!.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                         
        self.CGWidths = []
        var ratio: CGFloat = 0
        var w2: CGFloat = 0
        
        for tool in self.tools {
            switch tool.cellType {
            case .image:
                ratio = 100 / CGFloat((tool as! imageTool).thumbNail.height)
                w2 = CGFloat((tool as! imageTool).thumbNail.width) * ratio
            case .video:
                w2 = 133
            case .tool:
                w2 = 70
            }
            self.CGWidths.append(w2)
        }
        
        //let layout = self.SubCatCV.collectionViewLayout as! HorizontalLayoutVaryingWidths
        let layout = HorizontalLayoutVaryingWidths()
        layout.delegate = self
        layout.numberOfRows = 1
        layout.cellPadding = 2.5
        self.SubCatCV.collectionViewLayout = layout
            
            /*
            if self.tools.mode == .media {
                var totalWidth = 0
                for i in 0..<self.media.count {
                    var w = 0
                    if self.media[i].cellType == .image {
                        w = (self.media[i] as! imageTool).photo.width
                    } else {
                        w = 133
                    }
                    totalWidth += w
                }
                //self.SubCatCV.frame = CGRect(x: -totalWidth, y: Int(self.SubCatCV.frame.minY), width: totalWidth, height: 100)
            } else {
                //self.SubCatCV.frame = CGRect(x: -self.tools.count() * 100, y: Int(self.SubCatCV.frame.minY), width: self.tools.count() * 100, height: 100)
            }
            */
            
            /*
            UIView.transition(with: self.SubCatCV, duration: 0.5, options: .curveEaseInOut , animations: {
                self.SubCatCV.frame = CGRect(x: 10, y: Int(self.SubCatCV.frame.minY), width: Int(self.SubCatCV.frame.width), height: 100)
            */
            //}, completion: nil)
            
        
        DispatchQueue.main.async(execute: {
            self.SubCatCV.reloadData()
            selectedBreedImages[self.tag] = 1
            let indexPathForFirstRow = IndexPath(row: selectedBreedImages[self.tag], section: 0)
            self.SubCatCV.selectItem(at: indexPathForFirstRow, animated: false, scrollPosition: UICollectionView.ScrollPosition.left)
            self.SubCatCV.layoutIfNeeded()
       })
    }

    override func prepareForReuse() {
        super .prepareForReuse()
        self.backgroundColor = UIColor.clear
        self.MainCatImage.backgroundColor = UIColor.clear
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tools.count()
    }
        
    @objc func curlRightAnimation(_ gesture: UISwipeGestureRecognizer)
    {
        print("PAGE CURL RIGHT")
        
        if selectedBreedImages[tag] == media.count {
            Animations.requireUserAtencion(on: self.MainCatImage)
            return
        }
        
        QuartzCore.CATransaction.begin() //Begin the CATransaction

        QuartzCore.CATransaction.setAnimationDuration(0.7)
        QuartzCore.CATransaction.setCompletionBlock {
        }

        MainCatImage.layer.pageCURL(duration: 0.7, direction: CATransitionSubtype.fromRight)

        selectedBreedImages[tag] += 1
        
        var newImgURL: URL?
        if media[selectedBreedImages[tag] - 1].cellType == .image {
            newImgURL = URL(string: (media[selectedBreedImages[tag] - 1] as! imageTool).photo.URL)
        } else {
            newImgURL = URL(string: (media[selectedBreedImages[tag] - 1] as! youTubeTool).video.urlThumbnail)
        }
        
        self.MainCatImage.sd_setImage(with: newImgURL, placeholderImage: UIImage(named: "NoCatImage"), options: SDWebImageOptions.highPriority) { (img, err, _, _) in
            CATransaction.commit()
            self.SubCatCV.selectItem(at: IndexPath(item: selectedBreedImages[self.tag], section: 0), animated: true, scrollPosition: .centeredHorizontally)
        }
        
    }

    @objc func curlLeftAnimation(_ gesture: UISwipeGestureRecognizer)
    {
        print("PAGE CURL LEFT")
        
        if selectedBreedImages[tag] == 1 {
            Animations.requireUserAtencion(on: self.MainCatImage)
            return
        }
        
        QuartzCore.CATransaction.begin() //Begin the CATransaction

        QuartzCore.CATransaction.setAnimationDuration(0.7)
        QuartzCore.CATransaction.setCompletionBlock {
        }

        MainCatImage.layer.pageCURL(duration: 0.7, direction: CATransitionSubtype.fromLeft)

        selectedBreedImages[tag] -= 1
        
        var newImgURL: URL?
        if media[selectedBreedImages[tag]].cellType == .image {
            newImgURL = URL(string: (media[selectedBreedImages[tag] - 1] as! imageTool).photo.URL)
        } else {
            newImgURL = URL(string: (media[selectedBreedImages[tag] - 1] as! youTubeTool).video.urlThumbnail)
        }

        self.MainCatImage.sd_setImage(with: newImgURL, placeholderImage: UIImage(named: "NoCatImage"), options: SDWebImageOptions.highPriority) { (img, err, _, _) in
            CATransaction.commit()
            self.SubCatCV.selectItem(at: IndexPath(item: selectedBreedImages[self.tag], section: 0), animated: true, scrollPosition: .centeredHorizontally)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item >= tools.count() {
            let cell = SubCatCV.dequeueReusableCell(withReuseIdentifier: "subCell", for: indexPath) as! MainTabAdoptableCatsSubCVCell
            return cell
        }
        switch tools[indexPath.row].cellType {
        case .image:
            let cell = SubCatCV.dequeueReusableCell(withReuseIdentifier: "subCell", for: indexPath) as! MainTabBreedCollectionViewCell
            if indexPath.item >= tools.count() {
                return cell
            }
            cell.tag = indexPath.item
            let imgURL = URL(string: (tools[indexPath.item] as! imageTool).thumbNail.URL)
            cell.prepareForReuse()
            cell.configure(imgURL: imgURL!, isSelected: selectedBreedImages[tag] == indexPath.row)
            self.layoutIfNeeded()
            self.SubCatCV.setNeedsDisplay()
            return cell
        case .video:
            let cell = SubCatCV.dequeueReusableCell(withReuseIdentifier: "subCell", for: indexPath) as! MainTabBreedCollectionViewCell
            if indexPath.item >= tools.count() {
                return cell
            }
            cell.tag = indexPath.item
            let imgURL = URL(string: (tools[indexPath.item] as! youTubeTool).video.urlThumbnail)
            cell.prepareForReuse()
            cell.configure(imgURL: imgURL!, isSelected: selectedBreedImages[tag] == indexPath.row)
            self.layoutIfNeeded()
            self.SubCatCV.setNeedsDisplay()
            return cell
        case .tool:
            let cell = SubCatCV.dequeueReusableCell(withReuseIdentifier: "toolCell", for: indexPath) as! MainTabBreedToolCollectionViewCell
            if indexPath.item >= tools.count() {
                return cell
            }
            cell.tag = indexPath.item
            cell.prepareForReuse()
            cell.configure(tool: tools[indexPath.item])
            self.layoutIfNeeded()
            self.SubCatCV.setNeedsDisplay()
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let currentTool = tools[indexPath.item]
        
        if currentTool.cellType == .image || currentTool.cellType == .video {
            
            let thumbNail: URL?
            let photo: URL?
            let oldImgURL: String?
            
            if currentTool.cellType == .image {
                thumbNail = URL(string: (currentTool as! imageTool).thumbNail.URL)
                photo = URL(string: (currentTool as! imageTool).photo.URL)
                oldImgURL = (tools[indexPath.item] as! imageTool).thumbNail.URL
            } else {
                thumbNail = URL(string: (currentTool as! youTubeTool).video.urlThumbnail)
                photo = URL(string: (currentTool as! youTubeTool).video.urlThumbnail)
                oldImgURL = (tools[indexPath.item] as! youTubeTool).video.urlThumbnail
            }

            let cell = SubCatCV.dequeueReusableCell(withReuseIdentifier: "subCell", for: indexPath) as! MainTabBreedCollectionViewCell
        
            cell.subCatImage.sd_setImage(with: thumbNail) { (img, err, _, url) in
            }
        
            if currentTool.cellType == .video {
                self.YouTubeVideo.playerVars = [
                    "playsinline": "1",
                    "controls": "0",
                    "showinfo": "0"
                    ] as YouTubePlayerView.YouTubePlayerParameters
                self.YouTubeVideo.loadVideoID((currentTool as! youTubeTool).video.videoID)
                YouTubeVideo.isHidden = false
                YouTubeVideo.tag = tag
                (self.findViewController() as? MainTabBreedViewController)?.currentlyPlayingYouTubeVideoView = YouTubeVideo
            } else {
                YouTubeVideo.stop()
                YouTubeVideo.isHidden = true
            }
            
            if indexPath.item - selectedBreedImages[tag] > 0 {
                animateImageView(newImgURL: photo, oldImgURL: oldImgURL!, direction: .fromRight)
            } else if indexPath.item - selectedBreedImages[tag] < 0 {
                animateImageView(newImgURL: photo, oldImgURL: oldImgURL!, direction: .fromLeft)
            } else {
                return
            }
        } else {
            print("ACTION = \(currentTool.icon)")
            currentTool.performAction()
        }
        if indexPath.row == 0 {
            selectedBreedImages[tag] = 1
        } else {
            selectedBreedImages[tag] = indexPath.item
        }
    }

    func animateImageView(newImgURL: URL?, oldImgURL: String, direction: CATransitionSubtype) {
        QuartzCore.CATransaction.begin() //Begin the CATransaction

        QuartzCore.CATransaction.setAnimationDuration(0.25)
        QuartzCore.CATransaction.setCompletionBlock {
        }

        let transition = CATransition()
        transition.type = CATransitionType.moveIn
        transition.subtype = direction

        MainCatImage.layer.add(transition, forKey: kCATransition)
        self.MainCatImage.sd_setImage(with: newImgURL, placeholderImage: UIImage(named: oldImgURL), options: SDWebImageOptions.highPriority) { (img, err, _, _) in
            CATransaction.commit()
        }
    }
}

extension MainTabBreedTableViewCell: HorizontalLayoutVaryingWidthsLayoutDelegate {
  func collectionView(
      _ collectionView: UICollectionView,
    widthForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
    if indexPath.item >= CGWidths.count {
        return 0
    } else {
        return CGWidths[indexPath.item]
    }
  }
}
 */
