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

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let duration = 0.5
  var presenting = true
  var originFrame = CGRect.zero

  var dismissCompletion: (()->Void)?

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return duration
  }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        var toVC: UITabBarController!
        var toView: UIView!
        var fromVC: UITabBarController!
        var fromView: UIView!
        if presenting {
            toView = transitionContext.view(forKey: .to)!
            fromVC = transitionContext.viewController(forKey: .from)! as? UITabBarController
            fromView = fromVC!.selectedViewController!.view
        } else {
            toView = transitionContext.view(forKey: .from)!
            toVC = transitionContext.viewController(forKey: .to)! as? UITabBarController
            fromView = toVC.selectedViewController!.view
            fromView.tag = 222
        }
        
        var initialFrame: CGRect?
        var finalFrame: CGRect?
        
        if presenting {
            
            let toVC = transitionContext.viewController(forKey: .to) as! MainTabAdoptableCatsDetailViewController
            
            toVC.photo.alpha = 0
            toVC.PetName.alpha = 0
            toVC.breed.alpha = 0
            toVC.heart.alpha = 0
            toVC.location.alpha = 0
            toVC.mediaToolBar.alpha = 0
            toVC.stats.alpha = 0
            toVC.toolsToolBar.alpha = 0
            
            var rect = toVC.photo.frame
            
            selectedImage.contentMode = toVC.photo.contentMode

            rect.origin.y += 80

            initialFrame = presenting ? selectedImage.frame : rect
            finalFrame = presenting ? rect : selectedImage.frame
            
            selectedImage.frame = initialFrame!
            selectedImage.cornerRadius = 40

        } else {
            fromView.alpha = 0
        }
                
        if presenting {
            containerView.addSubview(toView)
            selectedImage.tag = 101
            containerView.addSubview(selectedImage)
            containerView.bringSubviewToFront(selectedImage)
        } else {
            containerView.addSubview(fromView)
        }
        
        UIView.animate(withDuration: duration, delay:0.0,
                     usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0,
                     animations: {
                        if !self.presenting {
                            fromView.alpha = 1
                        } else {
                            selectedImage.frame = finalFrame!
                        }
      }, completion: { _ in
        if self.presenting {
            //containerView.viewWithTag(101)?.removeFromSuperview()
            let toVC = transitionContext.viewController(forKey: .to) as! MainTabAdoptableCatsDetailViewController
            toVC.photo.alpha = 1
        
            UIView.animate(withDuration: 0.25, delay:0.0,
                     animations: {
                            toVC.photo.alpha = 1
                            toVC.PetName.alpha = 1
                            toVC.breed.alpha = 1
                            toVC.heart.alpha = 1
                            toVC.location.alpha = 1
                            toVC.mediaToolBar.alpha = 1
                            toVC.stats.alpha = 1
                            toVC.toolsToolBar.alpha = 1
                     }, completion: nil)
            selectedImage.isHidden = true
            transitionContext.completeTransition(true)
        } else {
            //let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            //let viewToShow = storyboard.instantiateViewController(withIdentifier: "AdoptList") as! MainTabAdoptableCatsCollectionViewViewController
            var vcs = [UIViewController]()
            vcs.append((containerView.viewWithTag(222)?.findViewController())!)
            containerView.viewWithTag(222)?.removeFromSuperview()
            vcs.append(contentsOf: toVC.viewControllers![1...toVC.viewControllers!.count - 1])
            self.dismissCompletion?()
            transitionContext.completeTransition(true)
            vcs[0].view.isHidden = false
            vcs[0].view.alpha = 1
            toVC.setViewControllers(vcs, animated: false)
            toVC.selectedIndex = 1
            toVC.selectedIndex = 0
        }
      })
    }
}
