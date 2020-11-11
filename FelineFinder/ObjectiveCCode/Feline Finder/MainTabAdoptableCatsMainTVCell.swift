//
//  MainTabAdoptableCatsMainTVCell.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/3/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import Foundation
import FaveButton
import SDWebImage
import URBSegmentedControl
import YouTubePlayer
import SkeletonView

extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}

class MainTabAdoptableCatsMainTVCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, CAAnimationDelegate, YouTubePlayerDelegate {
    
    @IBOutlet weak var MainCatImage: UIImageView!
    @IBOutlet weak var SubCatCV: UICollectionView!
    
    @IBOutlet weak var CatNameLabel: UILabel!
    @IBOutlet weak var BreedNameLabel: UILabel!
    @IBOutlet weak var InfoLabel: UILabel!
    @IBOutlet weak var CityLabel: UILabel!
    @IBOutlet weak var FavoriteButton:
        FaveButton!
    @IBOutlet weak var ToolsChooser: UIView!
    var ToolChooserControl: URBSegmentedControl?
    
    @IBOutlet weak var YouTubeVideo: YouTubePlayerView!
    
    private var petData: Pet!
    private var shelterData: shelter!
    private var tools: Tools!
    private var media = [Tool]()
    
    private var mediaCount = 0
    
    var CGWidths = [CGFloat]()
    
    func configure(pd: Pet?, sh: shelter?, sourceView: UIView) {
        if let p = pd, let s = sh {

            /*
            FavoriteButton.alpha = 1
            CatNameLabel.alpha = 1
            BreedNameLabel.alpha = 1
            CityLabel.alpha = 1
            InfoLabel.alpha = 1
            MainCatImage.alpha = 1
            SubCatCV.alpha = 1
            */
 
            //self.contentView.stopSkeletonAnimation()
            
            var icons = [UIImage]()
            icons.append(UIImage(named: "cat-icon")!)
            icons.append(UIImage(named: "speechBalloon")!)
            ToolChooserControl = URBSegmentedControl.init(icons: icons)

            ToolChooserControl?.segmentViewLayout = .vertical
            ToolChooserControl?.layoutOrientation = .vertical
            ToolChooserControl?.imageEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 0.0);
            ToolChooserControl?.contentEdgeInsets = UIEdgeInsets(top: 5.0, left: 0.0, bottom: 5.0, right: 5.0);

            ToolChooserControl?.frame = ToolsChooser.bounds
            
            ToolChooserControl?.addTarget(self, action: #selector(indexChanged), for: .valueChanged)

            ToolsChooser.addSubview(ToolChooserControl!)

            self.petData = p

            tools = Tools(pet: p, shelter: s, sourceView: sourceView)
            
            media = []
            media.append(contentsOf: tools.images())
            media.append(contentsOf: tools.youTubeVidoes())
            
            mediaCount = tools.images().count + tools.youTubeVidoes().count
            
            setup()
            
            if tools.count() < 2 {
                self.tools.mode = .tools
                setup()
                ToolChooserControl?.selectedSegmentIndex = 1
            }
            
            FavoriteButton.isSelected = Favorites.isFavorite(petData.petID, dataSource: .RescueGroup)
            
            YouTubeVideo.delegate = self
            
            let urlString: String? = petData.getImage(1, size: "pn")
            
            CatNameLabel.text = petData.name + " "
            BreedNameLabel.text = petData.breeds.first! + " "
            CityLabel.attributedText = setEmojicaLabel(text: "\(petData.location != "" ? petData.location + "📍" : "")\(petData.distance) Miles ", size: CityLabel.font.pointSize, fontName: CityLabel.font.fontName)
            var items = [String]()
            if petData.status != "" {items.append(petData.status)}
            if petData.sex != "" {items.append(petData.sex)}
            if petData.age != "" {items.append(petData.age)}
            if petData.size != "" {items.append(petData.size)}
            InfoLabel.attributedText = setEmojicaLabel(text: items.joined(separator: " 🐾 ") + " ", size: InfoLabel.font.pointSize, fontName: InfoLabel.font.fontName)
            
            if urlString == "" {
                MainCatImage?.backgroundColor = getRandomColor()
                MainCatImage?.image = UIImage(named: "NoCatImage")
            } else {
                let urlString2 = urlString!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "" //This will fill the spaces with the %20
                let imgURL = URL(string: urlString2)
                MainCatImage.sd_setImage(with: imgURL, placeholderImage: UIImage(named: "NoCatImage"))
            }
            
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(curlLeftAnimation))
            gesture.direction = .right
            MainCatImage.addGestureRecognizer(gesture)

            let gesture2 = UISwipeGestureRecognizer(target: self, action: #selector(curlRightAnimation))
            gesture2.direction = .left
            MainCatImage.addGestureRecognizer(gesture2)
            
            //MainCatImage.layer.cornerRadius = MainCatImage.frame.size.width * 0.125
            MainCatImage.layer.borderWidth = 6
            MainCatImage.layer.borderColor = UIColor(red: 0.5, green: 0.47, blue: 0.25, alpha: 1.0).cgColor
        } else {
            //self.contentView.showAnimatedGradientSkeleton()
            /*
            FavoriteButton.alpha = 0
            CatNameLabel.alpha = 0
            BreedNameLabel.alpha = 0
            CityLabel.alpha = 0
            InfoLabel.alpha = 0
            MainCatImage.alpha = 0
            SubCatCV.alpha = 0
            */
        }
    }
    
