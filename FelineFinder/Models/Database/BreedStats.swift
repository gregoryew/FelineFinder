//
//  BreedStats.swift
//  Feline Finder
//
//  Created by Gregory Williams on 6/14/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation
import FMDB

struct BreedStats {
    let BreedID: Int32
    let TraitShortDesc: String
    let Percent: Double
    let LowRange: Double
    let HighRange: Double
    let Value: String
    let isPercentage: Bool
    init(id: Int32, desc: String, percent: Double, lowRange: Double, highRange: Double, value: String, isPercentage: Bool) {
        BreedID = id
        TraitShortDesc = desc
        Percent = percent
        LowRange = lowRange
        HighRange = highRange
        Value = value
        self.isPercentage = isPercentage
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
        case "Zodicat":
            switch p {
            case 1: v = "♒ Aquarius (Jan 20 - Feb 18)"
            case 2: v = "♓ Pisces (Feb 19 - March 20)"
            case 3: v = "♈ Aries (March 21 - Apr 19)"
            case 4: v = "♉ Taurus (Apr 20 - May 20)"
            case 5: v = "♊ Gemini (May 21 - Jun 20)"
            case 6: v = "♋ Cancer (Jun 21 - July 22)"
            case 7: v = "♌ Leo (July 23 - Aug 22)"
            case 8: v = "♍ Virgo (Aug 23 - Sep 22)"
            case 9: v = "♎ Libra (Sep 23 - Oct 22)"
            case 10: v = "♏ Scorpio (Oct 23 - Nov 21)"
            case 11: v = "♐ Sagittarius (Nov 22 - Dec 21)"
            case 12: v = "♑ Capricorn (Dec 22 - Jan 19)"
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
    public var breedStats = [BreedStats]()
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
        case "Zodicat":
            switch p {
            case 1: v = "♒ Aquarius (Jan 20 - Feb 18)"
            case 2: v = "♓ Pisces (Feb 19 - March 20)"
            case 3: v = "♈ Aries (March 21 - Apr 19)"
            case 4: v = "♉ Taurus (Apr 20 - May 20)"
            case 5: v = "♊ Gemini (May 21 - Jun 20)"
            case 6: v = "♋ Cancer (Jun 21 - July 22)"
            case 7: v = "♌ Leo (July 23 - Aug 22)"
            case 8: v = "♍ Virgo (Aug 23 - Sep 22)"
            case 9: v = "♎ Libra (Sep 23 - Oct 22)"
            case 10: v = "♏ Scorpio (Oct 23 - Nov 21)"
            case 11: v = "♐ Sagittarius (Nov 22 - Dec 21)"
            case 12: v = "♑ Capricorn (Dec 22 - Jan 19)"
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
        case "Zodicat":
            switch p {
            case 1: v = "♒ Aquarius (Jan 20 - Feb 18)"
            case 2: v = "♓ Pisces (Feb 19 - March 20)"
            case 3: v = "♈ Aries (March 21 - Apr 19)"
            case 4: v = "♉ Taurus (Apr 20 - May 20)"
            case 5: v = "♊ Gemini (May 21 - Jun 20)"
            case 6: v = "♋ Cancer (Jun 21 - July 22)"
            case 7: v = "♌ Leo (July 23 - Aug 22)"
            case 8: v = "♍ Virgo (Aug 23 - Sep 22)"
            case 9: v = "♎ Libra (Sep 23 - Oct 22)"
            case 10: v = "♏ Scorpio (Oct 23 - Nov 21)"
            case 11: v = "♐ Sagittarius (Nov 22 - Dec 21)"
            case 12: v = "♑ Capricorn (Dec 22 - Jan 19)"
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
            
        if (contactDB.open()) {
            breedStats = [];
                
            var querySQL: String = ""
            
            if percentageMatch == -1 {
                querySQL = "SELECT BreedID, TraitShortDesc, c, isPercentage from BreedTraitStats where BreedID = ?"
            } else {
                querySQL = "SELECT BreedID, TraitShortDesc, c, l, h from BreedTraitValuesViewAnswers where BreedID = ?"
            }
            
            breedIDs.removeAll()
            
            let results: FMResultSet? = contactDB.executeQuery(querySQL,
                withArgumentsIn: [breedID])
            
            print("Error: \(String(describing: contactDB.lastErrorMessage()))")
            
            while results?.next() == true {
                let i = results?.int(forColumn: "BreedID")
                let d = results?.string(forColumn: "TraitShortDesc")
                let p = results?.double(forColumn: "c")
                var l: Double
                var h: Double
                var v: String
                var isPercentage: Bool
                v = getDescription(d!, p: p!)
                if percentageMatch != -1 {
                    l = results!.double(forColumn: "l")
                    h = results!.double(forColumn: "h")
                } else {
                    l = 0
                    h = 0
                }
                isPercentage = results!.string(forColumn: "isPercentage") == "yes"
                let breedStat = BreedStats(id: i!, desc: d!, percent: Double(p!), lowRange: l, highRange: h, value: v, isPercentage: isPercentage);
                breedStats.append(breedStat);
                if !breedIDs.contains(Int(i!)) {breedIDs.append(Int(i!))}
            }
            contactDB.close()
            /*
            for (var i = 0; i < breedStats.count; ++i)
            {
                println(breedStats[i].BreedID)
            }0
            */
        } else {
            print("Error: \(String(describing: contactDB.lastErrorMessage()))")
        }
    }

    func getBreedStatListForAllBreeds() {
        let documentsPath : AnyObject = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as AnyObject
        let DBPath:NSString = documentsPath.appending("/CatFinder.db") as NSString
        
        let contactDB = FMDatabase(path: DBPath as String)
            
        if (contactDB.open()) {
            breedStats = [];
            
            let querySQL = "SELECT BreedID, TraitID, TraitShortDesc, BreedTraitValue, isPercentage from BreedTraitAll order by BreedID, TraitOrder"
            
            let results: FMResultSet? = contactDB.executeQuery(querySQL,
                withArgumentsIn: [])
            
            print("Error: \(String(describing: contactDB.lastErrorMessage()))")
            
            breedIDs.removeAll()
            
            while results?.next() == true {
                let i = results?.int(forColumn: "BreedID")
                let _ = results?.int(forColumn: "TraitID")
                let traitDesc = results?.string(forColumn: "TraitShortDesc")
                let breedTraitValue = results?.int(forColumn: "BreedTraitValue")
                let isPercentage = results?.string(forColumn: "isPercentage")
                var v: String = ""
                v = getDescriptionAll(traitDesc!, p: Double(breedTraitValue!))
                let breedStat = BreedStats(id: i!, desc: traitDesc!, percent: Double(breedTraitValue!), lowRange: 0, highRange: 0, value: v, isPercentage: isPercentage == "yes");
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
            contactDB.close()
            /*
            for (var i = 0; i < breedStats.count; ++i)
            {
                println(breedStats[i].BreedID)
            }
            */
        } else {
            print("Error: \(String(describing: contactDB.lastErrorMessage()))")
        }
    }
    
    func calcMatches(responses: [response]) -> [Double] {
        var results = [Double](repeating: 0, count: 69)
        for breedID in breedIDs {
            let bs = allBreedStats[breedID]
            var sum: Double = 0
            var count: Int = 0
            for b in 0..<bs!.count {
                if (responses[b].percentAnswer > 0) || (responses[b].percentAnswer == -1) {
                    if responses[b].percentAnswer == -1 {
                        if (bs![b].Value == responses[b].descriptionAnswer) { //|| (responses[b].descriptionAnswer == "Doesn't Matter") || (responses[b].descriptionAnswer == "Any") {
                            sum += 1.0
                        }
                    } else {
                        sum += 1.0 - (abs(Double(responses[b].percentAnswer) - Double(bs![b].Percent)) / 5.0)
                    }
                    if (responses[b].descriptionAnswer != "Doesn't Matter") && (responses[b].descriptionAnswer != "Any") {count += 1}
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
