//
//  FFMultiSlider.swift
//  FelineFinder
//
//  Created by Gregory Williams on 8/26/21.
//

import UIKit
import MultiSlider

class FFMultiSlider: MultiSlider {
    @objc func tapAndSlide(gesture: UILongPressGestureRecognizer) {
        let pt = gesture.location(in: self)
      let thumbWidth = self.thumbRect().size.width
      var value: Float = 0

      if (pt.x <= self.thumbRect().size.width / 2) {
        value = Float(self.minimumValue)
      } else if (pt.x >= self.bounds.size.width - thumbWidth / 2) {
        value = Float(self.maximumValue)
      } else {
        let percentage = CGFloat((pt.x - thumbWidth / 2) / (self.bounds.size.width - thumbWidth))
        let delta = percentage * (self.maximumValue - self.minimumValue)
        value = Float(self.minimumValue + delta)
      }

        if (gesture.state == UIGestureRecognizer.State.began) {
            UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseIn, .curveEaseOut],
          animations: {
            self.value = [CGFloat(value)]
            super.sendActions(for: UIControl.Event.valueChanged)
          }, completion: nil)
      } else {
        self.value = [CGFloat(value)]
        super.sendActions(for: UIControl.Event.valueChanged)
      }
    }

    func thumbRect() -> CGRect {
        if let b = self.thumbViews.first {
            return b.bounds
        } else {
            return CGRect.zero
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup()  {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.tapAndSlide(gesture:)))
        longPress.minimumPressDuration = 0
        self.addGestureRecognizer(longPress)
    }
    
}
