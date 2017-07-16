//
//  SectionHeaderViewCollectionReusableView.swift
//  Feline Finder
//
//  Created by gregoryew1 on 12/18/16.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import UIKit

class SectionHeaderViewCollectionReusableView2: UICollectionReusableView {
    @IBOutlet weak var SectionHeaderLabel: UILabel!
    
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ActivityIndicator.isHidden = true
        SectionHeaderLabel.text = ""
    }
}
