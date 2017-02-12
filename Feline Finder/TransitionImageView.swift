import UIKit
import CoreImage

var whichVC = "second"

class TransitionImageView: UIImageView {
    
    @IBInspectable var duration: Double = 1.0
    //@IBInspectable var maskImage = UIImage(named: "pawMask.jpg")
    @IBInspectable var maskImage = UIImage(named: "background3.jpg")

    
    //private let filter = CIFilter(name: "CICopyMachineTransition")!
    private let filter = CIFilter(name: "CIDisintegrateWithMaskTransition")!
    //private let filter = CIFilter(name: "CIFlashTransition")!
    //private let filter = CIFilter(name: "CISwipeTransition")!
    //private let filter = CIFilter(name: "CIDissolveTransition")!
    //private let filter = CIFilter(name: "CIFlashTransition")!
    //private let filter = CIFilter(name: "CIModTransition")!
    //private let filter = CIFilter(name: "CIRippleTransition")!
    //private let filter = CIFilter(name: "CIPageCurlWithShadowTransition")!
    //private let filter = CIFilter(name: "CIBarsSwipeTransition")!
    //private let filter = CIFilter(name: "CIBarsSwipeTransition")!
    //private let filter = CIFilter(name: "CIAccordionFoldTransition")!


    
    
    private var transitionStartTime: CFTimeInterval = 0.0
    private var transitionTimer: Timer?
    
    weak var transitionContext: UIViewControllerContextTransitioning?
    weak var viewc: UIViewController?
    
    var i: CGFloat = 0.0
    var topImage: UIImage?
    var bottomImage: UIImage?
    var outputSize: CGSize?
    var transImage: transitionImage?
    
    func transitionToImage(toImage: UIImage?, transContext: UIViewControllerContextTransitioning?, vc: UIViewController, transImage: transitionImage) {
        
        
        /*guard let image = image, let toImage = toImage, let maskImage = maskImage  else {
            fatalError("You need to have set an image, provide a new image and a mask to fire up a transition")
        }*/
        
        //topImage = UIImage(named: "HeartMask.jpg")
        switch transImage {
        case .cat: maskImage = UIImage(named: "coolcatMask.jpg")
        case .heart: maskImage = UIImage(named: "heartMask.jpg")
        case .list: maskImage = UIImage(named: "listMask.jpg")
        case .save: maskImage = UIImage(named: "saveMask.jpg")
        case .search: maskImage = UIImage(named: "searchMask.jpg")
        case .zoom: maskImage = UIImage(named: "zoomMask.jpg")
        }
        outputSize = topImage?.size
        bottomImage = UIImage(named: "background3.jpg")
        
        topImage = maskImage
        guard let image = image, let toImage = toImage  else {
            fatalError("You need to have set an image, provide a new image and a mask to fire up a transition")
        }
        
        filter.setValue(CIImage(image: maskImage!), forKey: kCIInputMaskImageKey)
        //filter.setValue(CIImage(image: maskImage), forKey: "inputBacksideImage")
        //filter.setValue(CIImage(image: toImage), forKey: kCsIInputShadingImageKey)
        filter.setValue(CIImage(image: image),  forKey: kCIInputImageKey)
        filter.setValue(CIImage(image: toImage),  forKey: kCIInputTargetImageKey)
        //filter.setValue(50,  forKey: "inputNumberOfFolds")
        
        if let timer = transitionTimer, timer.isValid {
            timer.invalidate()
        }
        
        viewc = vc
        
        transitionContext = transContext
        
        transitionStartTime = CACurrentMediaTime()
        
        transitionTimer = Timer(timeInterval: 1.0/30.0,
                                target: self, selector: #selector(timerFired(timer:)),
                                  userInfo: toImage,
                                  repeats: true)
        RunLoop.current.add(transitionTimer!, forMode: RunLoopMode.defaultRunLoopMode)
        
    }
    
    func compositeTwoImages(top: UIImage, bottom: UIImage, newSize: CGSize) -> UIImage? {
        // begin context with new size
        UIGraphicsBeginImageContextWithOptions(bottom.size, false, 0.0)
        // draw images to context
        bottom.draw(in: CGRect(origin: CGPoint.zero, size: bottom.size))
        top.draw(in: CGRect(origin: CGPoint(x: ((bottom.size.width)/2 - newSize.width/2), y: ((bottom.size.height)/2 - newSize.height/2) ), size: newSize))
        // return the new image
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        // returns an optional
        return newImage
    }
    
    func timerFired(timer: Timer) {
        i = CGFloat((CACurrentMediaTime() - transitionStartTime) / duration) * bottomImage!.size.height
        //i += 40.0
        var mi: UIImage?
        outputSize = CGSize(width: (topImage?.size.width)! + i, height: (topImage?.size.height)! + i)
        if let finalImage = compositeTwoImages(top: topImage!, bottom: bottomImage!, newSize: outputSize!) {
            mi = finalImage
        }
        let progress = (CACurrentMediaTime() - transitionStartTime) / duration
        filter.setValue(CIImage(image: mi!), forKey: kCIInputMaskImageKey)
        filter.setValue(progress, forKey: kCIInputTimeKey)
        image = UIImage(ciImage: filter.outputImage!,
                        scale: UIScreen.main.scale,
                        orientation: UIImageOrientation.up)
        if CACurrentMediaTime() > transitionStartTime + duration {
            image = timer.userInfo as? UIImage
            i = 0.0
            timer.invalidate()
            for vc in (self.transitionContext?.containerView.subviews)! {
                if vc is TransitionImageView {
                    vc.removeFromSuperview()
                }
            }
            self.transitionContext?.completeTransition(true)
        }
    }
}
