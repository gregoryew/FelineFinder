//
//  MainTabBreedCollectionViewCell.swift
//  Feline Finder
//
//  Created by Gregory Williams on 11/4/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import UIKit

class MainTabBreedCollectionViewCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet  {
            subCatImage.alpha = self.isSelected ? 1 : 0.5
        }
    }
    
    override func prepareForReuse() {
        super .prepareForReuse()
    }
    
    @IBOutlet weak var subCatImage: UIImageView!
    
    func configure(imgURL: URL, isSelected: Bool) {
        subCatImage.alpha = isSelected ? 1 : 0.5
        subCatImage.sd_setImage(with: imgURL) { (img, err, opt, url) in
            if let e = err {
                print("IMAGE ERROR = \(e)")
            } else {
                print("NO ERROR")
            }
        }
        subCatImage.sd_setImage(with: imgURL, placeholderImage: UIImage(named: "NoCatImage"))
        let vc = UIView(frame: CGRect(x: -100, y: -100, width: 1000, height: 1000))
        vc.backgroundColor = UIColor.black
        self.contentView.addSubview(vc)
        self.contentView.sendSubviewToBack(vc)
    }
    
}
