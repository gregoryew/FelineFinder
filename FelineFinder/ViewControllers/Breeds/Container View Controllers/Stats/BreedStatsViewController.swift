//
//  BreedStatsViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/25/20.
//

import UIKit

class BreedStatsViewController: UIViewController {

    var breed: Breed?
    @IBOutlet weak var statGraphView: GraphView!
    
    let GRADIENTS = [UIColor.greenGradient, UIColor.pinkGradient, UIColor.blueGradient, UIColor.yellowGradient, UIColor.orangeGradient, UIColor.grayGradient, UIColor.purpleGradient, UIColor.green3Gradient, UIColor.skyBlueGradient, UIColor.brickRedGradient, UIColor.magentaGradient, UIColor.brownGradient, UIColor.grayGradient2, UIColor.pinkGradient, UIColor.orangeGradient]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var breedStats = BreedStatList()
        breedStats.getBreedStatList(Int(breed!.BreedID), percentageMatch: -1)
        var bars = [PercentBarView]()
        var i = 0
        for stat in breedStats.breedStats {
            let percentBar = PercentBarView()
            if stat.isPercentage {
                percentBar.title = stat.TraitShortDesc
                percentBar.gradient = GRADIENTS[i]
                percentBar.percentToFill = CGFloat(stat.Percent) / 100.0
            } else {
                percentBar.title = "\(stat.TraitShortDesc):  \(stat.Value)"
                percentBar.gradient = GRADIENTS[i]
                percentBar.percentToFill = 1.0
            }
            bars.append(percentBar)
            i += 1
        }
        statGraphView.bars.append(contentsOf: bars)
    }
    
}
