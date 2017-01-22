//
//  BreedStatsViewController.swift
//  Feline Finder
//
//  Created by Gregory Williams on 6/14/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import UIKit

class BreedStatsViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var whichSeque: String = ""
    var breed: Breed = Breed(id: 0, name: "", url: "", picture: "", percentMatch: 0, desc: "", fullPict: "", rbID: "", youTubeURL: "", cats101: "")
    var breedStat: BreedStats = BreedStats(id: 0, desc: "", percent: 0, lowRange: 0, highRange: 0, value: "")
    var breedStats: [BreedStats] = []
    var frameWidth = 0
    var onePart = 0.0
    
    let startpoint=30
    
    let distance=35
    
    var offSet = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = breed.BreedName
        
        frameWidth = (Int(self.view.frame.width) - 40)
        onePart = Double(frameWidth) / Double(100)
        
        
        DatabaseManager.sharedInstance.fetchBreedStatList(Int(breed.BreedID), percentageMatch: Double(breed.PercentMatch)) { (BreedStats) -> Void in
            self.breedStats = BreedStats
        }
        
        
        self.scrollView.backgroundColor = UIColor.gray
        
    }
    
    @IBAction func unwindToPetFinderPictureViewer(_ sender: UIStoryboardSegue)
    {
        //let sourceViewController = sender.sourceViewController
        // Pull any data from the view controller which initiated the unwind segue.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setGradientBackground()
        self.displayStats()
    }
    
    func setGradientBackground() {
        let colorTop =  UIColor.darkGray.cgColor
        let colorBottom = UIColor.lightGray.cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [ colorTop, colorBottom]
        gradientLayer.locations = [ 0.0, 1.0]
        var h = CGFloat(((breedStats.count + 1) * distance) + startpoint + 60)
        if self.view.frame.height > h {h = self.view.frame.height}
        let rect = CGRect(x: 0, y: -60, width: self.view.frame.width, height: h)
        gradientLayer.frame = rect
        
        self.scrollView.layer.addSublayer(gradientLayer)
    }
    
    func displayStats() {
        
        var i = 1;
        
        var dr: Bool = false
        
        if breed.PercentMatch != -1 {
            dr = true
        }
        
        let frameRect = CGRect(x: 0, y: 0, width: frameWidth, height: ((breedStats.count + 1) * distance) + startpoint)
        
        scrollView.contentSize = frameRect.size
        
        let pos = CGPoint(x:20,y:0)
        let lbl = UILabel()
        lbl.frame = CGRect(x: pos.x, y: pos.y - 60, width: 400, height: 18)
        lbl.font = lbl.font.withSize(10)
        lbl.textColor = UIColor.yellow
        lbl.text = "Legend: Purple = Actual ⎟ Pin = Your Preference"
        scrollView.addSubview(lbl)
        
        for breedStat in breedStats {
            i += 1;
            var c: Int = 1
            if (i > breedStats.count / 2) && UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
                c = 2
            }
            if breedStat.Value == "" {
                drawlines(rowNumber:i, columnNumber: c, percent:breedStat.Percent, linename:breedStat.TraitShortDesc, lowRange: breedStat.LowRange, highRange: breedStat.HighRange, drawRange: dr)
            }
            else {
                drawLabel(rowNumber:i, lineLabel:breedStat.TraitShortDesc, lineValue:breedStat.Value, lowRange: Int(breedStat.LowRange), highRange: Int(breedStat.HighRange))
            }
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            (segue.destination as! DetailViewController).breed = breed
        }
        /*
        else if (segue.identifier == "breederList") {
            (segue.destinationViewController as! BreedersViewController).breed = breed
        }
        else if (segue.identifier == "BreederMap") {
            (segue.destinationViewController as! MapViewController).breed = breed
        }
        */
        else if (segue.identifier == "petFinder") {
            let b = self.breed as Breed?
            (segue.destination as! AdoptableCatsViewController).breed = b!
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
            lbl.textColor = UIColor.lightGray
        } else {
            lbl.textColor = UIColor.yellow
        }
        lbl.font = lbl.font.withSize(15)
        lbl.text = "\(label): \(valDesc)"
        scrollView.addSubview(lbl)
    }
    
    func drawlines (rowNumber row:Int, columnNumber col:Int, percent val:Double,linename name:String,lowRange l: Double, highRange h: Double, drawRange dr: Bool){
        
        let start = CGPoint(x:20,y:Int(row*distance)+startpoint - 105)
        let end = CGPoint(x:Int(val*onePart),y:Int(row*distance)+startpoint - 105)
        //first label settings
        let lbl = UILabel()
        lbl.frame = CGRect(x: start.x, y: start.y - 25, width: 200, height: 18)
        lbl.font = lbl.font.withSize(15)
        if ((l == 0.0) && (h == 100.0) && (dr == true)) {
            lbl.textColor = UIColor.lightGray
        } else {
            lbl.textColor = UIColor.yellow
        }
        lbl.text = name
        scrollView.addSubview(lbl)
        
        if ((l == 0.0) && (h == 100.0) && (dr == true)) {
            let lightRed  = UIColor(red:0.537, green:0.412, blue:0.761, alpha:1.0)
            drawLine(startpoint: start, endpoint: end, linecolor: lightRed.cgColor, linewidth:15.0)
        } else {
            //red part of line
            drawLine(startpoint: start, endpoint: end,linecolor: UIColor.purple.cgColor,linewidth:15.0)
        }
        
        //gray part of line
        let nextpt = Double((100.0 - val)*onePart) + Double(val*onePart)
        let nstart = CGPoint(x:Int(val*onePart),y:Int(row*distance)+startpoint - 105)
        let nend = CGPoint(x:Int(nextpt),y:Int(row*distance)+startpoint - 105)
        if ((l == 0.0) && (h == 100.0) && (dr == true)) {
            drawLine(startpoint: nstart, endpoint: nend,linecolor: UIColor.lightGray.cgColor,linewidth:15.0)
        } else {
            drawLine(startpoint: nstart, endpoint: nend, linecolor: UIColor.gray.cgColor,linewidth:15.0)
        }
        
        if !((l == 0.0) && (h == 100.0)) && (dr == true) {
            let myLayer = CALayer()
            let myImage = UIImage(named: "pushPin")?.cgImage
            myLayer.frame = CGRect(x: self.view.frame.width + 30, y: CGFloat(start.y) - 27.0, width: 30.0, height: 30.0)
            myLayer.contents = myImage
            scrollView.layer.addSublayer(myLayer)
            let animation = CABasicAnimation(keyPath: "position.x")
            animation.fromValue = self.view.frame.width + 30
            animation.toValue = CGFloat(l * onePart)
            animation.repeatCount = 1
            animation.duration = 0.5
            myLayer.add(animation, forKey: "position.x")
            myLayer.frame = CGRect(x: CGFloat(l * onePart), y: CGFloat(start.y) - 27.0, width: 30.0, height: 30.0)
        }
    }
    
    
    func drawLine(startpoint start:CGPoint, endpoint end:CGPoint, linecolor color: CGColor , linewidth widthline:CGFloat){
        
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = widthline
        
        scrollView.layer.addSublayer(shapeLayer)
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated:true);
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated:true);
    }

}
