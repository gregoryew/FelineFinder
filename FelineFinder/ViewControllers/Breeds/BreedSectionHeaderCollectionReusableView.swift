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
        if choosenBreedSortOption == .name {
            SectionLetterLabel.text = letter
        } else {
            switch letter {
            case "1": SectionLetterLabel.text = "Purrfect Match"
            case "2": SectionLetterLabel.text = "Wonderful Match"
            case "3": SectionLetterLabel.text = "Good Match"
            case "4": SectionLetterLabel.text = "Maybe Match"
            case "5": SectionLetterLabel.text = "Poor Match"
            case "6": SectionLetterLabel.text = anyFitOptionsSelected ? "Bad Match" : "Unknown Update on Fit tab"
            default: SectionLetterLabel.text = "ERROR"
            }
        }
    }
}
