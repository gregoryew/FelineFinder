//
//  MainTabAdoptableCatsMainTVCell.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/3/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import Foundation
import FaveButton

class MainTabAdoptableCatsMainTVCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
        
    @IBOutlet weak var MainCatImage: UIImageView!
    @IBOutlet weak var SubCatCV: UICollectionView!
    
    @IBOutlet weak var CatNameLabel: UILabel!
    @IBOutlet weak var BreedNameLabel: UILabel!
    @IBOutlet weak var InfoLabel: UILabel!
    @IBOutlet weak var CityLabel: UILabel!
    @IBOutlet weak var FavoriteButton: FaveButton!
    
    var petData: Pet!
    var imgs: [String]!
    var ximgs: [String]!
        
    func setup() {
        guard petData != nil else {return}
        imgs = petData.getAllImagesOfACertainSize("pnt")
        ximgs = petData.getAllImagesOfACertainSize("x")
        SubCatCV.dataSource = self
        SubCatCV.delegate = self
        DispatchQueue.main.async {
            self.SubCatCV.reloadData()
            self.SubCatCV.layoutIfNeeded()
        }
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
        self.backgroundColor = UIColor.white
        self.MainCatImage.backgroundColor = getRandomColor()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgs.count
    }
    
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
            
            setup()
                        
            FavoriteButton.isSelected = Favorites.isFavorite(petData.petID, dataSource: .RescueGroup)
            
            let urlString: String? = petData.getImage(1, size: "pn")
            
            CatNameLabel.text = petData.name
            BreedNameLabel.text = petData.breeds.first
            CityLabel.text = petData.location
            InfoLabel.text = "\(petData.status) 🐾 \(petData.sex) 🐾 \(petData.age) 🐾 \(petData.size)"
            
            if urlString == "" {
                MainCatImage?.backgroundColor = getRandomColor()
                MainCatImage?.image = UIImage(named: "NoCatImage")
            } else {
                let urlString2 = urlString!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "" //This will fill the spaces with the %20
                let imgURL = URL(string: urlString2)
                MainCatImage.sd_setImage(with: imgURL, placeholderImage: UIImage(named: "NoCatImage"))
            }
        }
        else {
            FavoriteButton.alpha = 0
            CatNameLabel.alpha = 0
            BreedNameLabel.alpha = 0
            CityLabel.alpha = 0
            InfoLabel.alpha = 0
            MainCatImage.alpha = 0
            SubCatCV.alpha = 0
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
        let imgURL = URL(string: imgs[indexPath.row])
        cell.subCatImage.sd_setImage(with: imgURL, placeholderImage: UIImage(named: "NoCatImage"))
        //let block: SDExternalCompletionBlock = {(image, error, cacheType, imageURL) -> Void in
        //    self.layoutIfNeeded()
        //}
        //cell.subCatImage.sd_setImage(with: imgURL, placeholderImage: UIImage(named: "NoCatImage"), completed: block)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imgURL = URL(string: ximgs[indexPath.row])
        
        let cell = SubCatCV.dequeueReusableCell(withReuseIdentifier: "subCell", for: indexPath) as! MainTabAdoptableCatsSubCVCell
        
        UIView.transition(with: self.MainCatImage,
                          duration: 0.5,
                          options: .transitionFlipFromBottom,
                          animations: {
                            self.MainCatImage.sd_setImage(with: imgURL, placeholderImage: (cell.subCatImage as! DynamicImageView).image)
                          }, completion: nil)
    }
}

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
        var size = CGSize.zero
        if fixedWidth > 0 && fixedHeight > 0 {
            size.width = fixedWidth
            size.height = fixedHeight
        } else if fixedWidth <= 0 && fixedHeight > 0 {
            size.height = 73 //fixedHeight
            if let image = self.image {
                let ratio = 73 / image.size.height //fixedHeight / image.size.height
                size.width = image.size.width * ratio
            }
        } else if fixedWidth > 0 && fixedHeight <= 0 {
            size.width = fixedWidth
            if let image = self.image {
                let ratio = fixedWidth / image.size.width
                size.height = image.size.height * ratio
            }
        } else {
            size = image?.size ?? .zero
        }
        return size
    }

}
