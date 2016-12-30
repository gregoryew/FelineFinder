//
//  SectionHeaderViewCollectionReusableView.swift
//  Feline Finder
//
//  Created by gregoryew1 on 12/18/16.
//  Copyright © 2016 Gregory Williams. All rights reserved.
//

import UIKit

class SectionHeaderViewCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var SectionHeaderLabel: UILabel!
    
    @IBOutlet weak var SectionImage: UIImageView!
    
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        SectionImage.image = nil
        ActivityIndicator.isHidden = true
        SectionHeaderLabel.text = ""
    }
}
