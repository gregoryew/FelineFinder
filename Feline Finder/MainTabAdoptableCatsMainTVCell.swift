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
import ImageSizeFetcher

class MainTabAdoptableCatsMainTVCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, CAAnimationDelegate {
    
    @IBOutlet weak var MainCatImage: UIImageView!
    @IBOutlet weak var SubCatCV: UICollectionView!
    
    @IBOutlet weak var CatNameLabel: UILabel!
    @IBOutlet weak var BreedNameLabel: UILabel!
    @IBOutlet weak var InfoLabel: UILabel!
    @IBOutlet weak var CityLabel: UILabel!
    @IBOutlet weak var FavoriteButton: FaveButton!
    @IBOutlet weak var Togle: UISegmentedControl!
    
    @IBOutlet weak var SubCatCVWidth: NSLayoutConstraint!
    
    private var petData: Pet!
    //private var imgs: [picture2] = []
    //private var ximgs: [picture2] = []
    //private var photos: [picture2] = []
    private var imgs: [imageTool] = []
    private var tools: Tools!
        
    var CGWidths = [CGFloat]()
    
    func configure(pd: Pet?) {
        if let p = pd {

            FavoriteButton.alpha = 1
            CatNameLabel.alpha = 1
            BreedNameLabel.alpha = 1
            CityLabel.alpha = 1
            InfoLabel.alpha = 1
            MainCatImage.alpha = 1
            SubCatCV.alpha = 1
            
            self.petData = p
            
            tools = Tools(pet: self.petData)
            
            setup()
            
            FavoriteButton.isSelected = Favorites.isFavorite(petData.petID, dataSource: .RescueGroup)
            
            let urlString: String? = petData.getImage(1, size: "pn")
            
            CatNameLabel.text = petData.name
            BreedNameLabel.text = petData.breeds.first
            CityLabel.text = "\(petData.location) 🐾 \(petData.distance) Miles"
            InfoLabel.text = "\(petData.status) 🐾 \(petData.sex) 🐾 \(petData.age) 🐾 \(petData.size)"
            
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
            FavoriteButton.alpha = 0
            CatNameLabel.alpha = 0
            BreedNameLabel.alpha = 0
            CityLabel.alpha = 0
            InfoLabel.alpha = 0
            MainCatImage.alpha = 0
            SubCatCV.alpha = 0
        }
    }
    
    func setup() {
        //guard petData != nil else {return}
        //imgs = []
        //imgs = petData.getAllImagesObjectsOfACertainSize("pnt")
        //imgs = petData.getAllImagesOfACertainSize("pnt")
        //ximgs = []
        //ximgs = petData.getAllImagesObjectsOfACertainSize("x")
        
        SubCatCV.dataSource = self
        SubCatCV.delegate = self
                
        SubCatCV!.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let layout = SubCatCV.collectionViewLayout as! HorizontalLayoutVaryingWidths
        layout.delegate = self
        layout.numberOfRows = 1
        layout.cellPadding = 2.5
        
        CGWidths = []
        let imgs = tools.images()
        for img in imgs {
            let ratio = 100 / CGFloat(img.thumbNail.height)
            let w2 = CGFloat(img.thumbNail.width) * ratio
            CGWidths.append(w2)
        }
         
        DispatchQueue.main.async {
            self.SubCatCV.reloadData()
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
            let indexPathForFirstRow = IndexPath(row: selectedImages[self.tag], section: 0)
            self.SubCatCV.selectItem(at: indexPathForFirstRow, animated: false, scrollPosition: UICollectionView.ScrollPosition.left)
            self.SubCatCV.layoutIfNeeded()
        }
    }
    
    @IBAction func togleSwitched(_ sender: Any) {
        self.tools?.switchMode()
    }
    
    @IBAction func favoriteTapped(_ sender: Any) {
        if FavoriteButton.isSelected {
            let f = Favorite(petID: petData.petID, petName: petData.name, imageName: petData.media[0].URL, breed: petData.breeds.popFirst() ?? "", FavoriteDataSource: DataSource.RescueGroup, Status: petData.status)
            Favorites.addFavorite(petData.petID, f: f)
        } else {
            Favorites.removeFavorite(petData.petID, dataSource: .RescueGroup)
        }
    }
    
