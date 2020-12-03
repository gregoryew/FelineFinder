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
    var XOffset = CGFloat(6)
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
        //print("setupView begin")
        //backgroundColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        backgroundColor = .clear
        //tools.append(UIImageView(image: UIImage(named: "Tool_Video")))
        tools.append(UIImageView(image: UIImage(named: "Tool_Photo")))
        tools.append(UIImageView(image: UIImage(named: "Tool_Stats")))
        tools.append(UIImageView(image: UIImage(named: "Tool_Info")))
                
        menuIcon = UIImageView(image: UIImage(named: "Tool_Menu_Inactive"))
        menuIcon.contentMode = .scaleAspectFill
        menuIcon.frame.origin = CGPoint(x: XOffset, y: self.bounds.maxY - self.bounds.height)
        self.originalY = frame.minY
        addSubview(menuIcon)
        
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
        //print("setupView end")
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        //print("handleTap begin")
        menuOpen = !menuOpen
        if menuOpen {
            self.openMenu()
        } else {
            self.closeMenu()
            self.setNeedsDisplay()
        }
    }

    @objc func handleItemTap(_ sender: UITapGestureRecognizer? = nil) {
        //print("handleItemTap being")
        delegate.menuItemChoosen(option: (sender?.view!.tag)!)
        //menuIcon.image = tools[sender!.view!.tag].image
        menuOpen = false
        self.closeMenu()
        self.setNeedsDisplay()
        //print("handleItemTap end")
    }
    
    func openMenu() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
            var y: CGFloat = 10
            for i in 0..<self.tools.count {
                y += self.tools[i].frame.height
                self.tools[i].frame.origin = CGPoint(x: self.XOffset, y: y - self.menuIcon.frame.height)
            }
            let frameWidth = self.menuIcon.frame.width
            self.menuIcon.frame.origin = CGPoint(x: self.XOffset, y: y)
            self.frame = CGRect(x: self.frame.minX, y: self.frame.minY - y, width: frameWidth + 12, height: y + self.menuIcon.frame.height)
            self.setNeedsDisplay()
        }, completion: nil)
    }

    func closeMenu() {
        //print("close menu begin")
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
            for tool in self.tools {
                tool.frame.origin = CGPoint(x: self.XOffset, y: 0)
            }
            self.menuIcon.frame.origin = CGPoint(x: self.XOffset, y: 0)
            self.frame = CGRect(x: self.frame.minX, y: self.originalY, width: self.menuIcon.frame.width + 12, height: self.menuIcon.frame.height)
            //self.setNeedsDisplay()
        }, completion:  { (finished) in
            if finished {
                //print("close menu end")
            }
        })
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        if !menuOpen {
            let rectanglePath = UIBezierPath(rect: rect)
            UIColor.clear.setFill()
            rectanglePath.fill()
            UIColor.white.setStroke()
            rectanglePath.lineWidth = 1
            rectanglePath.stroke()
            return
        }
        
        //// Group
        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: rect.width, height: 45))
        UIColor.white.setFill()
        ovalPath.fill()
        UIColor.white.setStroke()
        ovalPath.lineWidth = 1
        ovalPath.stroke()

        //// Rectangle Drawing
        let rectanglePath = UIBezierPath(rect: CGRect(x: 0, y: 21, width: rect.width, height: rect.height + self.menuIcon.frame.height + 25))
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
