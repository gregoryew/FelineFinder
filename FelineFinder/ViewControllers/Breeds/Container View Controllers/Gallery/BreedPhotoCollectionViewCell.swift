//
//  PhotoCollectionViewCell.swift
//  FelineFinder
//
//  Created by Gregory Williams on 12/2/20.
//

import UIKit
import Kingfisher

class BreedPhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var catPhotoImg: UIImageView!
    
    func configure(img: imageTool) {
        print("URL = \(img.thumbNail.URL))")
        if let imgURL = URL(string: img.thumbNail.URL) {
            catPhotoImg.kf.indicatorType = .activity
            catPhotoImg.kf.setImage(with: imgURL)
        } else {
            catPhotoImg.image = UIImage(named: "NoCatImage")
        }
    }
}
