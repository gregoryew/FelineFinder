//
//  ZoomViewControler.swift
//  Feline Finder
//
//  Created by Gregory Williams on 9/27/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class ZoomAnimationViewController: UIViewController, UIViewControllerTransitioningDelegate, CAAnimationDelegate {
    var operation: UINavigationController.Operation = .push
    private var isLayerBased: Bool {
      return operation == .push
    }
    let animationDuration = 0.5
    //let logo = CatLogoLayer.logoLayer()
}

extension ZoomAnimationViewController: UIViewControllerAnimatedTransitioning {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 2.0
    }
    
    private func getFrom(using transitionContext: UIViewControllerContextTransitioning) -> ZoomAnimationViewController {
        if transitionContext.viewController(forKey: .from) is UITabBarController {
            let tab = transitionContext.viewController(forKey: .from) as! UITabBarController
            return tab.selectedViewController as! ZoomAnimationViewController
        } else {
            return transitionContext.viewController(forKey: .from) as! ZoomAnimationViewController
        }
    }

    private func getTo(using transitionContext: UIViewControllerContextTransitioning) -> UIViewController {
        if transitionContext.viewController(forKey: .to) is UITabBarController {
            return transitionContext.viewController(forKey: .to) as! MainTabBarControllerViewController
        } else {
            return transitionContext.viewController(forKey: .to) as! ZoomAnimationViewController
        }
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        /***** Animation *****/
        //logo.position = CGPoint(x: view.layer.bounds.size.width/2,
        //  y: view.layer.bounds.size.height/2 - 30)
        //logo.fillColor = UIColor.white.cgColor
        //view.layer.addSublayer(logo)

        let fromVC = getFrom(using: transitionContext)
        let toVC = getTo(using: transitionContext)
            
        //let toVC = transitionContext.viewController(forKey: .to) as! ZoomAnimationViewController
        transitionContext.containerView.addSubview(toVC.view)
        toVC.view.frame = transitionContext.finalFrame(for: toVC)
        UIView.animate(withDuration: animationDuration, animations: {
            let animation = CABasicAnimation(keyPath: "transform")
            animation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
            animation.toValue = NSValue(caTransform3D: CATransform3DConcat(
              CATransform3DMakeTranslation(0.0, 0.0, 0.0),
              CATransform3DMakeScale(200.0, 200.0, 5.0)
            ))

            animation.duration = self.animationDuration
            animation.delegate = self
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            animation.timingFunction = CAMediaTimingFunction(name: .easeIn)

            //let maskLayer: CAShapeLayer = CatLogoLayer.logoLayer()
            //maskLayer.position = fromVC.logo.position
            //toVC.view.layer.mask = maskLayer
            //maskLayer.add(animation, forKey: "cat")

            //fromVC.logo.add(animation, forKey: nil)

        }, completion: { (success) in
            // IMPORTANT: Notify UIKit that the transition is complete.
            transitionContext.completeTransition(success)
            let containerView = transitionContext.containerView
            containerView.isUserInteractionEnabled = false
            /*
            for subview2 in UIApplication.shared.keyWindow!.subviews {
                if subview2 is UITransitionView {
                    [subview removeFromSuperview];
                }
            }
            if let window = UIApplication.shared.keyWindow {
                if let viewController = window.rootViewController {
                    window.addSubview(viewController.view)
                }
            }
            */
        })
    }
}
