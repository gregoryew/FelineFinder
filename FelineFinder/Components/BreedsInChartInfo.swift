//
//  BreedsInChartInfo.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/14/20.
//

import UIKit

struct breedInChartInfo {
    var breedID: Int?
    var percents = [CGFloat]()
    var title: String?
    var gradient: CGGradient?
    var color: UIColor?
    var imageName: String?
    
    init(id: Int, title: String, gradient: CGGradient, color: UIColor, percents: [CGFloat], imageName: String) {
        self.breedID = id
        self.percents = percents
        self.title = title
        self.gradient = gradient
        self.color = color
        self.imageName = imageName
    }
}

class BreedsInChartInfo {
    var breeds = [breedInChartInfo]()
    func addBreed (id: Int, percents: [CGFloat], title: String, gradient: CGGradient, color: UIColor, imageName: String) {
        breeds.append(breedInChartInfo(id: id, title: title, gradient: gradient, color: color, percents: percents, imageName: imageName))
    }
    func removeBreed(id: Int) {
        breeds.removeAll { (breed) -> Bool in
            return breed.breedID == id
        }
    }
    func getBreed(id: Int) -> breedInChartInfo? {
        return breeds.first { (breed) -> Bool in
            return breed.breedID == id
        }
    }
    func getBreedPos(id: Int) -> Int? {
        return breeds.firstIndex { (breed) -> Bool in
            return breed.breedID == id
        }
    }
    func getBars(id: Int) -> [PercentBarView]? {
        var bars = [PercentBarView]()
        for breed in breeds {
            let percentBar = PercentBarView()
            percentBar.title = breed.title ?? ""
            percentBar.gradient = breed.gradient!
            percentBar.percentToFill = breed.percents[id]
            bars.append(percentBar)
        }
        return bars
    }
    subscript(index: Int) -> breedInChartInfo? {
        guard index > 0 && index < breeds.count else {return nil}
        return breeds[index]
    }
    var count: Int {return breeds.count}
}

