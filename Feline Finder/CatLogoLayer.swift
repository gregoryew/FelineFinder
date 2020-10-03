/*
* Copyright (c) 2014-present Razeware LLC
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

class CatLogoLayer {
  
  //
  // Function to create a RW logo shape layer
  //
/*
  class func logoLayer() -> CAShapeLayer {
    let layer = CAShapeLayer()
    layer.isGeometryFlipped = true
    
    //the RW bezier
    let bezier = UIBezierPath()
    bezier.move(to: CGPoint(x: 0.0, y: 0.0))
    bezier.addCurve(to: CGPoint(x: 0.0, y: 66.97), controlPoint1:CGPoint(x: 0.0, y: 0.0), controlPoint2:CGPoint(x: 0.0, y: 57.06))
    bezier.addCurve(to: CGPoint(x: 16.0, y: 39.0), controlPoint1: CGPoint(x: 27.68, y: 66.97), controlPoint2:CGPoint(x: 42.35, y: 52.75))
    bezier.addCurve(to: CGPoint(x: 26.0, y: 17.0), controlPoint1: CGPoint(x: 17.35, y: 35.41), controlPoint2:CGPoint(x: 26, y: 17))
    bezier.addLine(to: CGPoint(x: 38.0, y: 34.0))
    bezier.addLine(to: CGPoint(x: 49.0, y: 17.0))
    bezier.addLine(to: CGPoint(x: 67.0, y: 51.27))
    bezier.addLine(to: CGPoint(x: 67.0, y: 0.0))
    bezier.addLine(to: CGPoint(x: 0.0, y: 0.0))
    bezier.close()
    
    //create a shape layer
    layer.path = bezier.cgPath
    layer.bounds = (layer.path?.boundingBox)!
    
    return layer
  }
*/
    
    class func logoLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        //layer.isGeometryFlipped = true
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 130.82, y: 0.38))
        bezierPath.addLine(to: CGPoint(x: 101.76, y: 29.81))
        bezierPath.addLine(to: CGPoint(x: 97.37, y: 64.46))
        bezierPath.addLine(to: CGPoint(x: 103.33, y: 117.87))
        bezierPath.addLine(to: CGPoint(x: 176.45, y: 305.77))
        bezierPath.addLine(to: CGPoint(x: 169.94, y: 344.14))
        bezierPath.addLine(to: CGPoint(x: 149.62, y: 358.42))
        bezierPath.addLine(to: CGPoint(x: 110.91, y: 369.88))
        bezierPath.addLine(to: CGPoint(x: 85.73, y: 359.38))
        bezierPath.addLine(to: CGPoint(x: 72.46, y: 362.43))
        bezierPath.addLine(to: CGPoint(x: 71.05, y: 383.96))
        bezierPath.addLine(to: CGPoint(x: 76.51, y: 405.2))
        bezierPath.addLine(to: CGPoint(x: 81.89, y: 417.69))
        bezierPath.addLine(to: CGPoint(x: 66.61, y: 416.52))
        bezierPath.addLine(to: CGPoint(x: 30.7, y: 404.29))
        bezierPath.addLine(to: CGPoint(x: 3.34, y: 397.59))
        bezierPath.addLine(to: CGPoint(x: 0.38, y: 409.55))
        bezierPath.addLine(to: CGPoint(x: 2.56, y: 439.99))
        bezierPath.addLine(to: CGPoint(x: 15.95, y: 482.38))
        bezierPath.addLine(to: CGPoint(x: 30.39, y: 525.59))
        bezierPath.addLine(to: CGPoint(x: 58.9, y: 571.72))
        bezierPath.addLine(to: CGPoint(x: 95.08, y: 611.32))
        bezierPath.addLine(to: CGPoint(x: 161.83, y: 645.61))
        bezierPath.addLine(to: CGPoint(x: 253.98, y: 658.52))
        bezierPath.addLine(to: CGPoint(x: 323.99, y: 648.44))
        bezierPath.addLine(to: CGPoint(x: 332.06, y: 677.29))
        bezierPath.addLine(to: CGPoint(x: 358.06, y: 710.85))
        bezierPath.addLine(to: CGPoint(x: 392.35, y: 731.24))
        bezierPath.addLine(to: CGPoint(x: 424.93, y: 739.38))
        bezierPath.addLine(to: CGPoint(x: 459.09, y: 739.38))
        bezierPath.addLine(to: CGPoint(x: 485.24, y: 727.74))
        bezierPath.addLine(to: CGPoint(x: 515.68, y: 716.91))
        bezierPath.addLine(to: CGPoint(x: 535.62, y: 697.76))
        bezierPath.addLine(to: CGPoint(x: 541.23, y: 674.56))
        bezierPath.addLine(to: CGPoint(x: 544.27, y: 646.82))
        bezierPath.addLine(to: CGPoint(x: 601.36, y: 656.18))
        bezierPath.addLine(to: CGPoint(x: 673.06, y: 655.24))
        bezierPath.addLine(to: CGPoint(x: 720.14, y: 644.53))
        bezierPath.addLine(to: CGPoint(x: 766.61, y: 617.11))
        bezierPath.addLine(to: CGPoint(x: 803.57, y: 581.39))
        bezierPath.addLine(to: CGPoint(x: 828.76, y: 548.89))
        bezierPath.addLine(to: CGPoint(x: 848.06, y: 510.77))
        bezierPath.addLine(to: CGPoint(x: 870.81, y: 446.69))
        bezierPath.addLine(to: CGPoint(x: 871.34, y: 399.71))
        bezierPath.addLine(to: CGPoint(x: 859.52, y: 396.77))
        bezierPath.addLine(to: CGPoint(x: 790.34, y: 420.9))
        bezierPath.addLine(to: CGPoint(x: 798.71, y: 401.45))
        bezierPath.addLine(to: CGPoint(x: 805.71, y: 378.75))
        bezierPath.addLine(to: CGPoint(x: 799.47, y: 359.36))
        bezierPath.addLine(to: CGPoint(x: 781.93, y: 361.64))
        bezierPath.addLine(to: CGPoint(x: 746.1, y: 369.88))
        bezierPath.addLine(to: CGPoint(x: 716.64, y: 353.17))
        bezierPath.addLine(to: CGPoint(x: 699.99, y: 310.54))
        bezierPath.addLine(to: CGPoint(x: 720.69, y: 257.28))
        bezierPath.addLine(to: CGPoint(x: 741.86, y: 195.65))
        bezierPath.addLine(to: CGPoint(x: 762.68, y: 142.67))
        bezierPath.addLine(to: CGPoint(x: 775.32, y: 90.03))
        bezierPath.addLine(to: CGPoint(x: 775.32, y: 47.01))
        bezierPath.addLine(to: CGPoint(x: 766.15, y: 19.8))
        bezierPath.addLine(to: CGPoint(x: 744.97, y: 0.38))
        bezierPath.addLine(to: CGPoint(x: 523.28, y: 179.65))
        bezierPath.addLine(to: CGPoint(x: 478.73, y: 166.4))
        bezierPath.addLine(to: CGPoint(x: 446.19, y: 164.14))
        bezierPath.addLine(to: CGPoint(x: 411.64, y: 165.96))
        bezierPath.addLine(to: CGPoint(x: 371.92, y: 171.72))
        bezierPath.addLine(to: CGPoint(x: 354.89, y: 177.98))
        bezierPath.addLine(to: CGPoint(x: 130.82, y: 0.38))
        bezierPath.close()
        bezierPath.lineCapStyle = .round;
        bezierPath.lineJoinStyle = .round;
        
        let rect = CGRect(x: 300, y: 300, width: 10, height: 10)
        let bz2 = bezierPath.fit(into: rect) //.moveCenter(to: rect.center)
        
        //create a shape layer
        layer.path = bz2.cgPath
        layer.bounds = (layer.path?.boundingBox)!
        
        return layer
    }
 }

/*
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
*/
