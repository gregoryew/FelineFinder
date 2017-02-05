import UIKit
import TransitionTreasury

enum DIRECTION {
    case left
    case right
}

class SlideAnimation: NSObject, TRViewControllerAnimatedTransitioning {
    open var transitionStatus: TransitionStatus
    
    open var transitionContext: UIViewControllerContextTransitioning?
    
    open var percentTransition: UIPercentDrivenInteractiveTransition?
    
    private var currentImage: TransitionImageView?
    
    open var completion: (() -> Void)?
    
    open var cancelPop: Bool = false
    
    open var interacting: Bool = false
    
    var dir: DIRECTION
    
    var duration: Double = 1.0
    
    var containView: UIView?
    var fromVC: UIViewController?
    var toVC: UIViewController?
    
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    public init(direction: DIRECTION, status: TransitionStatus = .push) {
        transitionStatus = status
        dir = direction
        super.init()
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        containView = transitionContext.containerView
        
        containView?.addSubview(fromVC!.view)
        containView?.addSubview(toVC!.view)
        
        if dir == .left {
            if transitionStatus == .push {
                let toVCFrame = toVC?.view.frame
                toVC?.view.frame = CGRect(x: -1 * (toVC?.view.frame.width)!, y: 0, width: (toVC?.view.frame.width)!, height: (toVC?.view.frame.height)!)
                UIView.animate(withDuration: 1.0, animations: {
                    self.fromVC?.view.frame = CGRect(x: 2 * (toVCFrame?.width)!, y: 0, width: (self.toVC?.view.frame.width)!, height: (self.toVC?.view.frame.height)!)
                    self.toVC?.view.frame = toVCFrame!
                }, completion: { _ in self.transitionContext?.completeTransition(true)})
            } else {
                UIView.animate(withDuration: 1.0, animations: {
                    self.toVC?.view.frame = CGRect(x: 0, y: 0, width: (self.toVC?.view.frame.width)!, height: (self.toVC?.view.frame.height)!)
                    self.fromVC?.view.frame = CGRect(x: -1 * (self.fromVC?.view.frame.width)!, y: 0, width: (self.fromVC?.view.frame.width)!, height: (self.fromVC?.view.frame.height)!)
                }, completion: { _ in self.transitionContext?.completeTransition(true)})
            }
        } else {
            if transitionStatus == .push {
                let toVCFrame = toVC?.view.frame
                toVC?.view.frame = CGRect(x: 2 * (toVC?.view.frame.width)!, y: 0, width: (toVC?.view.frame.width)!, height: (toVC?.view.frame.height)!)
                UIView.animate(withDuration: 1.0, animations: {
                    self.fromVC?.view.frame = CGRect(x: -1 * (toVCFrame?.width)!, y: 0, width: (self.toVC?.view.frame.width)!, height: (self.toVC?.view.frame.height)!)
                    self.toVC?.view.frame = toVCFrame!
                }, completion: { _ in self.transitionContext?.completeTransition(true)})
            } else {
                UIView.animate(withDuration: 1.0, animations: {
                    self.toVC?.view.frame = CGRect(x: 0, y: 0, width: (self.toVC?.view.frame.width)!, height: (self.toVC?.view.frame.height)!)
                    self.fromVC?.view.frame = CGRect(x: -1 * (self.fromVC?.view.frame.width)!, y: 0, width: (self.fromVC?.view.frame.width)!, height: (self.fromVC?.view.frame.height)!)
                }, completion: { _ in self.transitionContext?.completeTransition(true)})
            }
        }
    }
}
