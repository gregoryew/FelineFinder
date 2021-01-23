//
//  Globals.swift
//  Cat Appz
//
//  Created by Gregory Williams on 8/22/16.
//  Copyright © 2016 Gregory Williams. All rights reserved.
//

import Foundation
//import TransitionTreasury
//import TransitionAnimation
import UIKit
import WebKit

extension UIViewController {
    func setEmojicaLabel(text: String, size: CGFloat = 32.0, fontName: String = "") -> NSAttributedString {
        return NSAttributedString(string: text)
    }
}

extension UICollectionViewCell {
    func setEmojicaLabel(text: String, size: CGFloat = 32.0, fontName: String = "") -> NSAttributedString {
        return NSAttributedString(string: text)
   }
}

extension UITableViewCell {
    func setEmojicaLabel(text: String, size: CGFloat = 32.0, fontName: String = "") -> NSAttributedString {
        return NSAttributedString(string: text)
    }
}

extension UIColor {
    convenience init(hexString hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }

        assert(hexFormatted.count == 6, "Invalid hex code used.")

        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}
@IBDesignable
class TopIconButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let kTextTopPadding:CGFloat = 3.0;
        
        var titleLabelFrame = self.titleLabel!.frame;
        
        
        let labelSize = titleLabel!.sizeThatFits(CGSize(width: self.contentRect(forBounds: self.bounds).width, height: CGFloat.greatestFiniteMagnitude))
        
        var imageFrame = self.imageView!.frame;
        
        let fitBoxSize = CGSize(width: max(imageFrame.size.width, labelSize.width), height: labelSize.height + kTextTopPadding + imageFrame.size.height)
        
        let fitBoxRect = self.bounds.insetBy(dx: (self.bounds.size.width - fitBoxSize.width)/2, dy: (self.bounds.size.height - fitBoxSize.height)/2);
        
        imageFrame.origin.y = fitBoxRect.origin.y;
        imageFrame.origin.x = fitBoxRect.midX - (imageFrame.size.width/2);
        self.imageView!.frame = imageFrame;
        
        // Adjust the label size to fit the text, and move it below the image
        
        titleLabelFrame.size.width = labelSize.width;
        titleLabelFrame.size.height = labelSize.height;
        titleLabelFrame.origin.x = (self.frame.size.width / 2) - (labelSize.width / 2);
        titleLabelFrame.origin.y = fitBoxRect.origin.y + imageFrame.size.height + kTextTopPadding;
        self.titleLabel!.frame = titleLabelFrame;
        self.titleLabel!.textAlignment = .center
    }
    
}

class AppMisc {
    static let USER_ID = NSUUID().uuidString.replacingOccurrences(of: "-", with: "_")
}


enum FilterType {
    case Simple
    case Advanced
}

