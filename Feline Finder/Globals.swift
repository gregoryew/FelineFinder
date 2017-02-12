//
//  Globals.swift
//  Cat Appz
//
//  Created by Gregory Williams on 8/22/16.
//  Copyright © 2016 Gregory Williams. All rights reserved.
//

import Foundation
import TransitionTreasury
import TransitionAnimation

enum DemoTransition {
    case FadePush
    case TwitterPresent
    case SlideTabBar
    case CIZoom(transImage: transitionImage)
    case Flip
    case Slide(direction: DIRECTION)
    //case Zoom(startingRect: CGRect, endingRect: CGRect)
}

extension DemoTransition: TransitionAnimationable {
    func transitionAnimation() -> TRViewControllerAnimatedTransitioning {
        switch self {
        case .FadePush:
            return FadeTransitionAnimation()
        case .TwitterPresent :
            return TwitterTransitionAnimation()
        case .SlideTabBar :
            return SlideTransitionAnimation()
        case let .CIZoom(transitionImage) :
            return CIZoomAnimation(transImage: transitionImage)
        case .Flip :
            return FlipAnimation()
        case let .Slide(dir) :
            return SlideAnimation(direction: dir)
        //case let .Zoom(startingRect, endingRect):
        //    return ZoomAnimation(startingRect: startingRect, endingRect: endingRect)
        }
    }
}

extension UINavigationController {
    
    func viewControllerWithClass(_ aClass: AnyClass) -> UIViewController? {
        
        for vc in self.viewControllers {
            
            if vc.isMember(of: aClass) {
                
                return vc
            }
        }
        
        return nil
    }
}

let textColor = UIColor.black //UIColor(red: 255/255, green: 243/255, blue: 0/255, alpha: 1)
let darkTextColor = UIColor.black //UIColor(red: 154/255, green: 217/255, blue: 47/255, alpha: 1)
let lightBackground = UIColor.white //UIColor(red: 1/255, green: 168/255, blue: 188/255, alpha: 1)
let darkBackground = UIColor.blue //UIColor(red: 128/255, green: 74/255, blue: 187/255, alpha: 1)
let headerLightColor = UIColor.blue
let headerDarkColor = UIColor.darkGray
//let darkBackground = UIColor(red: 0, green: 0, blue: 131/255, alpha: 1)
let hiliteColor = UIColor.lightGray //UIColor.cyan

var whichSegueGlobal = ""
var cameFromFiltering = false
var imageCache = [String:UIImage]()  //This is a global image cache
var zipCode: String = ""
var zipCodeGlobal: String = ""
var bnGlobal: String = ""
var editWhichQuestionGlobal: Int = 0
var filterOptions: filterOptionsList = filterOptionsList()
var NameID: Int = 0
var currentFilterSave: String = "Touch Here To Load/Save..."
var sortFilter: String = "animalLocationDistance"
var distance = "4000"
var updated = Date()
var rescueGroupsLastQueried = Date()
var viewPopped = false
var globalBreed: Breed?

// 1. Declare outside class definition (or in its own file).
// 2. UIKit must be included in file where this code is added.
// 3. Extends UIDevice class, thus is available anywhere in app.
//
// Usage example:
//
//    if UIDevice().type == .simulator {
//       print("You're running on the simulator... boring!")
//    } else {
//       print("Wow! Running on a \(UIDevice().type.rawValue)")
//    }

typealias filter = Dictionary<String, AnyObject>

public enum DataSource: String {
    case PetFinder      = "PetFinder"
    case RescueGroup    = "RescueGroup"
}

public enum Model : String {
    case simulator = "simulator/sandbox",
    iPod1          = "iPod 1",
    iPod2          = "iPod 2",
    iPod3          = "iPod 3",
    iPod4          = "iPod 4",
    iPod5          = "iPod 5",
    iPad2          = "iPad 2",
    iPad3          = "iPad 3",
    iPad4          = "iPad 4",
    iPhone4        = "iPhone 4",
    iPhone4S       = "iPhone 4S",
    iPhone5        = "iPhone 5",
    iPhone5S       = "iPhone 5S",
    iPhone5C       = "iPhone 5C",
    iPadMini1      = "iPad Mini 1",
    iPadMini2      = "iPad Mini 2",
    iPadMini3      = "iPad Mini 3",
    iPadAir1       = "iPad Air 1",
    iPadAir2       = "iPad Air 2",
    iPhone6        = "iPhone 6",
    iPhone6plus    = "iPhone 6 Plus",
    iPhone6S       = "iPhone 6S",
    iPhone6Splus   = "iPhone 6S Plus",
    unrecognized   = "?unrecognized?"
}