    func setup() {
        SubCatCV.dataSource = self
        SubCatCV.delegate = self
                
        SubCatCV!.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let layout = SubCatCV.collectionViewLayout as! HorizontalLayoutVaryingWidths
        layout.delegate = self
        layout.numberOfRows = 1
        layout.cellPadding = 2.5
        
        CGWidths = []
        var ratio: CGFloat = 0
        var w2: CGFloat = 0
        
        for tool in tools {
            switch tool.cellType {
            case .image:
                ratio = 100 / CGFloat((tool as! imageTool).thumbNail.height)
                w2 = CGFloat((tool as! imageTool).thumbNail.width) * ratio
            case .video:
                w2 = 160
            case .tool:
                w2 = 70
            }
            CGWidths.append(w2)
        }
         
        DispatchQueue.main.async {
            //(self.tools.mode == .media ? .transitionFlipFromBottom : .transitionFlipFromTop)
            if self.tools.mode == .media {
                var totalWidth = 0
                for i in 0..<self.media.count {
                    var w = 0
                    if self.media[i].cellType == .image {
                        w = (self.media[i] as! imageTool).photo.width
                    } else {
                        w = 100
                    }
                    totalWidth += w
                }
                self.SubCatCV.frame = CGRect(x: -totalWidth, y: Int(self.SubCatCV.frame.minY), width: totalWidth, height: 100)
            } else {
                self.SubCatCV.frame = CGRect(x: -self.tools.count() * 100, y: Int(self.SubCatCV.frame.minY), width: self.tools.count() * 100, height: 100)
            }
            
            UIView.transition(with: self.SubCatCV, duration: 0.5, options: .curveEaseInOut , animations: {
                self.SubCatCV.frame = CGRect(x: Int(self.ToolsChooser.frame.width), y: Int(self.SubCatCV.frame.minY), width: Int(self.SubCatCV.frame.width), height: 100)
                self.SubCatCV.reloadData()
            }, completion: nil)
            
            /*
            var totalWidth:CGFloat = 0
            for i in 0..<self.CGWidths.count {
                totalWidth += self.CGWidths[i]
            }
            if totalWidth <
                self.contentView.frame.width {
                self.SubCatCVWidth.constant = totalWidth
                self.SubCatCV.isScrollEnabled = false
            } else {
                self.SubCatCVWidth.constant = self.contentView.frame.width
                self.SubCatCV.isScrollEnabled = true
            }
            */
            selectedImages[self.tag] = 1
            let indexPathForFirstRow = IndexPath(row: selectedImages[self.tag], section: 0)
            self.SubCatCV.selectItem(at: indexPathForFirstRow, animated: false, scrollPosition: UICollectionView.ScrollPosition.left)
            
            self.SubCatCV.layoutIfNeeded()
            
        }
    }
    