struct Matrix<T> {
    let rows: Int, columns: Int
    var grid: [T]
    init(rows: Int, columns: Int,defaultValue: T) {
        self.rows = rows
        self.columns = columns
        grid = Array(repeating: defaultValue, count: rows * columns)
    }
    func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    subscript(row: Int, column: Int) -> T {
        get {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
}

extension UIImage {
    var isPortrait:  Bool    { return size.height > size.width }
    var isLandscape: Bool    { return size.width > size.height }
    var breadth:     CGFloat { return min(size.width, size.height) }
    var breadthSize: CGSize  { return CGSize(width: breadth, height: breadth) }
    var breadthRect: CGRect  { return CGRect(origin: .zero, size: breadthSize) }
    var circleMasked: UIImage? {
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait  ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
        UIBezierPath(ovalIn: breadthRect).addClip()
        UIImage(cgImage: cgImage).draw(in: breadthRect)
        return UIGraphicsGetImageFromCurrentImageContext()
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
//var imageCache = [String:UIImage]()  //This is a global image cache
var zipCode: String = ""
var editWhichQuestionGlobal: Int = 0

var filterOptions: filterOptionsListV5 = filterOptionsListV5()
var filterType: FilterType = FilterType.Advanced

var NameID: Int = 0
var currentFilterSave: String = "Touch Here To Load/Save..."
var sortFilter: String = "animalLocationDistance"
var distance = "4000"
var updated = Date()
var rescueGroupsLastQueried = Date()
var viewPopped = false
var viewPoppedFromTabBarToBreeds = false
var globalBreed: Breed?
var sourceViewController: FilterOptionsListTableViewController?
var titleLabelsAlreadyDisplayed = false
var firstTime: Bool = false

typealias filter = Dictionary<String, Any>

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
    var type: Model {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafeMutablePointer(to: &systemInfo.machine) {
            ptr in String(cString: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self))
        }
        let modelMap : [ String : Model ] = [
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

@IBDesignable
class DynamicImageView: UIImageView {

    @IBInspectable var fixedWidth: CGFloat = 0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    @IBInspectable var fixedHeight: CGFloat = 0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        var s = CGSize.zero
        if fixedWidth > 0 && fixedHeight > 0 {
            s.width = fixedWidth
            s.height = fixedHeight
        } else if fixedWidth <= 0 && fixedHeight > 0 {
            if let image = self.image {
                let ratio = fixedHeight / image.size.height
                s.width = image.size.width * ratio - 10
                s.height = fixedHeight
            }
        } else if fixedWidth > 0 && fixedHeight <= 0 {
            s.width = fixedWidth
            if let image = self.image {
                let ratio = fixedWidth / image.size.width
                s.height = image.size.height * ratio
            }
        } else {
            s = image?.size ?? .zero
        }
        return s
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
                let sourceIndex = controllerStack.firstIndex(of: sourceViewController)!
                controllerStack[sourceIndex] = destinationController
                // Assign the updated stack with animation
                navigationController!.setViewControllers(controllerStack, animated:true)
            }
        }
        //
    }
}

extension UIView {
    
    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow()
            }
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            
            // Don't touch the masksToBound property if a shadow is needed in addition to the cornerRadius
            if shadow == false {
                self.layer.masksToBounds = true
            }
        }
    }
    
    /*
    func addShadow(shadowColor: CGColor = UIColor.black.cgColor,
                   shadowOffset: CGSize = CGSize(width: 1.0, height: 2.0),
                   shadowOpacity: Float = 0.4,
                   shadowRadius: CGFloat = 3.0) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
    */
 
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}

// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension String {
    
    subscript (i: Int) -> Character {
        let index1 = self.index(self.startIndex, offsetBy: i)
        //let index = self.startIndex.advanceBy(i)
        return self[index1]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return mid(r.startIndex, amount: r.count - 1)
    }
    
    func URLEncodedString() -> String? {
        let customAllowedSet =  CharacterSet.urlQueryAllowed
        let escapedString = self.addingPercentEncoding(withAllowedCharacters: customAllowedSet)
        return escapedString
    }
    
    static func queryStringFromParameters(_ parameters: Dictionary<String,String>) -> String? {
        if (parameters.count == 0)
        {
            return nil
        }
        var queryString : String? = nil
        for (key, value) in parameters {
            if let encodedKey = key.URLEncodedString() {
                if let encodedValue = value.URLEncodedString() {
                    if queryString == nil
                    {
                        queryString = "?"
                    }
                    else
                    {
                        queryString! += "&"
                    }
                    queryString! += encodedKey + "=" + encodedValue
                }
            }
        }
        return queryString
    }
    
    var isNumber : Bool {
            get{
                return !self.isEmpty && self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
        }
    }
    
    // LEFT
    // Returns the specified number of chars from the left of the string
    // let str = "Hello"
    // print(str.left(3))         // Hel
    func left(_ to: Int) -> String {
        return "\(self[..<self.index(startIndex, offsetBy: to)])"
    }

    // RIGHT
    // Returns the specified number of chars from the right of the string
    // let str = "Hello"
    // print(str.left(3))         // llo
    func right(_ from: Int) -> String {
        return "\(self[self.index(startIndex, offsetBy: self.count-from)...])"
    }

    // MID
    // Returns the specified number of chars from the startpoint of the string
    // let str = "Hello"
    // print(str.left(2,amount: 2))         // ll
    func mid(_ from: Int, amount: Int) -> String {
        let x = "\(self[self.index(startIndex, offsetBy: from)...])"
        return x.left(amount)
    }
    
    func chopPrefix(_ count: Int = 1) -> String {
        return self.right(self.count - count)
    }
    
    func chopSuffix(_ count: Int = 1) -> String {
        return self.left(self.count - count)
    }
}

