//
//  BreedInfoTableViewCell.swift
//  Feline Finder
//
//  Created by gregoryew1 on 6/30/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import UIKit

class BreedInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var CatImage: UIImageView!
    @IBOutlet weak var CatNameLabel: UILabel!
    var lastCell: Bool = false
    
    override func draw(_ rect: CGRect) {
        //CatImage.layer.cornerRadius = CatImage.frame.size.width / 2
        //CatImage.layer.masksToBounds = true
        //CatImage.clipsToBounds = true
        CatImage.contentMode = .scaleAspectFill
        //applyPlainShadow(view: CatImage)
    }
    
    func cgColor(red: CGFloat, green: CGFloat, blue: CGFloat) -> AnyObject {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 0.6).cgColor as AnyObject
    }
    
    func applyPlainShadow(view: UIView) {
        let layer = view.layer
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 10, height: 10)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5
    }
    
    func applyCurvedShadow(view: UIView) {
        let size = view.bounds.size
        let width = size.width
        let height = size.height
        let depth = CGFloat(11.0)
        let lessDepth = 0.8 * depth
        let curvyness = CGFloat(5)
        let radius = CGFloat(1)
        
        let path = UIBezierPath()
        
        // top left
        path.move(to: CGPoint(x: radius, y: height))
        
        // top right
        path.addLine(to: CGPoint(x: width - 2*radius, y: height))
        
        // bottom right + a little extra
        path.addLine(to: CGPoint(x: width - 2*radius, y: height + depth))
        
        // path to bottom left via curve
        path.addCurve(to: CGPoint(x: radius, y: height + depth),
                      controlPoint1: CGPoint(x: width - curvyness, y: height + lessDepth - curvyness),
                      controlPoint2: CGPoint(x: curvyness, y: height + lessDepth - curvyness))
        
        let layer = view.layer
        layer.shadowPath = path.cgPath
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = radius
        layer.shadowOffset = CGSize(width: 0, height: -3)
    }
    
    func applyHoverShadow(view: UIView) {
        let size = view.bounds.size
        let width = size.width
        let height = size.height
        
        let ovalRect = CGRect(x: 5, y: height + 5, width: width - 10, height: 15)
        let path = UIBezierPath(roundedRect: ovalRect, cornerRadius: 10)
        
        let layer = view.layer
        layer.shadowPath = path.cgPath
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize(width: 0, height: 0)
    }
}
