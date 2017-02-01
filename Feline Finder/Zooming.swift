/*
* Copyright (c) 2014-2016 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import QuartzCore

@IBDesignable
class Zooming: UIButton {
  
  //constants
  let lineWidth: CGFloat = 1.0
  let animationDuration = 1.0
    //ui
  let photoLayer = CALayer()
  let circleLayer = CAShapeLayer()
  let maskLayer = CAShapeLayer()
  let label: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "ArialRoundedMTBold", size: 18.0)
    label.textAlignment = .center
    label.textColor = UIColor.black
    return label
  }()
  
  //variables
  @IBInspectable
  var image: UIImage? = nil {
    didSet {
      photoLayer.contents = image?.cgImage
    }
  }
  
  @IBInspectable
  var name: String? = nil {
    didSet {
      label.text = name
    }
  }
  
  var shouldTransitionToFinishedState = false
  
  override func didMoveToWindow() {
    layer.addSublayer(photoLayer)

    photoLayer.mask = maskLayer
    layer.addSublayer(circleLayer)
    addSubview(label)
    
  }
  
    var hideCircleLayer = true
    
    override func layoutSubviews() {
    super.layoutSubviews()
    
    guard let image = image else {
      return
    }
    
    //Size the avatar image to fit
    photoLayer.frame = CGRect(
      x: (bounds.size.width - image.size.width + lineWidth)/2,
      y: (bounds.size.height - image.size.height - lineWidth)/2,
      width: image.size.width,
      height: image.size.height)
    photoLayer.isHidden = true
    
    //Draw the circle
    /*
    circleLayer.path = UIBezierPath(ovalIn: bounds).cgPath
    circleLayer.strokeColor = UIColor.white.cgColor
    circleLayer.lineWidth = lineWidth
    circleLayer.fillColor = UIColor.clear.cgColor
    */
    let bezierPath = UIBezierPath()
    /*bezierPath.move(to: CGPoint(x: 119.91, y: 0.38))
    bezierPath.addCurve(to: CGPoint(x: 84.38, y: 16.6), controlPoint1: CGPoint(x: 105.87, y: 0.38), controlPoint2: CGPoint(x: 93.23, y: 6.62))
    bezierPath.addCurve(to: CGPoint(x: 48.84, y: 0.38), controlPoint1: CGPoint(x: 75.52, y: 6.62), controlPoint2: CGPoint(x: 62.88, y: 0.38))
    bezierPath.addCurve(to: CGPoint(x: 0.38, y: 51.1), controlPoint1: CGPoint(x: 22.08, y: 0.38), controlPoint2: CGPoint(x: 0.38, y: 23.09))
    bezierPath.addCurve(to: CGPoint(x: 3.87, y: 72.79), controlPoint1: CGPoint(x: 0.38, y: 58.63), controlPoint2: CGPoint(x: 1.65, y: 65.87))
    bezierPath.addCurve(to: CGPoint(x: 7.68, y: 82.46), controlPoint1: CGPoint(x: 3.87, y: 72.79), controlPoint2: CGPoint(x: 5.89, y: 79.03))
    bezierPath.addCurve(to: CGPoint(x: 84.38, y: 154.88), controlPoint1: CGPoint(x: 28.11, y: 126.39), controlPoint2: CGPoint(x: 84.38, y: 154.88))
    bezierPath.addCurve(to: CGPoint(x: 161.07, y: 82.46), controlPoint1: CGPoint(x: 84.38, y: 154.88), controlPoint2: CGPoint(x: 140.64, y: 126.39))
    bezierPath.addCurve(to: CGPoint(x: 164.88, y: 72.79), controlPoint1: CGPoint(x: 161.07, y: 82.46), controlPoint2: CGPoint(x: 163.71, y: 76.61))
    bezierPath.addCurve(to: CGPoint(x: 168.38, y: 51.1), controlPoint1: CGPoint(x: 167, y: 65.84), controlPoint2: CGPoint(x: 168.38, y: 58.63))
    bezierPath.addCurve(to: CGPoint(x: 119.91, y: 0.38), controlPoint1: CGPoint(x: 168.38, y: 23.09), controlPoint2: CGPoint(x: 146.68, y: 0.38))
    bezierPath.close()*/
    
    bezierPath.lineJoinStyle = .round

    circleLayer.path = bezierPath.fit(into: bounds.offsetBy(dx: 300, dy: 0)).moveCenter(to: (self.superview?.window?.bounds.center)!).cgPath
    
    //circleLayer.path = bezierPath.cgPath
    //circleLayer.frame = photoLayer.frame.offsetBy(dx: 0, dy: -10)
    circleLayer.strokeColor = UIColor.white.cgColor
    circleLayer.lineWidth = lineWidth
    circleLayer.fillColor = UIColor.white.cgColor
    circleLayer.isHidden = hideCircleLayer
    
    //Size the layer
    maskLayer.path = circleLayer.path
    maskLayer.position = CGPoint(x: 0.0, y: 10.0)
    
    //Size the label
    //label.frame = CGRect(x: 0.0, y: bounds.size.height + 10.0, width: bounds.size.width, height: 24.0)
  }
    
    func delay(seconds: Double, completion: @escaping ()-> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
    }
    
    func zoom(zoomedRect: CGRect) {
        //let originalCenter = center
        /*
        UIView.animate(withDuration: animationDuration, delay: 0.0, usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       animations: {
                        self.frame = zoomedRect
        },
                       completion: {_ in
                        //complete bounce to
        }
        )
        */
        /*
        UIView.animate(withDuration: animationDuration, delay: animationDuration, usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1.0,
                       animations: {
                        //self.photoLayer.frame = zoomedRect
        },
                       completion: nil
        )
        */
        
//        let morphedFrame = zoomedRect
        hideCircleLayer = false
        circleLayer.removeFromSuperlayer()
        window?.rootViewController?.view.layer.insertSublayer(circleLayer, at: UInt32(layer.sublayers!.count))
        self.layoutSubviews()
        
        let morphAnimation = CABasicAnimation(keyPath: "path")
        morphAnimation.duration = animationDuration
        
        //bezierPath.fit(into: zoomedRect).moveCenter(to: photoLayer.frame.center).fill()
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 119.91, y: 0.38))
        bezierPath.addCurve(to: CGPoint(x: 84.38, y: 16.6), controlPoint1: CGPoint(x: 105.87, y: 0.38), controlPoint2: CGPoint(x: 93.23, y: 6.62))
        bezierPath.addCurve(to: CGPoint(x: 48.84, y: 0.38), controlPoint1: CGPoint(x: 75.52, y: 6.62), controlPoint2: CGPoint(x: 62.88, y: 0.38))
        bezierPath.addCurve(to: CGPoint(x: 0.38, y: 51.1), controlPoint1: CGPoint(x: 22.08, y: 0.38), controlPoint2: CGPoint(x: 0.38, y: 23.09))
        bezierPath.addCurve(to: CGPoint(x: 3.87, y: 72.79), controlPoint1: CGPoint(x: 0.38, y: 58.63), controlPoint2: CGPoint(x: 1.65, y: 65.87))
        bezierPath.addCurve(to: CGPoint(x: 7.68, y: 82.46), controlPoint1: CGPoint(x: 3.87, y: 72.79), controlPoint2: CGPoint(x: 5.89, y: 79.03))
        bezierPath.addCurve(to: CGPoint(x: 84.38, y: 154.88), controlPoint1: CGPoint(x: 28.11, y: 126.39), controlPoint2: CGPoint(x: 84.38, y: 154.88))
        bezierPath.addCurve(to: CGPoint(x: 161.07, y: 82.46), controlPoint1: CGPoint(x: 84.38, y: 154.88), controlPoint2: CGPoint(x: 140.64, y: 126.39))
        bezierPath.addCurve(to: CGPoint(x: 164.88, y: 72.79), controlPoint1: CGPoint(x: 161.07, y: 82.46), controlPoint2: CGPoint(x: 163.71, y: 76.61))
        bezierPath.addCurve(to: CGPoint(x: 168.38, y: 51.1), controlPoint1: CGPoint(x: 167, y: 65.84), controlPoint2: CGPoint(x: 168.38, y: 58.63))
        bezierPath.addCurve(to: CGPoint(x: 119.91, y: 0.38), controlPoint1: CGPoint(x: 168.38, y: 23.09), controlPoint2: CGPoint(x: 146.68, y: 0.38))
        bezierPath.close()
        bezierPath.lineJoinStyle = .round
        
        morphAnimation.toValue = bezierPath.fit(into: zoomedRect).moveCenter(to: photoLayer.frame.center).cgPath
        
        morphAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        /*
        let grow = CABasicAnimation(keyPath:"bounds")
        grow.fromValue = photoLayer.bounds   // from no height
        grow.toValue   = zoomedRect // to a height of 200
        grow.duration  = animationDuration
        // add any additional animation configuration here...
        photoLayer.add(grow, forKey:"grow the height of the layer")
        */
        circleLayer.add(morphAnimation, forKey: nil)
        maskLayer.add(morphAnimation, forKey: nil)
        delay(seconds: animationDuration) {self.hideCircleLayer = true
            self.layoutSubviews()}
    }
}
/*
  func bounceOff(point: CGPoint, morphSize: CGSize) {
    let originalCenter = center

    UIView.animate(withDuration: animationDuration, delay: 0.0, usingSpringWithDamping: 0.8,
      initialSpringVelocity: 0.0,
      animations: {
        self.center = point
      },
      completion: {_ in
        //complete bounce to
      }
    )

    UIView.animate(withDuration: animationDuration, delay: animationDuration, usingSpringWithDamping: 0.7,
      initialSpringVelocity: 1.0,
      animations: {
        self.center = originalCenter
      },
      completion: {_ in
        delay(seconds: 0.1) {
            self.bounceOff(point: point, morphSize: morphSize)
        }
      }
    )

    let morphedFrame = (originalCenter.x > point.x) ?

      CGRect(x: 0.0, y: bounds.height - morphSize.height,
             width: morphSize.width, height: morphSize.height):

      CGRect(x: bounds.width - morphSize.width,
             y: bounds.height - morphSize.height,
             width: morphSize.width, height: morphSize.height)

    let morphAnimation = CABasicAnimation(keyPath: "path")
    morphAnimation.duration = animationDuration
    morphAnimation.toValue = UIBezierPath(ovalIn: morphedFrame).cgPath

    morphAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)

    circleLayer.add(morphAnimation, forKey: nil)
    maskLayer.add(morphAnimation, forKey: nil)
  }
}
*/
    
