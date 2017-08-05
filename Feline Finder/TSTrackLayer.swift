//
//  TSTrackLayer.swift
//  TestSlider
//
//  Created by gregoryew1 on 7/16/17.
//  Copyright © 2017 gregoryew1. All rights reserved.
//

import UIKit

class TSTrackLayer: CALayer {
    weak var ticksSlider: TicksSlider?
    
    override func draw(in ctx: CGContext) {
        if let slider = ticksSlider {
            // Path without ticks
            let trackPath = UIBezierPath(rect: CGRect(x: 0, y: bounds.maxY - slider.trackHight, width: bounds.width, height: slider.trackHight * 4))
            
            // Fill the track
            ctx.setFillColor(slider.trackColor)
            ctx.addPath(trackPath.cgPath)
            ctx.fillPath()
            
            let backgroundLayer = CALayer()
            backgroundLayer.backgroundColor = UIColor.white.cgColor
            backgroundLayer.frame = CGRect(x: 0, y: 19, width: bounds.maxX + 10, height: 10)
            slider.layer.addSublayer(backgroundLayer)
            
            let valueLayer = CAGradientLayer()
            let statVal = CGFloat((Double(bounds.maxX) / slider.maximumValue) * slider.statValue)
            valueLayer.frame = CGRect(x: 0, y: 19, width: statVal, height: 10)
            valueLayer.colors = [UIColor.cyan.cgColor, UIColor.blue.cgColor]
            valueLayer.startPoint = CGPoint(x: 0, y: 0.5)
            valueLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
            slider.layer.addSublayer(valueLayer)
            
            let preferenceLayer = CALayer()
            var preferenceVal = CGFloat((Double(bounds.maxX) / slider.maximumValue) * slider.value)
            var prefColor: CGColor?
            if preferenceVal > statVal {
                prefColor = UIColor.green.cgColor
                preferenceLayer.backgroundColor = prefColor
                preferenceVal = preferenceVal - statVal
                preferenceLayer.frame = CGRect(x: statVal, y: 19, width: preferenceVal, height: 10)
            } else if preferenceVal < statVal {
                prefColor = UIColor.yellow.cgColor
                preferenceLayer.backgroundColor = prefColor
                preferenceLayer.frame = CGRect(x: 0, y: 19, width: preferenceVal, height: 10)
            } else {
                prefColor = UIColor.clear.cgColor
                preferenceLayer.backgroundColor = prefColor
                preferenceLayer.frame = CGRect(x: 20, y: 19, width: preferenceVal + 20, height: 10)
            }
            slider.layer.addSublayer(preferenceLayer)
            
            // Draw ticks
            for index in Int(slider.minimumValue)...Int(slider.maximumValue) {
                let delta = (bounds.width / CGFloat(slider.maximumValue))
                
                // Clip
                let tickPath = UIBezierPath(rect: CGRect(x: CGFloat(index) * delta - 0.5 * slider.tickWidth , y: 0.0, width: slider.tickWidth, height: slider.tickHight))
                
                // Fill the tick
                ctx.setFillColor(slider.tickColor)
                ctx.addPath(tickPath.cgPath)
                ctx.fillPath()
            }
        }
    }
}
