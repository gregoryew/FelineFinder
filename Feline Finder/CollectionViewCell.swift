//
//  CollectionViewCell.swift
//  Feline Finder
//
//  Created by gregoryew1 on 12/18/16.
//  Copyright © 2016 Gregory Williams. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var CatImager: UIImageView!
    @IBOutlet weak var CatNameLabel: UILabel!
    @IBOutlet weak var Video: UIImageView!
    
    
    override func prepareForReuse() {
        CatImager.image = nil
        CatNameLabel.text = ""
        Video.image = nil
    }
}
