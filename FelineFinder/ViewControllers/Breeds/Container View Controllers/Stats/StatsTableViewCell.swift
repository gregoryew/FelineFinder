//
//  StatsTableViewCell.swift
//  FelineFinder
//
//  Created by Gregory Williams on 1/10/21.
//

import UIKit

class StatsTableViewCell: UITableViewCell {

    var breed: Breed?
    
    let GRADIENTS = [UIColor.greenGradient, UIColor.pinkGradient, UIColor.blueGradient, UIColor.yellowGradient, UIColor.orangeGradient, UIColor.blueGradient, UIColor.purpleGradient, UIColor.green3Gradient, UIColor.skyBlueGradient, UIColor.brickRedGradient, UIColor.magentaGradient, UIColor.brownGradient, UIColor.yellowGradient, UIColor.pinkGradient, UIColor.orangeGradient]
    
    func configure(breed: Breed) {
        let statGraphView = GraphView()
        let breedStats = BreedStatList()
        breedStats.getBreedStatList(Int(breed.BreedID), percentageMatch: -1)
        var bars = [PercentBarView]()
        var i = 0
        for stat in breedStats.breedStats {
            let percentBar = PercentBarView()
            if stat.isPercentage {
                percentBar.title = stat.TraitShortDesc
                percentBar.gradient = GRADIENTS[i]
                percentBar.percentToFill = CGFloat(stat.Percent) / 100.0
            } else {
                if stat.TraitShortDesc == "Zodicat" {
                    percentBar.title = "\(stat.Value)"
                } else {
                    percentBar.title = "\(stat.TraitShortDesc):  \(stat.Value)"
                }
                percentBar.gradient = GRADIENTS[i]
                percentBar.percentToFill = 1.0
            }
            bars.append(percentBar)
            i += 1
        }
        self.addSubview(statGraphView)
        statGraphView.frame = self.frame.insetBy(dx: 20, dy: 20)
        statGraphView.frame.origin = CGPoint(x: statGraphView.frame.origin.x, y: statGraphView.frame.origin.y - 30)
        statGraphView.bars.append(contentsOf: bars)
    }
    
}
