//
//  PhotoCollectionViewCell.swift
//  FelineFinder
//
//  Created by Gregory Williams on 12/2/20.
//

import UIKit
import SDWebImage

class BreedPhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var catPhotoImg: UIImageView!
    
    func configure(img: imageTool) {
        print("URL = \(img.thumbNail.URL))")
        catPhotoImg.sd_setImage(with: URL(string: img.thumbNail.URL), placeholderImage: UIImage(named: "NoCatImage"), completed: { (_, err, _, _) in
            if err != nil {
                print("ERROR = \(err!)")
            }
        })
    }
}
