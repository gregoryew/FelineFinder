//
//  CollectionViewCell.swift
//  Feline Finder
//
//  Created by gregoryew1 on 12/18/16.
//  Copyright © 20167 Gregory Williams. All rights reserved.
//

import UIKit

protocol MyCellDelegate {
    func lblCityTapped(cell: CollectionViewCell2)
    func lblStatusTapped(cell: CollectionViewCell2)
}

class CollectionViewCell2: UICollectionViewCell {
    @IBOutlet weak var CatImager: UIImageView!
    @IBOutlet weak var CatNameLabel: UILabel!
    @IBOutlet weak var Video: UIImageView!
    @IBOutlet weak var Favorite: UIImageView!
    @IBOutlet weak var BreedName: UILabel!
    @IBOutlet weak var City: UILabel!
    @IBOutlet weak var Status: UILabel!
    
    var CityVar: String = ""
    var StatusVar: String = ""
    
    var lblCityTapRec:UITapGestureRecognizer!
    var lblStatusTapRec:UITapGestureRecognizer!
    var delegate: MyCellDelegate?
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        City.isUserInteractionEnabled = true
        
        lblCityTapRec = UITapGestureRecognizer(target: self, action: #selector(CollectionViewCell2.lblCityTapped(sender:)))
        City.isUserInteractionEnabled = true
        City.addGestureRecognizer(lblCityTapRec)

        Status.isUserInteractionEnabled = true
        
        lblStatusTapRec = UITapGestureRecognizer(target: self, action: #selector(CollectionViewCell2.lblStatusTapped(sender:)))
        Status.isUserInteractionEnabled = true
        Status.addGestureRecognizer(lblStatusTapRec)
    }
        
    func lblCityTapped(sender: AnyObject){
        delegate?.lblCityTapped(cell: self)
    }

    func lblStatusTapped(sender: AnyObject){
        delegate?.lblStatusTapped(cell: self)
    }
    
    override func prepareForReuse() {
        CatImager.image = nil
        CatNameLabel.text = ""
        Video.image = nil
        Favorite.image = nil
        BreedName.text = ""
        City.text = ""
        Status.text = ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if UIDevice().type.rawValue.hasPrefix("iPad") {
            CatImager.cornerRadius = 15
        } else {
            CatImager.cornerRadius = 10
        }
    }
    
    override func draw(_ rect: CGRect) {
        CatImager.contentMode = .scaleAspectFill
        //applyPlainShadow(view: CatImager)
    }
    
    /*
    func applyPlainShadow(view: UIView) {
        let layer = view.layer
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 10, height: 10)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5
    }
 */
}
