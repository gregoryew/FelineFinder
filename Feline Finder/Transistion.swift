//
//  Transistion.swift
//  Feline Finder
//
//  Created by gregoryew1 on 2/12/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit
import CoreImage

class TransitionImageView2: UIImageView {
    
    @IBInspectable var duration: Double = 0.5
    
    private var transitionStartTime: CFTimeInterval = 0.0
    private var transitionTimer: Timer?
    
    weak var transitionContext: UIViewControllerContextTransitioning?
    weak var viewc: UIViewController?
    weak var viewf: UIViewController?
    
    var i: CGFloat = 0.0
    var bottomImage: UIImage?
    var outputSize: CGSize?
    var transImage: transitionImage?
    var bezierPath: UIBezierPath?
    
    func transitionToImage(toImage: UIImage?, transContext: UIViewControllerContextTransitioning?, vc: UIViewController, ti: transitionImage, fromVC: UIViewController) {
        outputSize = CGSize(width: 10, height: 10)
        bottomImage = toImage
 
        if let timer = transitionTimer, timer.isValid {
            timer.invalidate()
        }
        
        self.transImage = ti
        
        viewc = vc
        viewf = fromVC
        
        transitionContext = transContext
        
        switch transImage! {
        case .cat: bezierPath = self.getCat()
        case .heart: bezierPath = self.getHeart()
        case .search: bezierPath = self.getMagnifyingGlass()
        case .save: bezierPath = self.getDisk()
        case .list: bezierPath = self.getCircle()
        default: bezierPath = self.getCat()
        }
        
        transitionStartTime = CACurrentMediaTime()
        
        transitionTimer = Timer(timeInterval: 1.0/30.0,
                                target: self, selector: #selector(timerFired(timer:)),
                                userInfo: toImage,
                                repeats: true)
        RunLoop.current.add(transitionTimer!, forMode: RunLoopMode.defaultRunLoopMode)
        
    }
    
    func getCat() -> UIBezierPath {
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
        
        return bezierPath
    }
    
    func getHeart() -> UIBezierPath {
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

        return bezierPath
    }
    
