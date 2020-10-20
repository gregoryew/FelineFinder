//
//  MainTabAdoptableCatsSubTVCell.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/3/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import Foundation

class MainTabAdoptableCatsSubCVCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet  {
            subCatImage.alpha = self.isSelected ? 1 : 0.5
        }
    }
    
    override func prepareForReuse() {
        super .prepareForReuse()
    }
    
    @IBOutlet weak var subCatImage: DynamicImageView!
    
    func configure(imgURL: URL, isSelected: Bool) {
        subCatImage.alpha = isSelected ? 1 : 0.5
        subCatImage.sd_setImage(with: imgURL, placeholderImage: UIImage(named: "NoCatImage"))
    }
    
}
