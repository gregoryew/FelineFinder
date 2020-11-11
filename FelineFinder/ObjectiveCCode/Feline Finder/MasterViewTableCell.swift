//
//  PetFinderTableCell.swift
//  FelineFinder
//
//  Created by Gregory Williams on 7/4/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit

class MasterViewCell: UITableViewCell {
    
    @IBOutlet weak var CatImage: UIImageView!
    @IBOutlet weak var CatNameLabel: UILabel!
    var lastCell: Bool = false
    
    override func draw(_ rect: CGRect) {
        //CatImage.layer.cornerRadius = CatImage.frame.size.width / 2
        //CatImage.layer.masksToBounds = true
        //CatImage.clipsToBounds = true
        CatImage.contentMode = .scaleAspectFill
        applyPlainShadow(view: CatImage)
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
    
    //Mirror Effect
    /*
     let theReflection = UIImageView()
     theReflection.image = UIImage(cgImage: (CatImage.image?.cgImage)!, scale: 1.0, orientation: UIImageOrientation.downMirrored)
     theReflection.frame = CatImage.frame
     theReflection.frame = theReflection.frame.offsetBy(dx: 0, dy: CatImage.frame.height)
     theReflection.layer.cornerRadius = CatImage.frame.size.width / 2
     theReflection.layer.masksToBounds = true
     let gradient: CAGradientLayer = CAGradientLayer()
     gradient.frame = theReflection.bounds
     gradient.startPoint = CGPoint(x: 0, y: 0)
     gradient.endPoint = CGPoint(x: 0, y: 1)
     gradient.colors = [cgColor(red: 0.0, green: 0.0, blue: 0.0), cgColor(red: 255.0, green: 255.0, blue: 255.0)]
     theReflection.layer.insertSublayer(gradient, at: 0)
     addSubview(theReflection)
     */
    
    /*
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
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
