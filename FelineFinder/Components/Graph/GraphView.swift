//
//  GraphView.swift
//  segmentedTest5
//
//  Created by Gregory Williams on 11/12/20.
//

import UIKit

class GraphView: UIView {

    var bars = [PercentBarView]() {
        didSet {
            self.addBars()
        }
    }
    
    override init(frame: CGRect) {
      super.init(frame: frame)
      setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      setupView()
    }
    
    func setupView() {
      backgroundColor = .clear
      /*
      let xAxis = GraphXAxisView()
        xAxis.tag = 2
        xAxis.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 34)
        while let x = viewWithTag(2) {
          x.removeFromSuperview()
        }
        addSubview(xAxis)
        */
      addBars()
    }
    
    private func addBars() {
        while let x = viewWithTag(1) {
          x.removeFromSuperview()
        }
        
        for i in 0..<bars.count {
          bars[i].tag = 1
          addSubview(bars[i])
            bars[i].frame = CGRect(x: 0, y: Int(i * (Int(25))), width: Int(frame.size.width - 34), height: 20)
        }
        
        if let lastBar = bars.last {
            frame.size.height = lastBar.frame.maxY + 10
        }
    }
}
