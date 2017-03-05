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
    //@IBOutlet weak var Status: UILabel!
    
    var lastCell: Bool = false
    
    override func draw(_ rect: CGRect) {
        //CatImage.layer.cornerRadius = CatImage.frame.size.width / 2
        //CatImage.layer.masksToBounds = true
        //CatImage.clipsToBounds = true
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
 
    
    /*
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    */
    
    /*
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        let whiteColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
        let lightGrayColor = UIColor (red:230.0/255.0, green:230.0/255.0, blue:230.0/255.0, alpha:1.0)
        let separatorColor = UIColor(red:208.0/255.0, green:208.0/255.0, blue:208.0/255.0, alpha:1.0)
        
        let paperRect = self.bounds
        
        if (self.isSelected) {
            drawLinearGradient(context, paperRect, lightGrayColor.cgColor, separatorColor.cgColor)
        } else {
            drawLinearGradient(context, paperRect, whiteColor.cgColor, lightGrayColor.cgColor)
        }
        
        drawLinearGradient(context, paperRect, whiteColor.cgColor, lightGrayColor.cgColor)
        
        var strokeRect = paperRect
        strokeRect.size.height -= 1
        strokeRect = rectFor1PxStroke(strokeRect)
        
        context!.setStrokeColor(whiteColor.cgColor)
        
        context!.setLineWidth(1.0)
        context!.stroke(strokeRect)
        
        let startPoint = CGPoint(x: paperRect.origin.x, y: paperRect.origin.y + paperRect.size.height - 1)
        let endPoint = CGPoint(x: paperRect.origin.x + paperRect.size.width - 1, y: paperRect.origin.y + paperRect.size.height - 1)
        
        if (!self.lastCell) {
            draw1PxStroke(context, startPoint, endPoint, separatorColor.cgColor)
        } else {
            context!.setStrokeColor(whiteColor.cgColor)
            context!.setLineWidth(1.0)
            
            let pointA = CGPoint(x: paperRect.origin.x, y: paperRect.origin.y + paperRect.size.height - 1)
            let pointB = CGPoint(x: paperRect.origin.x, y: paperRect.origin.y)
            let pointC = CGPoint(x: paperRect.origin.x + paperRect.size.width - 1, y: paperRect.origin.y)
            let pointD = CGPoint(x: paperRect.origin.x + paperRect.size.width - 1, y: paperRect.origin.y + paperRect.size.height - 1)
            
            draw1PxStroke(context, pointA, pointB, whiteColor.cgColor)
            draw1PxStroke(context, pointB, pointC, whiteColor.cgColor)
            draw1PxStroke(context, pointC, pointD, whiteColor.cgColor)
        }
    }
 */
    
}