    @objc func indexChanged(_ sender: URBSegmentedControl, _ index: Int) {
        if ToolChooserControl?.selectedSegmentIndex == 0 {
            tools.mode = .media
        } else {
            tools.mode = .tools
        }
        setup()
    }
    
    @IBAction func favoriteTapped(_ sender: Any) {
        if FavoriteButton.isSelected {
            Favorites.addFavorite(petData.petID)
        } else {
            Favorites.removeFavorite(petData.petID, dataSource: .RescueGroup)
        }
    }
    
    override func prepareForReuse() {
        super .prepareForReuse()
        self.backgroundColor = UIColor.clear
        self.MainCatImage.backgroundColor = UIColor.clear
        self.ToolChooserControl?.selectedSegmentIndex = 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tools.count()
    }
        
    @objc func curlRightAnimation(_ gesture: UISwipeGestureRecognizer)
    {
        print("PAGE CURL RIGHT")
        
        if selectedImages[tag] == media.count {
            Animations.requireUserAtencion(on: self.MainCatImage)
            return
        }
        
        QuartzCore.CATransaction.begin() //Begin the CATransaction

        QuartzCore.CATransaction.setAnimationDuration(0.7)
        QuartzCore.CATransaction.setCompletionBlock {
        }

        MainCatImage.layer.pageCURL(duration: 0.7, direction: CATransitionSubtype.fromRight)

        selectedImages[tag] += 1
        
        var newImgURL: URL?
        if media[selectedImages[tag] - 1].cellType == .image {
            newImgURL = URL(string: (media[selectedImages[tag] - 1] as! imageTool).photo.URL)
        } else {
            newImgURL = URL(string: (media[selectedImages[tag] - 1] as! youTubeTool).video.urlThumbnail)
        }
        
        self.MainCatImage.sd_setImage(with: newImgURL, placeholderImage: UIImage(named: "NoCatImage"), options: SDWebImageOptions.highPriority) { (img, err, _, _) in
            CATransaction.commit()
            self.SubCatCV.selectItem(at: IndexPath(item: selectedImages[self.tag], section: 0), animated: true, scrollPosition: .centeredHorizontally)
        }
        
    }

    @objc func curlLeftAnimation(_ gesture: UISwipeGestureRecognizer)
    {
        print("PAGE CURL LEFT")
        
        if selectedImages[tag] == 1 {
            Animations.requireUserAtencion(on: self.MainCatImage)
            return
        }
        
        QuartzCore.CATransaction.begin() //Begin the CATransaction

        QuartzCore.CATransaction.setAnimationDuration(0.7)
        QuartzCore.CATransaction.setCompletionBlock {
        }

        MainCatImage.layer.pageCURL(duration: 0.7, direction: CATransitionSubtype.fromLeft)

        selectedImages[tag] -= 1
        
        var newImgURL: URL?
        if media[selectedImages[tag]].cellType == .image {
            newImgURL = URL(string: (media[selectedImages[tag] - 1] as! imageTool).photo.URL)
        } else {
            newImgURL = URL(string: (media[selectedImages[tag] - 1] as! youTubeTool).video.urlThumbnail)
        }

        self.MainCatImage.sd_setImage(with: newImgURL, placeholderImage: UIImage(named: "NoCatImage"), options: SDWebImageOptions.highPriority) { (img, err, _, _) in
            CATransaction.commit()
            self.SubCatCV.selectItem(at: IndexPath(item: selectedImages[self.tag], section: 0), animated: true, scrollPosition: .centeredHorizontally)
        }
    }
    
