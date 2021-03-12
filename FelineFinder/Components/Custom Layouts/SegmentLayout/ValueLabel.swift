//
//  ValueButton.swift
//  FelineFinder
//
//  Created by Gregory Williams on 1/23/21.
//

import UIKit

class ValueLabel: UILabel {

    var choosen: Bool = false {
        didSet {self.draw(self.frame)}
    }
    
    public override func draw(_ rect: CGRect) {
        let color: UIColor = choosen ? UIColor(red:0.977, green:0.835, blue:0.282, alpha:1.000) :
        UIColor(red:0.875, green:0.875, blue:0.875, alpha:1)
        
        //// General Declarations
        if let context = UIGraphicsGetCurrentContext() {

        //// Group
        //// Rectangle Drawing
        let rectanglePath = UIBezierPath(roundedRect: rect, cornerRadius: 20)
        color.setFill()
        rectanglePath.fill()

        //// Text Drawing
        //let textRect = CGRect(x: 4, y: 7, width: 151, height: 25)
        let textRect = rect
            let textTextContent = NSString(string: text ?? "")
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .center

        let textFontAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.5), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: textStyle]

        let textTextHeight: CGFloat = textTextContent.boundingRect(with: CGSize(width: textRect.width - 20, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: textFontAttributes, context: nil).size.height
            context.saveGState()
            context.clip(to: textRect)
            textTextContent.draw(in: CGRect(x: textRect.minX, y: textRect.minY + (textRect.height - textTextHeight) / 2, width: textRect.width - 20, height: textTextHeight), withAttributes: textFontAttributes)
            context.restoreGState()
        }
    }

}
