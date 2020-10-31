//
//  MainTabAdoptableCatsSubTVCell.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/3/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import Foundation
import SkeletonView

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
        let vc = UIView(frame: CGRect(x: -100, y: -100, width: 1000, height: 1000))
        vc.backgroundColor = UIColor.black
        self.contentView.addSubview(vc)
        self.contentView.sendSubviewToBack(vc)
    }
    
}
