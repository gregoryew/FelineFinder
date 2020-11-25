//
//  BreedSectionHeaderCollectionReusableView.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/24/20.
//

import UIKit

class BreedSectionHeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var SectionLetterLabel: UILabel!
    
    func configure(letter: String) {
        SectionLetterLabel.text = letter
    }
}