public extension Collection {

    /// Convert self to JSON String.
    /// Returns: the pretty printed JSON string or an empty string if any error occur.
    func json() -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
            return String(data: jsonData, encoding: .utf8) ?? "{}"
        } catch {
            print("json serialization error: \(error)")
            return "{}"
        }
    }
}

public extension Date {
    static func setToDateTime (dateString: String = "", formatString: String = "yyyy-MM-dd") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatString
        return dateFormatter.date(from: dateString)!
    }
}

var RescueGroupsKey: String {
  get {
    // 1
    guard let filePath = Bundle.main.path(forResource: "FelineFinder-Info", ofType: "plist") else {
      fatalError("Couldn't find file 'FelineFinder-Info.plist'.")
    }
    // 2
    let plist = NSDictionary(contentsOfFile: filePath)
    guard let value = plist?.object(forKey: "RescueGroupsAPI") as? String else {
      fatalError("Couldn't find key 'RescueGroupsAPI' in 'FelineFinder-Info.plist'.")
    }
    return value
  }
}

var YouTubeAPIKey: String {
  get {
    // 1
    guard let filePath = Bundle.main.path(forResource: "FelineFinder-Info", ofType: "plist") else {
      fatalError("Couldn't find file 'FelineFinder-Info.plist'.")
    }
    // 2
    let plist = NSDictionary(contentsOfFile: filePath)
    guard let value = plist?.object(forKey: "YouTubeAPI") as? String else {
      fatalError("Couldn't find key 'YouTubeAPI' in 'FelineFinder-Info.plist'.")
    }
    return value
  }
}

extension UITextField {
    func setIcon(_ image: UIImage) {
        let iconView = UIImageView(frame:
                      CGRect(x: 10, y: 5, width: 20, height: 20))
        iconView.image = image
        let iconContainerView: UIView = UIView(frame:
                      CGRect(x: 20, y: 0, width: 30, height: 30))
        iconContainerView.addSubview(iconView)
        leftView = iconContainerView
        leftViewMode = .always
    }
}

extension UIView {
    // Attaches all sides of the receiver to its parent view
    func coverWholeSuperview(margin: CGFloat = 0.0) {
        let view = superview
        layoutAttachTop(to: view, margin: margin)
        layoutAttachBottom(to: view, margin: margin)
        layoutAttachLeading(to: view, margin: margin)
        layoutAttachTrailing(to: view, margin: margin)

    }

    // Attaches the top of the current view to the given view's top if it's a superview of the current view or to it's bottom if it's not (assuming this is then a sibling view).
    @discardableResult
    func layoutAttachTop(to: UIView? = nil, margin: CGFloat = 0.0) -> NSLayoutConstraint {

        let view: UIView? = to ?? superview
        let isSuperview = view == superview
        let constraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal,
                                            toItem: view, attribute: isSuperview ? .top : .bottom, multiplier: 1.0,
                                            constant: margin)
        superview?.addConstraint(constraint)

