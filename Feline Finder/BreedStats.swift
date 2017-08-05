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

class BreedStatList {
    var breedStats = [BreedStats]()
    
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
                let breedStat = BreedStats(id: i!, desc: d!, percent: p!, lowRange: l, highRange: h, value: v);
                breedStats.append(breedStat);
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
}
