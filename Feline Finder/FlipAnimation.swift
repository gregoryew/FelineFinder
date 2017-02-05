import UIKit
import TransitionTreasury

class FlipAnimation: NSObject, TRViewControllerAnimatedTransitioning {
    open var transitionStatus: TransitionStatus
    
    open var transitionContext: UIViewControllerContextTransitioning?
    
    open var percentTransition: UIPercentDrivenInteractiveTransition?
    
    private var currentImage: TransitionImageView?
    
    open var completion: (() -> Void)?
    
    open var cancelPop: Bool = false
    
    open var interacting: Bool = false
    
    var duration: Double = 1.0
    
    var containView: UIView?
    var fromVC: UIViewController?
    var toVC: UIViewController?
    
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    public init(status: TransitionStatus = .push) {
        transitionStatus = status
        super.init()
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        containView = transitionContext.containerView
        
        containView?.addSubview(fromVC!.view)
        containView?.addSubview(toVC!.view)
        
        if transitionStatus == .push {
        UIView.transition(from: (fromVC?.view)!, to: (toVC?.view)!, duration: 1, options: UIViewAnimationOptions.transitionFlipFromRight, completion: nil)
        } else {
            UIView.transition(from: (fromVC?.view)!, to: (toVC?.view)!, duration: 1, options: UIViewAnimationOptions.transitionFlipFromLeft, completion: nil)
        }
        self.transitionContext?.completeTransition(true)
    }
}
