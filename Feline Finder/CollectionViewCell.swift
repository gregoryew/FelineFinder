//
//  CollectionViewCell.swift
//  Feline Finder
//
//  Created by gregoryew1 on 12/18/16.
//  Copyright © 2016 Gregory Williams. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var CatImager: UIImageView!
    @IBOutlet weak var CatNameLabel: UILabel!
    @IBOutlet weak var Video: UIImageView!
    
    override func prepareForReuse() {
        CatImager.image = nil
        CatNameLabel.text = ""
        Video.image = nil
    }
    
    override func draw(_ rect: CGRect) {
        CatImager.contentMode = .scaleAspectFit
        applyPlainShadow(view: CatImager)
    }
    
    func applyPlainShadow(view: UIView) {
        let layer = view.layer
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 10, height: 10)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        Video.layer.cornerRadius = 25
    }
}
