//
//  MainTabTableViewCell.swift
//  Feline Finder
//
//  Created by gregoryew1 on 8/7/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import UIKit

class MainTabTableViewCell: UITableViewCell {
    @IBOutlet weak var CatImage: UIImageView!
    @IBOutlet weak var CatName: UILabel!
        
    override func draw(_ rect: CGRect) {
        CatImage.contentMode = .scaleAspectFit
        applyPlainShadow(view: CatImage)
    }
        
    func applyPlainShadow(view: UIView) {
        let layer = view.layer
            
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 10, height: 10)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5
    }
}