    func getMagnifyingGlass() -> UIBezierPath {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 68.3, y: 0.38))
        bezierPath.addLine(to: CGPoint(x: 44.56, y: 13.21))
        bezierPath.addLine(to: CGPoint(x: 30.8, y: 27.27))
        bezierPath.addLine(to: CGPoint(x: 23.09, y: 45.78))
        bezierPath.addLine(to: CGPoint(x: 20.51, y: 72.22))
        bezierPath.addLine(to: CGPoint(x: 24.58, y: 84.57))
        bezierPath.addLine(to: CGPoint(x: 29.5, y: 93.83))
        bezierPath.addLine(to: CGPoint(x: 0.38, y: 123.19))
        bezierPath.addLine(to: CGPoint(x: 0.38, y: 128.91))
        bezierPath.addLine(to: CGPoint(x: 0.38, y: 133.8))
        bezierPath.addLine(to: CGPoint(x: 11.82, y: 144.33))
        bezierPath.addLine(to: CGPoint(x: 19.89, y: 144.33))
        bezierPath.addLine(to: CGPoint(x: 50.19, y: 114.87))
        bezierPath.addLine(to: CGPoint(x: 66.01, y: 120.49))
        bezierPath.addLine(to: CGPoint(x: 81.31, y: 122.97))
        bezierPath.addLine(to: CGPoint(x: 103.62, y: 119.89))
        bezierPath.addLine(to: CGPoint(x: 122.82, y: 109.77))
        bezierPath.addLine(to: CGPoint(x: 133.46, y: 96.72))
        bezierPath.addLine(to: CGPoint(x: 144.41, y: 78.17))
        bezierPath.addLine(to: CGPoint(x: 144.41, y: 54.39))
        bezierPath.addLine(to: CGPoint(x: 139.96, y: 37.84))
        bezierPath.addLine(to: CGPoint(x: 129.37, y: 21.33))
        bezierPath.addLine(to: CGPoint(x: 110.99, y: 5.12))
        bezierPath.addLine(to: CGPoint(x: 89.29, y: 0.38))
        bezierPath.addLine(to: CGPoint(x: 68.3, y: 0.38))
        bezierPath.close()
        bezierPath.lineCapStyle = .round;
        
        bezierPath.lineJoinStyle = .round;

        return bezierPath
    }
    
    func getDisk() -> UIBezierPath {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 147.06, y: 40.27))
        bezierPath.addLine(to: CGPoint(x: 107.54, y: 0.38))
        bezierPath.addLine(to: CGPoint(x: 9.39, y: 1.49))
        bezierPath.addLine(to: CGPoint(x: 3.96, y: 6.29))
        bezierPath.addLine(to: CGPoint(x: 0.46, y: 11.25))
        bezierPath.addLine(to: CGPoint(x: 0.38, y: 137.58))
        bezierPath.addLine(to: CGPoint(x: 3.41, y: 142.85))
        bezierPath.addLine(to: CGPoint(x: 10.18, y: 147.55))
        bezierPath.addLine(to: CGPoint(x: 135.06, y: 147.63))
        bezierPath.addLine(to: CGPoint(x: 143.14, y: 144.24))
        bezierPath.addLine(to: CGPoint(x: 146.16, y: 136.58))
        bezierPath.addCurve(to: CGPoint(x: 147.06, y: 40.27), controlPoint1: CGPoint(x: 146.16, y: 136.58), controlPoint2: CGPoint(x: 145.58, y: 39.15))
        bezierPath.close()
        bezierPath.lineCapStyle = .round;
        
        bezierPath.lineJoinStyle = .round;
        
        return bezierPath
    }
    
    func getCircle() -> UIBezierPath {
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 50, height: 50))
        return ovalPath
    }
    
    func compositeTwoImages(img: UIImage, newSize: CGSize) -> UIImage? {
        // begin context with new size
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
        // draw images to context
        img.draw(in: CGRect(origin: CGPoint.zero, size: img.size))
        
        let context = UIGraphicsGetCurrentContext()
        
        context!.setFillColor(UIColor.clear.cgColor)
        
        let rect = CGRect(x: (self.center.x / 2) - (newSize.width / 2),  y:(self.center.y / 2) - (newSize.height / 2), width: newSize.width, height: newSize.height)
        
        let strokeColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        
        let bp = bezierPath?.fit(into: rect).moveCenter(to: self.center)
        
        context?.addPath((bp?.cgPath)!)
        context?.clip()
        context?.clear((bp?.bounds)!)
        
        strokeColor.setStroke()
        bp?.lineWidth = 5.0
        bp?.stroke()
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        // returns an optional
        return newImage
    }
    
    @objc func timerFired(timer: Timer) {
        i = CGFloat((CACurrentMediaTime() - transitionStartTime) / duration) * bounds.size.height
        outputSize = CGSize(width: 10 + i, height: 10 + i)
        image = compositeTwoImages(img: bottomImage!, newSize: outputSize!)
        if CACurrentMediaTime() > transitionStartTime + duration {
            image = timer.userInfo as? UIImage
            i = 0.0
            timer.invalidate()
            for vc in (self.transitionContext?.containerView.subviews)! {
                if vc is TransitionImageView2 {
                    vc.removeFromSuperview()
                    viewf?.view.alpha = 1
                }
            }
            self.transitionContext?.completeTransition(true)
        }
    }
}

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
        let center = bound.center
        
        let zeroedTo = CGPoint(x: to.x-bound.origin.x, y: to.y-bound.origin.y)
        let vector = center.vector(to: zeroedTo)
        
        _ = offset(to: CGSize(width: vector.dx, height: vector.dy))
        return self
    }
    
    func offset(to offset:CGSize) -> Self{
        let t = CGAffineTransform(translationX: offset.width, y: offset.height)
        _ = applyCentered(transform: t)
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
        _ = applyCentered(transform: scale)
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