    func getRandomColor() -> UIColor{
        
        let randomRed:CGFloat = CGFloat(drand48())
        
        let randomGreen:CGFloat = CGFloat(drand48())
        
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item >= tools.count() {
            let cell = SubCatCV.dequeueReusableCell(withReuseIdentifier: "subCell", for: indexPath) as! MainTabAdoptableCatsSubCVCell
            return cell
        }
        switch tools[indexPath.row].cellType {
        case .image:
            let cell = SubCatCV.dequeueReusableCell(withReuseIdentifier: "subCell", for: indexPath) as! MainTabAdoptableCatsSubCVCell
            if indexPath.item >= tools.count() {
                return cell
            }
            cell.tag = indexPath.item
            let imgURL = URL(string: (tools[indexPath.item] as! imageTool).thumbNail.URL)
            cell.prepareForReuse()
            cell.configure(imgURL: imgURL!, isSelected: selectedImages[tag] == indexPath.row)
            self.layoutIfNeeded()
            self.SubCatCV.setNeedsDisplay()
            return cell
        case .video:
            let cell = SubCatCV.dequeueReusableCell(withReuseIdentifier: "subCell", for: indexPath) as! MainTabAdoptableCatsSubCVCell
            if indexPath.item >= tools.count() {
                return cell
            }
            cell.tag = indexPath.item
            let imgURL = URL(string: (tools[indexPath.item] as! youTubeTool).video.urlThumbnail)
            cell.prepareForReuse()
            cell.configure(imgURL: imgURL!, isSelected: selectedImages[tag] == indexPath.row)
            self.layoutIfNeeded()
            self.SubCatCV.setNeedsDisplay()
            return cell
        case .tool:
            let cell = SubCatCV.dequeueReusableCell(withReuseIdentifier: "toolCell", for: indexPath) as! ToolCollectionViewCell
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

            let cell = SubCatCV.dequeueReusableCell(withReuseIdentifier: "subCell", for: indexPath) as! MainTabAdoptableCatsSubCVCell
        
            cell.subCatImage.sd_setImage(with: thumbNail) { (img, err, _, url) in
                /*
                print("cell frame = \(cell.frame) imgs w= \((self.tools[indexPath.item] as! imageTool).thumbNail.width) imgs h= \(self.imgs[indexPath.item].thumbNail.height) url= \(self.imgs[indexPath.item].thumbNail.URL) subimg=\(img!.size) ratio=\(img!.size.width * (100 / img!.size.height)) CGFloat=\(self.CGWidths) indexPath=\(indexPath) imgsCount=\(self.imgs.count) petID=\(self.petData.petID)")
                */
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
                (self.findViewController() as? MainTabAdoptableCats)?.currentlyPlayingYouTubeVideoView = YouTubeVideo
            } else {
                YouTubeVideo.stop()
                YouTubeVideo.isHidden = true
            }
            
            if indexPath.item - selectedImages[tag] > 0 {
                animateImageView(newImgURL: photo, oldImgURL: oldImgURL!, direction: .fromRight)
            } else if indexPath.item - selectedImages[tag] < 0 {
                animateImageView(newImgURL: photo, oldImgURL: oldImgURL!, direction: .fromLeft)
            } else {
                return
            }
        } else {
            print("ACTION = \(currentTool.icon)")
            currentTool.performAction()
        }
        if indexPath.row == 0 {
            selectedImages[tag] = 1
        } else {
            selectedImages[tag] = indexPath.item
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

        /*
        transition.type = CATransitionType.fade
        transition.subtype = CATransitionSubtype.fromRight
        */

        MainCatImage.layer.add(transition, forKey: kCATransition)
        self.MainCatImage.sd_setImage(with: newImgURL, placeholderImage: UIImage(named: oldImgURL), options: SDWebImageOptions.highPriority) { (img, err, _, _) in
            CATransaction.commit()
        }
    }
}

extension MainTabAdoptableCatsMainTVCell: HorizontalLayoutVaryingWidthsLayoutDelegate {
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

extension CALayer {
    
