//
//  PercentBarView.swift
//  segmentedTest5
//
//  Created by Gregory Williams on 11/12/20.
//

import UIKit

class PercentBarView: UIView {
    var percentToFill: CGFloat = 1.0
    var title: String = ""
    var gradient: CGGradient = UIColor.pinkGradient
    
    override init(frame: CGRect) {
      super.init(frame: frame)
      setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      setupView()
    }
    
    private func setupView() {
      backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        //// General Declarations
        if let context = UIGraphicsGetCurrentContext() {
            //// Rectangle Drawing
            let grayBar = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), cornerRadius: 10)
            UIColor.gray.setFill()
            grayBar.fill()

            //// Rectangle 2 Drawing
            let percentBar = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: frame.width * CGFloat(percentToFill), height: frame.height), cornerRadius: 10)
            context.saveGState()
            percentBar.addClip()
            
            let percentToFillGradient = CGFloat(frame.width * CGFloat(percentToFill) * 0.5)
            
            context.drawLinearGradient(gradient, start: CGPoint(x: percentToFillGradient, y: -0), end: CGPoint(x: percentToFillGradient, y: frame.height), options: CGGradientDrawingOptions())
 
            context.restoreGState()
            
            //// Text Drawing
            let textRect = CGRect(x: 12, y: 0, width: frame.width, height: 16)
            let textTextContent = NSString(string: title)
            let textStyle = NSMutableParagraphStyle()
            textStyle.alignment = .left

            let textFontAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.labelFontSize), NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.paragraphStyle: textStyle]

            let textTextHeight: CGFloat = textTextContent.boundingRect(with: CGSize(width: textRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: textFontAttributes, context: nil).size.height
            context.saveGState()
            context.clip(to: textRect)
            textTextContent.draw(in: CGRect(x: textRect.minX, y: textRect.minY + (textRect.height - textTextHeight) / 2, width: textRect.width, height: textTextHeight), withAttributes: textFontAttributes)
            context.restoreGState()
        }
    }
}

/*
extension UIColor {
    static let gray = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1.000)

    static let lightPink = UIColor(red: 255.0/255.0, green: 0.0, blue: 255.0/255.0, alpha: 1.000)
    static let darkPink = UIColor.red
    static let pinkGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [darkPink.cgColor, lightPink.cgColor] as CFArray, locations: [0, 1])!
    
    //static let darkGreen2 = UIColor(red: 0/255, green: 203/255, blue: 54/255, alpha: 1.0)
    static let darkGreen2 = UIColor.green
    static let lightGreen2 = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
    static let greenGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [darkGreen2.cgColor, lightGreen2.cgColor] as CFArray, locations: [0, 1])!

    static let darkYellow = UIColor.yellow
    static let lightYellow = UIColor(red: 255.0/255.0, green: 213.0/255.0, blue: 0.0, alpha: 1.0)
    static let yellowGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [darkYellow.cgColor, lightYellow.cgColor] as CFArray, locations: [0, 1])!

    static let darkBlue = UIColor.blue
    static let lightBlue = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
    static let blueGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [darkBlue.cgColor, lightBlue.cgColor] as CFArray, locations: [0, 1])!

    static let darkOrange = UIColor.orange
    static let lightOrange = UIColor(red: 0.996, green: 0.373, blue: 0.584, alpha: 1.000)
    static let orangeGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [darkOrange.cgColor, lightOrange.cgColor] as CFArray, locations: [0, 1])!
}
*/

