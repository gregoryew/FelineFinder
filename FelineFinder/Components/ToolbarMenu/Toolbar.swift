//
//  Toolbar.swift
//  segmentedTest5
//
//  Created by Gregory Williams on 11/12/20.
//

import UIKit

protocol toolBar {
    func menuItemChoosen(option: Int)
}

class Toolbar: UIView {
    var tools = [UIImageView]()
    var inset = CGFloat(10)
    var menuIcon = UIImageView()
    var menuOpen: Bool = false
    var originalY = CGFloat(0)
    var xOffset = CGFloat(10)
    var delegate: toolBar!
    
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
        tools.append(UIImageView(image: UIImage(named: "Tool_Video")))
        tools.append(UIImageView(image: UIImage(named: "Tool_Photo")))
        tools.append(UIImageView(image: UIImage(named: "Tool_Stats")))
        tools.append(UIImageView(image: UIImage(named: "Tool_Info")))
                
        menuIcon = UIImageView(image: UIImage(named: "Tool_Menu_Inactive"))
        menuIcon.contentMode = .scaleAspectFill
        menuIcon.frame.origin = CGPoint(x: 5, y: self.bounds.maxY - self.bounds.height)
        addSubview(menuIcon)
        bounds = menuIcon.bounds
        
        for tool in tools {
            addSubview(tool)
            sendSubviewToBack(tool)
            tool.frame = menuIcon.frame
        }

        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        menuIcon.addGestureRecognizer(tap)
        menuIcon.isUserInteractionEnabled = true
        
        for i in 0..<tools.count {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleItemTap(_:)))
            tools[i].addGestureRecognizer(tap)
            tools[i].tag = i
            tools[i].isUserInteractionEnabled = true
        }
    }
 

    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        menuOpen = !menuOpen
        if menuOpen {
            self.openMenu()
        } else {
            self.closeMenu()
        }
    }

    @objc func handleItemTap(_ sender: UITapGestureRecognizer? = nil) {
        delegate.menuItemChoosen(option: (sender?.view!.tag)!)
        menuIcon.image = tools[sender!.view!.tag].image
        self.closeMenu()
        menuOpen = false
    }
    
    func openMenu() {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            var y: CGFloat = 10
            for i in 0..<self.tools.count {
                y += self.tools[i].frame.height
                self.tools[i].frame.origin = CGPoint(x: 5, y: y - self.menuIcon.frame.height)
            }
            let frameWidth = self.menuIcon.frame.width
            self.menuIcon.frame.origin = CGPoint(x: 5, y: y)
            self.originalY = self.frame.minY
            self.frame = CGRect(x: self.frame.minX, y: self.frame.minY - y, width: frameWidth + 12, height: y + self.menuIcon.frame.height)
            self.setNeedsDisplay()
        }, completion: nil)
    }

    func closeMenu() {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            for tool in self.tools {
                tool.frame.origin = CGPoint(x: 5, y: 0)
            }
            self.frame = CGRect(x: self.frame.minX, y: self.originalY, width: self.menuIcon.frame.width + 12, height: self.menuIcon.frame.height)
            self.menuIcon.frame.origin = CGPoint(x: 5, y: 0)
            self.setNeedsDisplay()
        }, completion: nil)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        if !menuOpen {return}
        
        //// Group
        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: rect.width, height: 85))
        UIColor.white.setFill()
        ovalPath.fill()
        UIColor.white.setStroke()
        ovalPath.lineWidth = 1
        ovalPath.stroke()

        //// Rectangle Drawing
        let rectanglePath = UIBezierPath(rect: CGRect(x: 0, y: 51, width: rect.width, height: rect.height + self.menuIcon.frame.height))
        UIColor.white.setFill()
        rectanglePath.fill()
        UIColor.white.setStroke()
        rectanglePath.lineWidth = 1
        rectanglePath.stroke()

        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0, y: 51))
        bezierPath.addLine(to: CGPoint(x: rect.width, y: 51))
        UIColor.white.setFill()
        bezierPath.fill()
        UIColor.white.setStroke()
        bezierPath.lineWidth = 3.5
        bezierPath.stroke()
    }
}
