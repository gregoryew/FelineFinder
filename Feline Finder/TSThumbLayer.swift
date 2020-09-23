//
//  TSThumbLayer.swift
//  TestSlider
//
//  Created by gregoryew1 on 7/16/17.
//  Copyright © 2017 gregoryew1. All rights reserved.
//

import UIKit

class TSThumbLayer: CALayer {
    /*
    var highlighted: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    */
    weak var ticksSlider : TicksSlider?
    
    override func draw(in ctx: (CGContext?)) {
        if let slider = ticksSlider {
            let myLayer = CALayer()
            if slider.knobVisible == false {
                return
            }
            let myImage = UIImage(named: "SliderKnob")?.cgImage
            //myLayer.frame = bounds
            //self.bounds.size = CGSize(width: 20, height: 20)
            myLayer.contents = myImage
            myLayer.frame = CGRect(x: 0, y: 0, width: (myImage?.width)!, height: (myImage?.height)!)
            self.backgroundColor = UIColor.clear.cgColor
            //self.highlighted = false
            self.addSublayer(myLayer)
        }
    }
}
