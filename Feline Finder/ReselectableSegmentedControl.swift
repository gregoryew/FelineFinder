//
//  ReselectableSegmentedControl.swift
//  FelineFinder
//
//  Created by Gregory Williams on 8/9/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation

class ReselectableSegmentedControl: UISegmentedControl {
    @IBInspectable var allowReselection: Bool = true
    
    override func touchesEnded(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        let previousSelectedSegmentIndex = self.selectedSegmentIndex
        super.touchesEnded(touches!, withEvent: event)
        if allowReselection && previousSelectedSegmentIndex == self.selectedSegmentIndex {
            if let touch = touches!.first as UITouch? {
                let touchLocation = touch.locationInView(self)
                if CGRectContainsPoint(bounds, touchLocation) {
                    self.sendActionsForControlEvents(.ValueChanged)
                }
            }
        }
    }
}