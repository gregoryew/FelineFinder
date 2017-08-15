//
//  BreedInfoStatsViewController.swift
//  Feline Finder
//
//  Created by gregoryew1 on 7/16/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import UIKit

class BreedInfoStatsViewController: UIViewController {

    @IBOutlet weak var breedInfoScrollView: UIScrollView!
    
    var breedStat: BreedStats = BreedStats(id: 0, desc: "", percent: 0, lowRange: 0, highRange: 0, value: "")
    var breedStats: [BreedStats] = []
    var frameWidth = 0
    var onePart = 0.0
    
    let startpoint=30
    
    let distance=50
    
    var offSet = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DatabaseManager.sharedInstance.fetchBreedStatList(Int((globalBreed?.BreedID)!), percentageMatch: Double((globalBreed?.PercentMatch)!)) { (BreedStats) -> Void in
            self.breedStats = BreedStats
            
            let frameRect = CGRect(x: 0, y: 0, width: self.frameWidth, height: ((self.breedStats.count + 1) * self.distance) + self.startpoint)
            
            self.ticksSliders = []
            
            self.breedInfoScrollView.contentSize = frameRect.size
            
            self.frameWidth = (Int(self.view.frame.width) - 40)
            
            var i = 0
            
            let pos = CGPoint(x:20,y:10)
            let lbl = UILabel()
            lbl.frame = CGRect(x: pos.x, y: pos.y, width: 200, height: 18)
            lbl.font = lbl.font.withSize(10)
            lbl.text = "Blue = Actual, Green/Yellow = Preference"
            self.breedInfoScrollView.addSubview(lbl)

            for breedStat in self.breedStats {
                i += 1;
                var c: Int = 1
                if (i > self.breedStats.count / 2) && UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
                    c = 2
                }
                if breedStat.Value == "" {
                    self.drawlines(rowNumber:i, columnNumber: c, percent:breedStat.Percent, linename:breedStat.TraitShortDesc, lowRange: breedStat.LowRange, highRange: breedStat.HighRange, drawRange: true)
                }
                else {
                    self.drawLabel(rowNumber:i, lineLabel:breedStat.TraitShortDesc, lineValue:breedStat.Value, lowRange: Int(breedStat.LowRange), highRange: Int(breedStat.HighRange))
                }
            }
        }
    }

    var ticksSliders: [TicksSlider] = []
    var labels: [UILabel] = []
    
    func drawLabel(rowNumber row: Int, lineLabel label: String, lineValue valDesc: String, lowRange lr: Int, highRange hr: Int) {
        let pos = CGPoint(x:20,y:Int(row*distance)+startpoint - 105)
        //first label settings
        let lbl = UILabel()
        lbl.frame = CGRect(x: pos.x, y: pos.y - 14, width: 200, height: 18)
        var doesntMatter = false
        switch row {
        case 9: //In-Out Door
            if lr == 0 && hr == 3 {doesntMatter = true}
        case 14: //Build
            if lr == 1 && hr == 7 {doesntMatter = true}
        case 15: //Hair
            if lr == 1 && hr == 7 {doesntMatter = true}
        case 16: //Size
            if lr == 1 && hr == 4 {doesntMatter = true}
        default: doesntMatter = false
        }
        if doesntMatter {
            lbl.textColor = darkTextColor
        } else {
            lbl.textColor = textColor
        }
        lbl.font = lbl.font.withSize(15)
        lbl.text = "\(label): \(valDesc)"
        breedInfoScrollView.addSubview(lbl)
        labels.append(lbl)
    }
    
    func drawlines (rowNumber row:Int, columnNumber col:Int, percent val:Double,linename name:String,lowRange l: Double, highRange h: Double, drawRange dr: Bool){
        
        let start = CGPoint(x:20,y:Int(row*distance)+startpoint - 105)
        _ = CGPoint(x:Int(val*onePart),y:Int(row*distance)+startpoint - 105)
        //first label settings
        let lbl = UILabel()
        lbl.frame = CGRect(x: start.x, y: start.y - 25, width: 200, height: 18)
        lbl.font = lbl.font.withSize(15)
        if ((l == 0.0) && (h == 100.0) && (dr == true)) {
            lbl.textColor = darkTextColor
        } else {
            lbl.textColor = textColor
        }
        lbl.text = name
        breedInfoScrollView.addSubview(lbl)
        
        let currentTick = TicksSlider(frame: CGRect.zero)
        
        currentTick.knobVisible = false
        
        breedInfoScrollView.addSubview(currentTick)
        //ticksSlider.addTarget(self, action: #selector(sliderValueDidChanged), for: .valueChanged)
        currentTick.maximumValue = 5
        currentTick.value = h / 20.0
        currentTick.statValue = val / 20.0
        
        currentTick.isUserInteractionEnabled = false
        ticksSliders.append(currentTick)
        labels.append(lbl)
        
    }
    
    override func viewDidLayoutSubviews() {
        let margin: CGFloat = 22.0
        let width = view.bounds.width - 2 * margin
        
        var i = 0
        
        var y = margin
        
        for t: TicksSlider in ticksSliders {
            y += margin
            labels[i].frame = CGRect(x: margin, y: y, width: width, height: labels[i].frame.size.height)
            y += labels[i].frame.size.height + 10
            t.frame = CGRect(x: margin, y: y, width: width, height: 1.5 * margin)
            y += 1.5 * margin
            i += 1
        }
        
        i = 8
        
        while i < 10 {
            y += labels[i].frame.size.height + 10
            labels[i].frame = CGRect(x: margin, y: y, width: width, height: labels[i].frame.size.height)
            i += 1
        }
        
        self.breedInfoScrollView.contentSize = CGSize(width: width, height: labels.last!.frame.maxY + labels.last!.frame.size.height + CGFloat(10.0))
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}
