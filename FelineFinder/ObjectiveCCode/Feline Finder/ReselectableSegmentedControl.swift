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
    
    override func touchesEnded(_ touches: Set<UITouch>?, with event: UIEvent?) {
        let previousSelectedSegmentIndex = self.selectedSegmentIndex
        super.touchesEnded(touches!, with: event)
        if allowReselection && previousSelectedSegmentIndex == self.selectedSegmentIndex {
            if let touch = touches!.first as UITouch? {
                let touchLocation = touch.location(in: self)
                if bounds.contains(touchLocation) {
                    self.sendActions(for: .valueChanged)
                }
            }
        }
    }
}
