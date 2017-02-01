//
//  Fade2Animation.swift
//  Example
//
//  Created by gregoryew1 on 1/28/17.
//  Copyright © 2017 com.transitiontreasury. All rights reserved.
//

import UIKit
import TransitionTreasury
import CoreImage

enum transitionImage {
    case heart
    case cat
    case search
    case save
    case list
    case zoom
}

class CIZoomAnimation: NSObject, TRViewControllerAnimatedTransitioning {
    open var transitionStatus: TransitionStatus
    
    open var transitionContext: UIViewControllerContextTransitioning?
    
    open var percentTransition: UIPercentDrivenInteractiveTransition?
    
    private var currentImage: TransitionImageView?
    
    private var transImage: transitionImage?
    
    open var completion: (() -> Void)?
    
    open var cancelPop: Bool = false
    
    open var interacting: Bool = false
    
    var duration: Double = 1.0
    
    var containView: UIView?
    var fromVC: UIViewController?
    var toVC: UIViewController?
    
    private var transitionStartTime: CFTimeInterval = 0.0
    private var transitionTimer: Timer?
    
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    public init(transImage: transitionImage, status: TransitionStatus = .push) {
        transitionStatus = status
        self.transImage = transImage
        super.init()
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        
        containView = transitionContext.containerView
        
        containView?.addSubview(fromVC!.view)
        containView?.addSubview(toVC!.view)
        
        if transitionStatus == TransitionStatus.push {
            let fromImage: UIImage?
            if fromVC is TitleScreenViewController {
                fromImage = UIImage(named: "titlescreen.png")
            } else {
                fromImage = UIImage.imageWithView(view: (fromVC?.view)!)
            }
        
            let img = UIImage(named: "background4.jpg")

            let container = transitionContext.containerView
            currentImage?.tag = 1
            currentImage = TransitionImageView()
            currentImage?.frame = (fromVC?.view.frame)!
            currentImage?.image = fromImage
            container.addSubview(currentImage!)
            
            currentImage?.transitionToImage(toImage: img, transContext: transitionContext, vc: toVC!, transImage: transImage!)
        } else {
            toVC!.view.layer.opacity = 0
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut, animations: {
                self.toVC!.view.layer.opacity = 1
            }){ finished in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                if !self.cancelPop {
                    if finished {
                        self.completion?()
                        self.completion = nil
                    }
                }
            }
        }
    }
}

extension UIImage {
    class func imageWithView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        //UIGraphicsBeginImageContext(view.bounds.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return image!
    }
}

