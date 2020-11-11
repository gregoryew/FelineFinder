//
//  BreedStats.swift
//  Feline Finder
//
//  Created by Gregory Williams on 6/14/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation

struct BreedStats {
    let BreedID: Int32
    let TraitShortDesc: String
    let Percent: Double
    let LowRange: Double
    let HighRange: Double
    let Value: String
    init(id: Int32, desc: String, percent: Double, lowRange: Double, highRange: Double, value: String) {
        BreedID = id
        TraitShortDesc = desc
        Percent = percent
        LowRange = lowRange
        HighRange = highRange
        Value = value
    }
    static func getDescription(_ d: String, p: Double) -> String {
        var v: String = ""
        switch d {
        case "Build":
            switch p {
            case 1: v = "Oriental"
            case 2: v = "Foreign"
            case 3: v = "Semi-Foreign"
            case 4: v = "Semi-Coby"
            case 5: v = "Cobby"
            case 6: v = "Substantial"
            default: v = ""
            }
        case "Type of Hair":
            switch p {
            case 1: v = "Hairless"
            case 2: v = "Short"
            case 3: v = "Rex"
            case 4: v = "Medium"
            case 5: v = "Long hair"
            case 6: v = "Short/Long Hair"
            default: v = ""
            }
        case "Size":
            switch p {
            case 1: v = "Small"
            case 2: v = "Average"
            case 3: v = "Biggish"
            default: v = ""
            }
        case "In/Outdoors":
            switch p {
            case 1: v = "Indoor"
            case 2: v = "Both"
            case 3: v = "Outdoor"
            default: v = ""
            }
        default: v = ""
        }
        return v
    }
}

struct response {
    var percentAnswer: Int
    var descriptionAnswer: String
    var id: Int
    init (id: Int, p: Int, d: String) {
        self.id = id
        self.descriptionAnswer = d
        self.percentAnswer = p
    }
}

class BreedStatList {
    var breedStats = [BreedStats]()
    var allBreedStats: [Int: [BreedStats]] = [:]
    
    func getDescription(_ d: String, p: Double) -> String {
        var v: String = ""
        switch d {
        case "Build":
            switch p {
            case 1: v = "Oriental"
            case 2: v = "Foreign"
            case 3: v = "Semi-Foreign"
            case 4: v = "Semi-Coby"
            case 5: v = "Cobby"
            case 6: v = "Substantial"
            default: v = ""
            }
        case "Type of Hair":
            switch p {
            case 1: v = "Hairless"
            case 2: v = "Short"
            case 3: v = "Rex"
            case 4: v = "Medium"
            case 5: v = "Long hair"
            case 6: v = "Short/Long Hair"
            default: v = ""
            }
        case "Size":
            switch p {
            case 1: v = "Small"
            case 2: v = "Average"
            case 3: v = "Biggish"
            default: v = ""
            }
        case "In/Outdoors":
            switch p {
            case 1: v = "Indoor"
            case 2: v = "Both"
            case 3: v = "Outdoor"
            default: v = ""
            }
        default: v = ""
        }
        return v
    }

    func getDescriptionAll(_ d: String, p: Double) -> String {
        var v: String = ""
        switch d {
        case "Build":
            switch p {
            case 1: v = "Oriental"
            case 2: v = "Foreign"
            case 3: v = "Semi-Foreign"
            case 4: v = "Semi-Coby"
            case 5: v = "Cobby"
            case 6: v = "Substantial"
            default: v = ""
            }
        case "Type of Hair":
            switch p {
            case 1: v = "Hairless"
            case 2: v = "Short"
            case 3: v = "Rex"
            case 4: v = "Medium"
            case 5: v = "Long Hair"
            case 6: v = "Short/Long Hair"
            default: v = ""
            }
        case "Size":
            switch p {
            case 1: v = "Small"
            case 2: v = "Average"
            case 3: v = "Big"
            default: v = ""
            }
        case "In/Outdoors":
            switch p {
            case 1: v = "Indoor"
            case 2: v = "Both"
            case 3: v = "Outdoor"
            default: v = ""
            }
        default: v = ""
        }
        return v
    }
    
    var breedIDs = [Int]()
    
    func getBreedTraitValue(_ breedID: Int, traitNumber: Int) -> Int {
        return Int(allBreedStats[breedID]![traitNumber].Value) ?? 0
    }
    