    func bottomAnimation(duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.duration = duration
        animation.type = CATransitionType.push
        animation.subtype = CATransitionSubtype.fromTop
        self.add(animation, forKey: CATransitionType.push.rawValue)
    }
    
    func topAnimation(duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.duration = duration
        animation.type = CATransitionType.push
        animation.subtype = CATransitionSubtype.fromBottom
        self.add(animation, forKey: CATransitionType.push.rawValue)
    }
    
    func pageCURL(duration:CFTimeInterval, direction: CATransitionSubtype) {
            let animation = CATransition()
            animation.duration = duration
            animation.startProgress = 0.0
            animation.endProgress   = 1;
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            //animation.type = CATransitionType(rawValue: "pageCurl")
            animation.type = CATransitionType.moveIn
            animation.subtype = direction
            //animation.isRemovedOnCompletion = true
        //animation.fillMode = CAMediaTimingFillMode.removed
            self.add(animation, forKey: "pageFlipAnimation")
        }
}

class Animations {
    static func requireUserAtencion(on onView: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: onView.center.x - 10, y: onView.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: onView.center.x + 10, y: onView.center.y))
        onView.layer.add(animation, forKey: "position")
    }
}

/*
extension MainTabAdoptableCatsMainTVCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subCell", for: indexPath) as! MainTabAdoptableCatsSubCVCell
        var s = CGSize(width: 50, height: 73)
        if let img = cell.subCatImage.image {
            let ratio = 73 / img.size.height
            s = CGSize(width: img.size.width * ratio, height: 73)
        }
        return s
    }
}
*/

@IBDesignable
class DynamicImageView: UIImageView {

    @IBInspectable var fixedWidth: CGFloat = 0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    @IBInspectable var fixedHeight: CGFloat = 0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        var s = CGSize.zero
        if fixedWidth > 0 && fixedHeight > 0 {
            s.width = fixedWidth
            s.height = fixedHeight
        } else if fixedWidth <= 0 && fixedHeight > 0 {
            if let image = self.image {
                let ratio = fixedHeight / image.size.height
                s.width = image.size.width * ratio - 10
                s.height = fixedHeight
            }
        } else if fixedWidth > 0 && fixedHeight <= 0 {
            s.width = fixedWidth
            if let image = self.image {
                let ratio = fixedWidth / image.size.width
                s.height = image.size.height * ratio
            }
        } else {
            s = image?.size ?? .zero
        }
        return s
    }
}

/*
func getHeaderInformations (myUrl: URL, completion: @escaping (_ content: String?) -> ()) {

    var request = URLRequest(url: myUrl)
    request.httpMethod = "HEAD"
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
    guard error == nil, let reponse = response as? HTTPURLResponse, let contentType = reponse.allHeaderFields["Content-Type"],let contentLength = reponse.allHeaderFields["Content-Length"]

        else{
            completion(nil)
            return
    }
        let content = String(describing: contentType) + "/" + String(describing: contentLength)

            completion(content)
    }
    task.resume()
}

static func sizeOfImageAt(url: URL) -> CGSize? {
    // with CGImageSource we avoid loading the whole image into memory
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
        return nil
    }

    let propertiesOptions = [kCGImageSourceShouldCache: false] as CFDictionary
    guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, propertiesOptions) as? [CFString: Any] else {
        return nil
    }

    if let width = properties[kCGImagePropertyPixelWidth] as? CGFloat,
        let height = properties[kCGImagePropertyPixelHeight] as? CGFloat {
        return CGSize(width: width, height: height)
    } else {
        return nil
    }
}
 */