extension UIColor {
    static let gray = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1.000)

    static let lightPink = UIColor(red: 0.973, green: 0.612, blue: 0.980, alpha: 1.000)
    static let darkPink = UIColor.red //UIColor(red: 0.969, green: 0.125, blue: 0.471, alpha: 1.000)
    static let pinkGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [darkPink.cgColor, lightPink.cgColor] as CFArray, locations: [0, 1])!
    
    //static let darkGreen2 = UIColor(red: 0/255, green: 203/255, blue: 54/255, alpha: 1.0)
    static let darkGreen2 = UIColor.green
    static let lightGreen2 = UIColor(red: 175.0/255.0, green: 242.0/255.0, blue: 139.0/255.0, alpha: 1.0)
    static let greenGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [darkGreen2.cgColor, lightGreen2.cgColor] as CFArray, locations: [0, 1])!

    static let darkYellow = UIColor(red: 240.0/255.0, green: 214.0/255.0, blue: 137.0/255.0, alpha: 1.000)
    static let lightYellow = UIColor.yellow
    //static let lightYellow = UIColor(red: 255.0/255.0, green: 213.0/255.0, blue: 0.0, alpha: 1.0)
    static let yellowGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [darkYellow.cgColor, lightYellow.cgColor] as CFArray, locations: [0, 1])!

    static let darkBlue = UIColor(red: 0.137, green: 0.690, blue: 0.741, alpha: 1.000)
    static let lightBlue = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
    static let blueGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [darkBlue.cgColor, lightBlue.cgColor] as CFArray, locations: [0, 1])!

    static let darkOrange = UIColor.orange //UIColor(red: 0.694, green: 0.196, blue: 0.329, alpha: 1.000)
    static let lightOrange = UIColor.yellow //UIColor(red: 1.000, green: 0.573, blue: 0.282, alpha: 1.000)
    static let orangeGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [darkOrange.cgColor, lightOrange.cgColor] as CFArray, locations: [0, 1])!

    //Breed Trait Stats
    static let lightGray = UIColor(hexString: "545454", alpha: 1.0)
    static let darkBlack = UIColor(hexString: "000000", alpha: 1.0)
    static let grayGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [darkBlack.cgColor, lightGray.cgColor] as CFArray, locations: [0, 1])!

    static let lightPurple = UIColor(hexString: "5354FD", alpha: 1.0)
    static let darkPurple = UIColor(hexString: "0500A8", alpha: 1.0)
    static let purpleGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [darkPurple.cgColor, lightPurple.cgColor] as CFArray, locations: [0, 1])!

    static let lightGreen3 = UIColor(hexString: "53FD54", alpha: 1.0)
    static let darkGreen3 = UIColor(hexString: "04A800", alpha: 1.0)
    static let green3Gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [darkGreen3.cgColor, lightGreen3.cgColor] as CFArray, locations: [0, 1])!

    static let lightSkyBlue = UIColor(hexString: "54FEFE", alpha: 1.0)
    static let darkSkyBlue = UIColor(hexString: "00A9A8", alpha: 1.0)
    static let skyBlueGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [darkSkyBlue.cgColor, lightSkyBlue.cgColor] as CFArray, locations: [0, 1])!

    static let lightBrickRed = UIColor(hexString: "FD5453", alpha: 1.0)
    static let darkBrickRed = UIColor(hexString: "A80100", alpha: 1.0)
    static let brickRedGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [darkBrickRed.cgColor, lightBrickRed.cgColor] as CFArray, locations: [0, 1])!

    static let lightMagenta = UIColor(hexString: "FE53FD", alpha: 1.0)
    static let darkMagenta = UIColor(hexString: "A801A8", alpha: 1.0)
    static let magentaGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [darkMagenta.cgColor, lightMagenta.cgColor] as CFArray, locations: [0, 1])!

    static let lightYellowBrick = UIColor(hexString: "FDFC53", alpha: 1.0)
    static let darkBrown = UIColor(hexString: "A85400", alpha: 1.0)
    static let brownGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [darkBrown.cgColor, lightYellowBrick.cgColor] as CFArray, locations: [0, 1])!

    static let lightGray2 = UIColor(hexString: "545454", alpha: 1.0)
    static let darkGray = UIColor(hexString: "83769C", alpha: 1.0)
    static let grayGradient2 = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [darkGray.cgColor, lightGray2.cgColor] as CFArray, locations: [0, 1])!
}

//Outrun Color Palette
extension UIColor {
    static let outrunYellow = UIColor(red: 1.000, green: 0.988, blue: 0.251, alpha: 1.000)
    static let outrunTan = UIColor(red: 0.980, green: 0.729, blue: 0.380, alpha: 1.000)
    static let outrunOrange = UIColor(red: 1.000, green: 0.506, blue: 0.447, alpha: 1.000)
    static let outrunPink = UIColor(red: 1.000, green: 0.184, blue: 0.663, alpha: 1.000)
    static let outrunNavyBlue = UIColor(red: 0.227, green: 0.341, blue: 0.604, alpha: 1.000)
    static let outrunBlackBlue = UIColor(red: 0.212, green: 0.141, blue: 0.310, alpha: 1.000)
}
