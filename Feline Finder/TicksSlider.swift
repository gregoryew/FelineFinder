//
//  TickerSlider.swift
//  TestSlider
//
//  Created by gregoryew1 on 7/16/17.
//  Copyright © 2017 gregoryew1. All rights reserved.
//

import UIKit

class TicksSlider: UIControl {
    
    var previousLocation = CGPoint()
    var h = false

    var minimumValue: Double = -0.1 {
        didSet {
            updateFrames()
        }
    }
    
    var maximumValue: Double = 5.1 {
        didSet {
            updateFrames()
        }
    }
    
    var value: Double = 7.0 {
        didSet {
            updateFrames()
        }
    }
    
    var statValue: Double = 0.0 {
        didSet{
            updateFrames()
        }
    }
    
    var statStartColor: CGColor = UIColor.cyan.cgColor {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }

    var statEndColor: CGColor = UIColor.blue.cgColor {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    var valueStartColor: CGColor = UIColor.yellow.cgColor {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    var valueEndColor: CGColor = UIColor.green.cgColor {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    let trackLayer = TSTrackLayer()
    var trackHight:CGFloat = 2.0 {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    var trackColor: CGColor = UIColor.black.cgColor {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    var tickHight:CGFloat = 8.0 {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    var tickWidth: CGFloat = 2.0 {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    var tickColor: CGColor = UIColor.black.cgColor {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    let thumbLayer = TSThumbLayer()
    var thumbColor: CGColor = UIColor.black.cgColor {
        didSet {
            thumbLayer.setNeedsDisplay()
        }
    }
    var thumbMargin:CGFloat = 2.0 {
        didSet {
            thumbLayer.setNeedsDisplay()
        }
    }
    
    var thumbWidth: CGFloat {
        return CGFloat(bounds.height)
    }
    
    override var frame: CGRect {
        didSet {
            updateFrames()
        }
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        trackLayer.ticksSlider = self
        trackLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(trackLayer)
        
        thumbLayer.ticksSlider = self
        thumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(thumbLayer)
        
        updateFrames()
    }
    
    func updateFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        trackLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: tickHight)
        trackLayer.setNeedsDisplay()
        
        var c = CGFloat(value) * (bounds.width / CGFloat(maximumValue))
        if c == 0 {c = 20}
        //if value == maximumValue {c -= 20}
        let thumbCenter = CGPoint(x: c, y: bounds.midY)
        thumbLayer.frame = CGRect(x: thumbCenter.x - thumbWidth / 2, y: tickHight + thumbMargin , width: thumbWidth, height: thumbWidth)
        thumbLayer.setNeedsDisplay()
        
        thumbLayer.zPosition = 1
        
        CATransaction.commit()
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)
        if thumbLayer.frame.contains(previousLocation) {
            //thumbLayer.highlighted = true
            h = true
        }
        //return thumbLayer.highlighted
        return h
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        // Track how much user has dragged
        let deltaLocation = Double(location.x - previousLocation.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width - thumbLayer.frame.width)
        
        previousLocation = location
        
        // update value
        //if thumbLayer.highlighted {
        if h {
            value += deltaValue
            value = clipValue(value: value)
        }
        
        //sendActions(for: .valueChanged)
        
        //return thumbLayer.highlighted
        return h
    }
    
    func clipValue(value: Double) -> Double {
        return min(max(value, minimumValue), maximumValue)
    }
    
    open var didValueChange:((_ value: Int) -> ())?

    func positionTracker() {
        h = false
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 7, initialSpringVelocity: 15, options: [], animations: { () -> Void in
            let roundValue = round(self.value)
            let thumbCenter = CGPoint(x: CGFloat(roundValue) * (self.bounds.width / CGFloat(self.maximumValue)), y: self.bounds.midY)
            self.thumbLayer.frame = CGRect(x: thumbCenter.x - self.thumbWidth / 2, y: self.tickHight + self.thumbMargin , width: self.thumbWidth, height: self.thumbWidth)
        }) { (Bool) -> Void in
            self.value = round(self.value)
            self.sendActions(for: .valueChanged)
            self.didValueChange?(Int(self.value))
        }
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        //thumbLayer.highlighted = false
        positionTracker()
    }
    
}