    override func prepareForReuse() {
        super .prepareForReuse()
        self.backgroundColor = UIColor.clear
        self.MainCatImage.backgroundColor = UIColor.clear
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgs.count
    }
        
    @objc func curlRightAnimation(_ gesture: UISwipeGestureRecognizer)
    {
        print("PAGE CURL RIGHT")
        
        if selectedImages[tag] >= imgs.count - 1 {
            Animations.requireUserAtencion(on: self.MainCatImage)
            return
        }
        
        QuartzCore.CATransaction.begin() //Begin the CATransaction

        QuartzCore.CATransaction.setAnimationDuration(0.7)
        QuartzCore.CATransaction.setCompletionBlock {
        }

        MainCatImage.layer.pageCURL(duration: 0.7, direction: CATransitionSubtype.fromRight)

        selectedImages[tag] += 1
        
        let newImgURL = URL(string: imgs[selectedImages[tag]].photo.URL)
            
        self.MainCatImage.sd_setImage(with: newImgURL, placeholderImage: UIImage(named: "NoCatImage"), options: SDWebImageOptions.highPriority) { (img, err, _, _) in
            CATransaction.commit()
            self.SubCatCV.selectItem(at: IndexPath(item: selectedImages[self.tag], section: 0), animated: true, scrollPosition: .centeredHorizontally)
        }
        
    }

    @objc func curlLeftAnimation(_ gesture: UISwipeGestureRecognizer)
    {
        print("PAGE CURL LEFT")
        
        if selectedImages[tag] <= 0 {
            Animations.requireUserAtencion(on: self.MainCatImage)
            return
        }
        
        QuartzCore.CATransaction.begin() //Begin the CATransaction

        QuartzCore.CATransaction.setAnimationDuration(0.7)
        QuartzCore.CATransaction.setCompletionBlock {
        }

        MainCatImage.layer.pageCURL(duration: 0.7, direction: CATransitionSubtype.fromLeft)

        selectedImages[tag] -= 1
                
        let newImgURL = URL(string: imgs[selectedImages[tag]].photo.URL)
        
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
        let cell = SubCatCV.dequeueReusableCell(withReuseIdentifier: "subCell", for: indexPath) as! MainTabAdoptableCatsSubCVCell
        cell.tag = indexPath.item
        prepareForReuse()
        if indexPath.item >= imgs.count {
            return cell
        }
        let imgURL = URL(string: imgs[indexPath.item].thumbNail.URL)
        cell.prepareForReuse()
        cell.configure(imgURL: imgURL!, isSelected: selectedImages[tag] == indexPath.row)
        self.layoutIfNeeded()
        self.SubCatCV.setNeedsDisplay()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let thumbNail = URL(string: imgs[indexPath.item].thumbNail.URL)
        let photo = URL(string: imgs[indexPath.item].photo.URL)

        let cell = SubCatCV.dequeueReusableCell(withReuseIdentifier: "subCell", for: indexPath) as! MainTabAdoptableCatsSubCVCell
        
        cell.subCatImage.sd_setImage(with: thumbNail) { (img, err, _, url) in
            print("cell frame = \(cell.frame) imgs w= \(self.imgs[indexPath.item].thumbNail.width) imgs h= \(self.imgs[indexPath.item].thumbNail.height) url= \(self.imgs[indexPath.item].thumbNail.URL) subimg=\(img!.size) ratio=\(img!.size.width * (100 / img!.size.height)) CGFloat=\(self.CGWidths) indexPath=\(indexPath) imgsCount=\(self.imgs.count) petID=\(self.petData.petID)")
        }
        
        if indexPath.item - selectedImages[tag] > 0 {
            animateImageView(newImgURL: photo, oldImgURL: imgs[indexPath.item].thumbNail.URL, direction: .fromRight)
        } else if indexPath.item - selectedImages[tag] < 0 {
            animateImageView(newImgURL: photo, oldImgURL: imgs[indexPath.item].thumbNail.URL, direction: .fromLeft)
        } else {
            return
        }
        selectedImages[tag] = indexPath.item
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
 /*
    let photo = imgs[indexPath.item]
    let ratio = 100 / CGFloat(photo.height) //fixedHeight / image.size.height
    let width = CGFloat(photo.width) * ratio
    return width
*/
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
