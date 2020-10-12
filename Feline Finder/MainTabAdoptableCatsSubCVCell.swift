//
//  MainTabAdoptableCatsSubTVCell.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/3/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import Foundation

class MainTabAdoptableCatsSubCVCell: UICollectionViewCell {
    
    @IBOutlet weak var subCatImage: DynamicImageView!
    @IBOutlet weak var MainView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Add width constraint if you want dynamic height
        MainView.translatesAutoresizingMaskIntoConstraints = false
        MainView.heightAnchor.constraint(equalToConstant: 73).isActive = true
    }

}
