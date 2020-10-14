//
//  MainTabAdoptableCatsSubTVCell.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/3/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import Foundation

protocol AmISelected {
    func selected(tag: Int) -> Bool
}

class MainTabAdoptableCatsSubCVCell: UICollectionViewCell {
    var delegate: AmISelected!
    
    override var isSelected: Bool {
        didSet  {
            subCatImage.alpha = self.isSelected ? 1 : 0.5
        }
    }
    
    override func prepareForReuse() {
        super .prepareForReuse()
        isSelected = delegate.selected(tag: subCatImage.tag)
    }
    
    @IBOutlet weak var subCatImage: DynamicImageView!
    
    func configure(imgURL: URL, isSelected: Bool) {
        subCatImage.alpha = isSelected ? 1 : 0.5
        subCatImage.sd_setImage(with: imgURL, placeholderImage: UIImage(named: "NoCatImage"))
    }
    
}
