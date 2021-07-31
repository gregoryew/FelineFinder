//
//  SegmentCollectionViewCell.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/15/20.
//

import UIKit

class SegmentCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var SegmentButton: UIButton!
    
    func configure(text: String, isSelected: Bool) {
        SegmentButton.setTitle(text, for: .normal)
        if isSelected {
            SegmentButton.backgroundColor = UIColor.darkYellow
            SegmentButton.tintColor = UIColor.black
        } else {
            SegmentButton.backgroundColor = UIColor.gray
            SegmentButton.tintColor = UIColor.white
        }
    }
}