        return constraint
    }

    // Attaches the bottom of the current view to the given view
    @discardableResult
    func layoutAttachBottom(to: UIView? = nil, margin: CGFloat = 0.0, priority: UILayoutPriority? = nil) -> NSLayoutConstraint {

        let view: UIView? = to ?? superview
        let isSuperview = (view == superview) || false
        let constraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal,
                                            toItem: view, attribute: isSuperview ? .bottom : .top, multiplier: 1.0,
                                            constant: -margin)
        if let priority = priority {
            constraint.priority = priority
        }
        superview?.addConstraint(constraint)

        return constraint
    }

    // Attaches the leading edge of the current view to the given view
    @discardableResult
    func layoutAttachLeading(to: UIView? = nil, margin: CGFloat = 0.0) -> NSLayoutConstraint {

        let view: UIView? = to ?? superview
        let isSuperview = (view == superview) || false
        let constraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal,
                                            toItem: view, attribute: isSuperview ? .leading : .trailing, multiplier: 1.0,
                                            constant: margin)
        superview?.addConstraint(constraint)

        return constraint
    }

    // Attaches the trailing edge of the current view to the given view
    @discardableResult
    func layoutAttachTrailing(to: UIView? = nil, margin: CGFloat = 0.0, priority: UILayoutPriority? = nil) -> NSLayoutConstraint {

        let view: UIView? = to ?? superview
        let isSuperview = (view == superview) || false
        let constraint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal,
                                            toItem: view, attribute: isSuperview ? .trailing : .leading, multiplier: 1.0,
                                            constant: -margin)
        if let priority = priority {
            constraint.priority = priority
        }
        superview?.addConstraint(constraint)

        return constraint
    }

    // For anchoring View
    struct AnchoredConstraints {
        var top, leading, bottom, trailing, width, height, centerX, centerY: NSLayoutConstraint?
    }
    
    @discardableResult
    func constraints(top: NSLayoutYAxisAnchor? = nil, leading: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil,
                trailing: NSLayoutXAxisAnchor? = nil, padding: UIEdgeInsets = .zero, size: CGSize = .zero,
                centerX: NSLayoutXAxisAnchor? = nil, centerY: NSLayoutYAxisAnchor? = nil,
                centerXOffset: CGFloat = 0, centerYOffset: CGFloat = 0) -> AnchoredConstraints {

        translatesAutoresizingMaskIntoConstraints = false
        var anchoredConstraints = AnchoredConstraints()

        if let top = top {
            anchoredConstraints.top = topAnchor.constraint(equalTo: top, constant: padding.top)
        }

        if let leading = leading {
            anchoredConstraints.leading = leadingAnchor.constraint(equalTo: leading, constant: padding.left)
        }

        if let bottom = bottom {
            anchoredConstraints.bottom = bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom)
        }

        if let trailing = trailing {
            anchoredConstraints.trailing = trailingAnchor.constraint(equalTo: trailing, constant: -padding.right)
        }

        if size.width != 0 {
            anchoredConstraints.width = widthAnchor.constraint(equalToConstant: size.width)
        }

        if size.height != 0 {
            anchoredConstraints.height = heightAnchor.constraint(equalToConstant: size.height)
        }

        if let centerX = centerX {
            anchoredConstraints.centerX = centerXAnchor.constraint(equalTo: centerX, constant: centerXOffset)
        }

        if let centerY = centerY {
            anchoredConstraints.centerY = centerYAnchor.constraint(equalTo: centerY, constant: centerYOffset)
        }

        [anchoredConstraints.top, anchoredConstraints.leading, anchoredConstraints.bottom,
         anchoredConstraints.trailing, anchoredConstraints.width,
         anchoredConstraints.height, anchoredConstraints.centerX,
         anchoredConstraints.centerY].forEach { $0?.isActive = true }

        return anchoredConstraints
    }
}

var questionList: QuestionList = QuestionList()
var Favorites = FavoritesList()
var FitValues = FitValueList()

let INITIAL_DATE = Date.setToDateTime(dateString: "1900-01-01")
let ALL_BREEDS = "All Breeds"
let FAVORITES = "FAVORITES"

let ADOPTABLE_CATS_VC = 1
let FAVORITES_VC = 2

let filterReturned = Notification.Name(rawValue: "filterReturned")
let listReturned = Notification.Name(rawValue: "listReturned")