extension CGRect{
    var center: CGPoint {
        return CGPoint( x: self.size.width/2.0,y: self.size.height/2.0)
    }
}
extension CGPoint{
    func vector(to p1:CGPoint) -> CGVector{
        return CGVector(dx: p1.x-self.x, dy: p1.y-self.y)
    }
}

extension UIBezierPath{
    func moveCenter(to:CGPoint) -> Self{
        let bound  = self.cgPath.boundingBox
        let center = bounds.center
        
        let zeroedTo = CGPoint(x: to.x-bound.origin.x, y: to.y-bound.origin.y)
        let vector = center.vector(to: zeroedTo)
        
        offset(to: CGSize(width: vector.dx, height: vector.dy))
        return self
    }
    
    func offset(to offset:CGSize) -> Self{
        let t = CGAffineTransform(translationX: offset.width, y: offset.height)
        applyCentered(transform: t)
        return self
    }
    
    func fit(into:CGRect) -> Self{
        let bounds = self.cgPath.boundingBox
        
        let sw     = into.size.width/bounds.width
        let sh     = into.size.height/bounds.height
        let factor = min(sw, max(sh, 0.0))
        
        return scale(x: factor, y: factor)
    }
    
    func scale(x:CGFloat, y:CGFloat) -> Self{
        let scale = CGAffineTransform(scaleX: x, y: y)
        applyCentered(transform: scale)
        return self
    }
    
    
    func applyCentered(transform: @autoclosure () -> CGAffineTransform ) -> Self{
        let bound  = self.cgPath.boundingBox
        let center = CGPoint(x: bound.midX, y: bound.midY)
        var xform  = CGAffineTransform.identity
        
        xform = xform.concatenating(CGAffineTransform(translationX: -center.x, y: -center.y))
        xform = xform.concatenating(transform())
        xform = xform.concatenating( CGAffineTransform(translationX: center.x, y: center.y))
        apply(xform)
        
        return self
    }
}
