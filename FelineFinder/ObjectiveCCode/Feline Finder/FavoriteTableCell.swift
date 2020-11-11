//
//  FavoriteTableCell.swift
//  FelineFinder
//
//  Created by Gregory Williams on 7/11/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit

class FavoriteTableCell: UITableViewCell {
    
    @IBOutlet weak var CatImage: UIImageView!
    @IBOutlet weak var CatName: UILabel!
    
    override func draw(_ rect: CGRect) {
        CatImage.contentMode = .scaleAspectFill
        applyPlainShadow(view: CatImage)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if UIDevice().model.hasPrefix("iPad") {
            CatImage.cornerRadius = 40
        } else {
            CatImage.cornerRadius = 40
        }
    }
    
    func applyPlainShadow(view: UIView) {
        let layer = view.layer
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 10, height: 10)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5
    }
}

