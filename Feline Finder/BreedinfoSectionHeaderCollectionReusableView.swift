//
//  BreedinfoSectionHeaderCollectionReusableView.swift
//  Feline Finder
//
//  Created by gregoryew1 on 7/16/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import UIKit

class BreedinfoSectionHeaderCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var SectionHeaderLabel: UILabel!
        
    override func prepareForReuse() {
        super.prepareForReuse()
        SectionHeaderLabel.text = ""
    }
}
