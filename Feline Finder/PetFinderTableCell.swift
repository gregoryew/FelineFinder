//
//  PetFinderTableCell.swift
//  FelineFinder
//
//  Created by Gregory Williams on 7/4/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit

class PetFinderCell: UITableViewCell {
    
    @IBOutlet weak var CatImage: UIImageView!
    @IBOutlet weak var CatNameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var hasVideo: UIImageView!
    
    var lastCell: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        let whiteColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
        let lightGrayColor = UIColor (red:230.0/255.0, green:230.0/255.0, blue:230.0/255.0, alpha:1.0)
        let separatorColor = UIColor(red:208.0/255.0, green:208.0/255.0, blue:208.0/255.0, alpha:1.0)
        
        let paperRect = self.bounds
        
        if (self.selected) {
            drawLinearGradient(context, paperRect, lightGrayColor.CGColor, separatorColor.CGColor)
        } else {
            drawLinearGradient(context, paperRect, whiteColor.CGColor, lightGrayColor.CGColor)
        }
        
        drawLinearGradient(context, paperRect, whiteColor.CGColor, lightGrayColor.CGColor)
        
        var strokeRect = paperRect
        strokeRect.size.height -= 1
        strokeRect = rectFor1PxStroke(strokeRect)
        
        CGContextSetStrokeColorWithColor(context, whiteColor.CGColor)
        
        CGContextSetLineWidth(context, 1.0)
        CGContextStrokeRect(context, strokeRect)
        
        let startPoint = CGPointMake(paperRect.origin.x, paperRect.origin.y + paperRect.size.height - 1)
        let endPoint = CGPointMake(paperRect.origin.x + paperRect.size.width - 1, paperRect.origin.y + paperRect.size.height - 1)
        
        if (!self.lastCell) {
            draw1PxStroke(context, startPoint, endPoint, separatorColor.CGColor)
        } else {
            CGContextSetStrokeColorWithColor(context, whiteColor.CGColor)
            CGContextSetLineWidth(context, 1.0)
            
            let pointA = CGPointMake(paperRect.origin.x, paperRect.origin.y + paperRect.size.height - 1)
            let pointB = CGPointMake(paperRect.origin.x, paperRect.origin.y)
            let pointC = CGPointMake(paperRect.origin.x + paperRect.size.width - 1, paperRect.origin.y)
            let pointD = CGPointMake(paperRect.origin.x + paperRect.size.width - 1, paperRect.origin.y + paperRect.size.height - 1)
            
            draw1PxStroke(context, pointA, pointB, whiteColor.CGColor)
            draw1PxStroke(context, pointB, pointC, whiteColor.CGColor)
            draw1PxStroke(context, pointC, pointD, whiteColor.CGColor)
        }
    }
    
}