public extension UIDevice {
    public var type: Model {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafeMutablePointer(to: &systemInfo.machine) {
            ptr in String(cString: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self))
        }
        var modelMap : [ String : Model ] = [
            "i386"      : .simulator,
            "x86_64"    : .simulator,
            "iPod1,1"   : .iPod1,
            "iPod2,1"   : .iPod2,
            "iPod3,1"   : .iPod3,
            "iPod4,1"   : .iPod4,
            "iPod5,1"   : .iPod5,
            "iPad2,1"   : .iPad2,
            "iPad2,2"   : .iPad2,
            "iPad2,3"   : .iPad2,
            "iPad2,4"   : .iPad2,
            "iPad2,5"   : .iPadMini1,
            "iPad2,6"   : .iPadMini1,
            "iPad2,7"   : .iPadMini1,
            "iPhone3,1" : .iPhone4,
            "iPhone3,2" : .iPhone4,
            "iPhone3,3" : .iPhone4,
            "iPhone4,1" : .iPhone4S,
            "iPhone5,1" : .iPhone5,
            "iPhone5,2" : .iPhone5,
            "iPhone5,3" : .iPhone5C,
            "iPhone5,4" : .iPhone5C,
            "iPad3,1"   : .iPad3,
            "iPad3,2"   : .iPad3,
            "iPad3,3"   : .iPad3,
            "iPad3,4"   : .iPad4,
            "iPad3,5"   : .iPad4,
            "iPad3,6"   : .iPad4,
            "iPhone6,1" : .iPhone5S,
            "iPhone6,2" : .iPhone5S,
            "iPad4,1"   : .iPadAir1,
            "iPad4,2"   : .iPadAir2,
            "iPad4,4"   : .iPadMini2,
            "iPad4,5"   : .iPadMini2,
            "iPad4,6"   : .iPadMini2,
            "iPad4,7"   : .iPadMini3,
            "iPad4,8"   : .iPadMini3,
            "iPad4,9"   : .iPadMini3,
            "iPhone7,1" : .iPhone6plus,
            "iPhone7,2" : .iPhone6,
            "iPhone8,1" : .iPhone6S,
            "iPhone8,2" : .iPhone6Splus
        ]
        
        if let model = modelMap[modelCode] {
            return model
        }
        return Model.unrecognized
    }
}

extension String
{
    func chopPrefix(_ count: Int = 1) -> String {
        return self.substring(from: self.characters.index(self.startIndex, offsetBy: count))
    }
    
    func chopSuffix(_ count: Int = 1) -> String {
        return self.substring(to: self.characters.index(self.endIndex, offsetBy: -count))
    }
}

class CustomSegue: UIStoryboardSegue {
    override func perform() {
        //self.sourceViewController.presentViewController(self.destinationViewController as! UIViewController, animated: false, completion: nil)
        
        let sourceViewController = self.source
        let destinationController = self.destination
        let navigationController = sourceViewController.navigationController
        
        // Get a changeable copy of the stack
        //var controllerStack: NSMutableArray = NSMutableArray(array: navigationController!.viewControllers)
        // Replace the source controller with the destination controller, wherever the source may be
        //controllerStack.replaceObjectAtIndex(controllerStack.indexOfObject(sourceViewController), withObject: destinationController)
        if navigationController != nil {
            if navigationController!.viewControllers.count != 0 {
                var controllerStack: [UIViewController] = navigationController!.viewControllers
                let sourceIndex = controllerStack.index(of: sourceViewController)!
                controllerStack[sourceIndex] = destinationController
                // Assign the updated stack with animation
                navigationController!.setViewControllers(controllerStack, animated:true)
            }
        }
        //
    }
}
