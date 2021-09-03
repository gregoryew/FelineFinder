//
//  GraphXAxisView.swift
//  segmentedTest5
//
//  Created by Gregory Williams on 11/13/20.
//

import UIKit

class GraphXAxisView: UIView {
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
        //General Declarations
        let xAxisOffset = CGFloat(30.0)
        var Labels = [String]()
        Labels.append("Any")
        Labels.append("Low")
        Labels.append("Med-Lo")
        Labels.append("Med")
        Labels.append("Med-Hi")
        Labels.append("High")

        if let context = UIGraphicsGetCurrentContext() {

            //// Bezier Drawing
            let bezierPath = UIBezierPath()
            UIColor.black.setStroke()
            bezierPath.lineWidth = 1
            bezierPath.stroke()

            let spaceBetweenLabels = CGFloat((bounds.size.width - (xAxisOffset * 2)) / CGFloat(Labels.count - 1))
            var tickPosX = xAxisOffset - CGFloat(20)

            //// XAxis
            let xAxis = UIBezierPath()
            xAxis.move(to: CGPoint(x: xAxisOffset - CGFloat(20), y: bounds.size.height - 1))
            xAxis.addLine(to: CGPoint(x: spaceBetweenLabels * CGFloat(Labels.count - 1) + tickPosX, y: bounds.size.height - 1))
            UIColor.black.setStroke()
            xAxis.lineWidth = 3
            xAxis.stroke()
            
            for i in 0..<Labels.count {
                //// tickMark Drawing
                let tickMark = UIBezierPath()
                tickMark.move(to: CGPoint(x: tickPosX, y: bounds.height - 8))
                tickMark.addLine(to: CGPoint(x: tickPosX, y: bounds.height))
                    UIColor.black.setStroke()
                    tickMark.lineWidth = 3
                    tickMark.stroke()

                // tickMarkLabel
                let textWidth = Labels[i].width(withConstrainedHeigth: 40, font: UIFont.systemFont(ofSize: 12))
                let tickMarkLabelRect = CGRect(x: tickPosX, y: 13, width: textWidth + 12, height: 30)
                let tickMarkLabelTextContent = NSString(string: Labels[i])
                let textStyle = NSMutableParagraphStyle()
                    textStyle.alignment = .center

                let textFontAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.paragraphStyle: textStyle]

                let tickMarkLabelTextHeight: CGFloat = tickMarkLabelTextContent.boundingRect(with: CGSize(width: tickMarkLabelRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: textFontAttributes, context: nil).size.height + 12
                context.saveGState()
                //context.clip(to: tickMarkLabelRect)
                tickMarkLabelTextContent.draw(in: CGRect(x: tickMarkLabelRect.minX - (textWidth / 2.0), y: 12, width: textWidth, height: tickMarkLabelTextHeight + 50), withAttributes: textFontAttributes)
                context.restoreGState()
                tickPosX += spaceBetweenLabels //- (Labels[i].width(withConstrainedHeigth: 20, font: UIFont.systemFont(ofSize: 15)) / 2.0)
            }
        }
    }
}