    func getBreedStatList(_ breedID: Int, percentageMatch: Double) {
        let documentsPath : AnyObject = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as AnyObject
        let DBPath:NSString = documentsPath.appending("/CatFinder.db") as NSString
        
        let contactDB = FMDatabase(path: DBPath as String)
            
        if (contactDB?.open())! {
            breedStats = [];
                
            var querySQL: String = ""
            
            if percentageMatch == -1 {
                querySQL = "SELECT BreedID, TraitShortDesc, c from BreedTraitStats where BreedID = ?"
            } else {
                querySQL = "SELECT BreedID, TraitShortDesc, c, l, h from BreedTraitValuesViewAnswers where BreedID = ?"
            }
            
            breedIDs.removeAll()
            
            let results: FMResultSet? = contactDB?.executeQuery(querySQL,
                withArgumentsIn: [breedID])
            
            print("Error: \(String(describing: contactDB?.lastErrorMessage()))")
            
            while results?.next() == true {
                let i = results?.int(forColumn: "BreedID")
                let d = results?.string(forColumn: "TraitShortDesc")
                let p = results?.double(forColumn: "c")
                var l: Double
                var h: Double
                var v: String
                v = getDescription(d!, p: p!)
                if percentageMatch != -1 {
                    l = results!.double(forColumn: "l")
                    h = results!.double(forColumn: "h")
                } else {
                    l = 0
                    h = 0
                }
                let breedStat = BreedStats(id: i!, desc: d!, percent: Double(p!), lowRange: l, highRange: h, value: v);
                breedStats.append(breedStat);
                if !breedIDs.contains(Int(i!)) {breedIDs.append(Int(i!))}
            }
            contactDB?.close()
            /*
            for (var i = 0; i < breedStats.count; ++i)
            {
                println(breedStats[i].BreedID)
            }0
            */
        } else {
            print("Error: \(String(describing: contactDB?.lastErrorMessage()))")
        }
    }

    func getBreedStatListForAllBreeds() {
        let documentsPath : AnyObject = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as AnyObject
        let DBPath:NSString = documentsPath.appending("/CatFinder.db") as NSString
        
        let contactDB = FMDatabase(path: DBPath as String)
            
        if (contactDB?.open())! {
            breedStats = [];
            
            let querySQL = "SELECT BreedID, TraitID, TraitShortDesc, BreedTraitValue from BreedTraitAll order by BreedID, TraitOrder"
            
            let results: FMResultSet? = contactDB?.executeQuery(querySQL,
                withArgumentsIn: [])
            
            print("Error: \(String(describing: contactDB?.lastErrorMessage()))")
            
            breedIDs.removeAll()
            
            while results?.next() == true {
                let i = results?.int(forColumn: "BreedID")
                let traitID = results?.int(forColumn: "TraitID")
                let traitDesc = results?.string(forColumn: "TraitShortDesc")
                let breedTraitValue = results?.int(forColumn: "BreedTraitValue")
                var v: String = ""
                v = getDescriptionAll(traitDesc!, p: Double(breedTraitValue!))
                let breedStat = BreedStats(id: i!, desc: traitDesc!, percent: Double(breedTraitValue!), lowRange: 0, highRange: 0, value: v);
                if allBreedStats.keys.contains(Int(i!)){
                    allBreedStats[Int(i!)]?.append(breedStat)
                } else {
                    var breedStats = [BreedStats]()
                    breedStats.append(breedStat)
                    allBreedStats.updateValue(breedStats, forKey: Int(i!))
                    //allBreedStats[Int(i!)!] = breedStats
                }
                if !breedIDs.contains(Int(i!)) {breedIDs.append(Int(i!))}
            }
            contactDB?.close()
            /*
            for (var i = 0; i < breedStats.count; ++i)
            {
                println(breedStats[i].BreedID)
            }
            */
        } else {
            print("Error: \(String(describing: contactDB?.lastErrorMessage()))")
        }
    }
    
    func calcMatches(responses: [response]) -> [Double] {
        var results = [Double](repeating: 0, count: (breedIDs.max() ?? 0))
        for breedID in breedIDs {
            let bs = allBreedStats[breedID]
            var sum: Double = 0
            var count: Int = 0
            for b in 0..<bs!.count {
                if (responses[b].percentAnswer > 0) || (responses[b].percentAnswer == -1) {
                    if responses[b].percentAnswer == -1 {
                        if (bs![b].Value == responses[b].descriptionAnswer) || (responses[b].descriptionAnswer == "Doesn't Matter") || (responses[b].descriptionAnswer == "Any") {
                            sum += 1.0
                        }
                    } else {
                        sum += 1.0 - (abs(Double(responses[b].percentAnswer) - Double(bs![b].Percent)) / 5.0)
                    }
                    count += 1
                }
            }
            if sum == 0 {
                results[breedID - 1] = 0
            } else {
                results[breedID - 1] = Double(sum) / Double(count)
            }
        }
        return results
    }
}
