//
//  MainBreedCollectionViewCell.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/24/20.
//

import UIKit
import SDWebImage
import MarqueeLabel

class MainBreedCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var BreedNameLabel: MarqueeLabel!
    @IBOutlet weak var BreedImage: UIImageView!
    
    func configure(breed: Breed) {
        self.BreedNameLabel.text = breed.BreedName
        //self.BreedImage.image = UIImage(named: breed.PictureHeadShotName)
        self.BreedImage.image = UIImage(named: "Cartoon Devon Rex")
    }
}
