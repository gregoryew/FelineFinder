//
//  CollectionViewCell.swift
//  Feline Finder
//
//  Created by gregoryew1 on 12/18/16.
//  Copyright © 20167 Gregory Williams. All rights reserved.
//

import UIKit

class CollectionViewCell2: UICollectionViewCell {
    @IBOutlet weak var CatImager: UIImageView!
    @IBOutlet weak var CatNameLabel: UILabel!
    @IBOutlet weak var Video: UIImageView!
    @IBOutlet weak var Favorite: UIImageView!
    @IBOutlet weak var BreedName: UILabel!
    @IBOutlet weak var City: UILabel!
    @IBOutlet weak var Status: UILabel!
    
    override func prepareForReuse() {
        CatImager.image = nil
        CatNameLabel.text = ""
        Video.image = nil
        Favorite.image = nil
        BreedName.text = ""
        City.text = ""
        Status.text = ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if UIDevice().type.rawValue.hasPrefix("iPad") {
            CatImager.cornerRadius = 15
        } else {
            CatImager.cornerRadius = 10
        }
    }
    
    override func draw(_ rect: CGRect) {
        CatImager.contentMode = .scaleAspectFill
        //applyPlainShadow(view: CatImager)
    }
}
