//
//  FilteringOptions.swift
//  Feline Finder
//
//  Created by Gregory Williams on 9/8/16.
//  Copyright © 2016 Gregory Williams. All rights reserved.
//

import Foundation

class filterOption {
    let name: String?
    var choosenValue: Int? = -1
    let fieldName: String?
    let display: Bool?
    let list: Bool?
    let classification: catClassification
    var sequence: Int = 0
    var options: [(displayName: String?, search: String?, value: Int?)] = []
    var choosenListValues:[Int] = []
    
    init (n: String, f: String, d: Bool, c: catClassification, o: [(displayName: String?, search: String?, value: Int?)]) {
        name = n
        fieldName = f
        options = o
        choosenValue = o.count - 1 //The Any Value
        display = d
        list = false
        classification = c
    }
    
    init (n: String, f: String, d: Bool, c: catClassification, l: Bool, o: [(displayName: String?, search: String?, value: Int?)]) {
        name = n
        fieldName = f
        options = o
        choosenValue = o.count - 1 //The Any Value
        display = d
        list = l
        classification = c
    }
    
    func optionsArray() -> [String] {
        var opts: [String] = []
        for o in options {
            opts.append(o.displayName!)
        }
        return opts
    }
    
    func getDisplayValues() -> String {
        var display = ""
        if (list == true) {
            for c in choosenListValues {
                for o in options {
                    if o.value == c {
                        display += o.displayName! + ", "
                    }
                }
            }
            if display != "" {
                display = display.chopSuffix(2)
            } else {
                display = "Any"
            }
        } else {
            if choosenValue != -1 {
                for o in options {
                    if o.value == choosenValue {
                        display = o.displayName!
                    }
                }
            } else {
                display = "Any"
            }
        }
        return display
    }
}

enum catClassification: Int {
    case admin
    case compatibility
    case personality
    case physical
}

class filterOptionsList {
    var filteringOptions: [filterOption] = []
    var adminList: [filterOption] = []
    var compatibilityList: [filterOption] = []
    var personalityList: [filterOption] = []
    var physicalList: [filterOption] = []
    func load() {
        if filteringOptions.count > 0 {return}
        //admin
        filteringOptions.append(filterOption(n: "Adoption pending", f: "animalAdoptionPending", d: false, c:.admin, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "No", search: "No", value: 1), (displayName: "Any", search: "Any", value: 2)]))
        filteringOptions.append(filterOption(n: "Courtesy", f: "animalCourtesy", d: false, c:.admin, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "No", search: "No", value: 1), (displayName: "Any", search: "Any", value: 2)]))
        filteringOptions.append(filterOption(n: "Found", f: "animalFound", d: false, c:.admin, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "No", search: "No", value: 1), (displayName: "Any", search: "Any", value: 2)]))
        filteringOptions.append(filterOption(n: "Needs a Foster", f: "animalNeedsFoster", d: false, c:.admin, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "No", search: "No", value: 1),(displayName: "Any", search: "Any", value: 2)]))
        filteringOptions.append(filterOption(n: "Allow sponsorship", f: "animalSponsorable", d: false, c:.admin, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "No", search: "No", value: 1),(displayName: "Any", search: "Any", value: 2)]))
        filteringOptions.append(filterOption(n: "Up-to-date", f: "animalUptodate", d: false, c:.admin, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "No", search: "No", value: 1),(displayName: "Any", search: "Any", value: 2)]))
        
        //compatibiity
        filteringOptions.append(filterOption(n: "Apartment OK", f: "animalApartment", d: false,            c: .compatibility, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Requires a Yard", f: "animalYardRequired", d: false, c: .compatibility, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "No", search: "No", value: 1),(displayName: "Any", search: "Any", value: 2)]))
        filteringOptions.append(filterOption(n: "Indoor/Outdoor", f: "animalIndoorOutdoor", d: false, c: .compatibility, o: [(displayName: "Indoor", search: "Indoor Only", value: 0),(displayName: "Both", search: "Indoor and Outdoor", value: 1),(displayName: "Outdoor", search: "Outdoor Only", value: 2),(displayName: "Any", search: "Any", value: 3)]))
        filteringOptions.append(filterOption(n: "Cold sensitive", f: "animalNoCold", d: false, c: .compatibility, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Heat sensitive", f: "animalNoHeat", d: false, c: .compatibility, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "OK with dogs", f: "animalOKWithDogs", d: false, c: .compatibility, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "No", search: "No", value: 1),(displayName: "Any", search: "Any", value: 2)]))
 /*
        filteringOptions.append(filterOption(n: "Not good with large dogs", f: "animalNoLargeDogs", d: false, c: .compatibility, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Not good with female dogs", f: "animalNoFemaleDogs", d: false, c: .compatibility, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Not good with male dogs", f: "animalNoMaleDogs", d: false, c: .compatibility, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
*/
        filteringOptions.append(filterOption(n: "OK with cats", f: "animalOKWithCats", d: false, c: .compatibility, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "No", search: "No", value: 1),(displayName: "Any", search: "Any", value: 2)]))
        filteringOptions.append(filterOption(n: "Seniors", f: "animalOKForSeniors", d: false, c: .compatibility, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Adults", f: "animalOKWithAdults", d: false, c: .compatibility, o: [(displayName: "All", search: "All", value: 0),(displayName: "Men Only", search: "Men Only", value: 1),(displayName: "Women Only", search: "Women Only", value: 2),(displayName: "Any", search: "Any", value: 3)]))
        filteringOptions.append(filterOption(n: "Farm Animals", f: "animalOKWithFarmAnimals", d: false, c: .compatibility, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "OK with kids", f: "animalOKWithKids", d: false, c: .compatibility, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "No", search: "No", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Older kids only", f: "animalOlderKidsOnly", d: false, c: .compatibility, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Owner experience needed", f: "animalOwnerExperience", d: false, c: .compatibility, o: [(displayName: "None", search: "None", value: 0),(displayName: "Species", search: "Species", value: 1),(displayName: "Breed", search: "Breed", value: 2),(displayName: "Any", search: "Any", value: 3)]))
        
        //Personality
        filteringOptions.append(filterOption(n: "Activity Level", f: "animalActivityLevel", d: false, c: .personality, l: true, o: [(displayName: "Not Active", search: "Not Active", value: 0),(displayName: "Slightly Active", search: "Slightly Active", value: 1),(displayName: "Moderately Active", search: "Moderately Active", value: 2),(displayName: "Highly Active", search: "Highly Active", value: 3),(displayName: "Any", search: "Any", value: 4)]))
        filteringOptions.append(filterOption(n: "Energy level", f: "animalEnergyLevel", d: false,  c: .personality, l: true, o: [(displayName: "Low", search: "Low", value: 0),(displayName: "Moderate", search: "Moderate", value: 1),(displayName: "High", search: "High", value: 2), (displayName: "Any", search: "Any", value: 3)]))
        filteringOptions.append(filterOption(n: "Exercise Needs", f: "animalExerciseNeeds", d: false,  c: .personality,l: true, o: [(displayName: "Not Required", search: "Not Required", value: 0),(displayName: "Low", search: "Low", value: 1),(displayName: "Moderate", search: "Moderate", value: 2),(displayName: "High", search: "High", value: 3),(displayName: "Any", search: "Any", value: 4)]))
        filteringOptions.append(filterOption(n: "Act with New People", f: "animalNewPeople", d: false,  c: .personality, l: true, o: [(displayName: "Cautious", search: "Cautious", value: 0),(displayName: "Friendly", search: "Friendly", value: 1),(displayName: "Protective", search: "Protective", value: 2),(displayName: "Aggressive", search: "Aggressive", value: 3),(displayName: "Any", search: "Any", value: 4)]))
        filteringOptions.append(filterOption(n: "Obedience training", f: "animalObedienceTraining", d: false,  c: .personality, l: true, o: [(displayName: "Needs Training", search: "Needs Training", value: 0),(displayName: "Has Basic Training", search: "Has Basic Training", value: 1),(displayName: "Well Trained", search: "Well Trained", value: 2),(displayName: "Any", search: "Any", value: 3)]))
        filteringOptions.append(filterOption(n: "Likes to vocalize", f: "animalVocal", d: false,  c: .personality, l: true, o: [(displayName: "Quiet", search: "Quiet", value: 0),(displayName: "Some", search: "Some", value: 1),(displayName: "Lots", search: "Lots", value: 2), (displayName: "Any", search: "Any", value: 3)]))
        filteringOptions.append(filterOption(n: "Affectionate", f: "animalAffectionate", d: false,  c: .personality, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Crate trained", f: "animalCratetrained", d: false,  c: .personality, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Eager to please", f: "animalEagerToPlease", d: false,  c: .personality, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Tries to escape", f: "animalEscapes", d: false,  c: .personality, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Even-tempered", f: "animalEventempered", d: false,  c: .personality, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Likes to fetch", f: "animalFetches", d: false,  c: .personality, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Gentle", f: "animalGentle", d: false,  c: .personality, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Does well in a car", f: "animalGoodInCar", d: false, c: .personality, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Goofy", f: "animalGoofy", d: false,  c: .personality, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Housetrained", f: "animalHousetrained", d: false,  c: .personality, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "No", search: "No", value: 1),(displayName: "Any", search: "Any", value: 2)]))
        filteringOptions.append(filterOption(n: "Independent/aloof", f: "animalIndependent", d: false,  c: .personality, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Intelligent", f: "animalIntelligent", d: false,  c: .personality, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Lap pet", f: "animalLap", d: false,  c: .personality, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Leash trained", f: "animalLeashtrained", d: false,  c: .personality, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Companion Cat?", f: "animalNeedsCompanionAnimal", d: false,  c: .personality, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Obedient", f: "animalObedient", d: false,  c: .personality, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Playful", f: "animalPlayful", d: false,  c: .personality, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Likes toys", f: "animalPlaysToys", d: false,  c: .personality, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Predatory", f: "animalPredatory", d: false,  c: .personality, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Territorial", f: "animalProtective", d: false,  c: .personality, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Likes to swim", f: "animalSwims", d: false,  c: .personality, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Timid / shy", f: "animalTimid", d: false,  c: .personality, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))

        //physical
        filteringOptions.append(filterOption(n: "Age", f: "animalGeneralAge", d: true, c: .physical, l: true, o: [(displayName: "Baby", search: "Baby", value: 0),(displayName: "Young", search: "Young", value: 1),(displayName: "Adult", search: "Adult", value: 2), (displayName: "Senior", search: "Senior", value: 3), (displayName: "Any", search: "Any", value: 4)]))
        filteringOptions.append(filterOption(n: "Sex", f: "animalSex", d: true, c: .physical, l: true, o: [(displayName: "Male", search: "Male", value: 0),(displayName: "Female", search: "Female", value: 1),(displayName: "Any", search: "Any", value: 2)]))
        filteringOptions.append(filterOption(n: "Coat Length", f: "animalCoatLength", d: false, c: .physical, l: true, o: [(displayName: "Short", search: "Short", value: 0),(displayName: "Medium", search: "Medium", value: 1),(displayName: "Long", search: "Long", value: 2), (displayName: "Any", search: "Any", value: 3)]))
        filteringOptions.append(filterOption(n: "Ear type", f: "animalEarType", d: false, c: .physical, l: true, o: [(displayName: "Cropped", search: "Cropped", value: 0),(displayName: "Droopy", search: "Droopy", value: 1),(displayName: "Erect", search: "Erect", value: 2),(displayName: "Long", search: "Long", value: 3),(displayName: "Missing", search: "Missing", value: 4),(displayName: "Notched", search: "Notched", value: 5),(displayName: "Rose", search: "Rose", value: 6),(displayName:         "Semi-erect", search: "Semi-erect", value: 7),(displayName: "Tipped", search: "Tipped", value: 8),(displayName: "Natural/Uncropped", search: "Natural/Uncropped", value: 9),(displayName: "Any", search: "Any", value: 10)]))
        filteringOptions.append(filterOption(n: "Eye color", f: "animalEyeColor", d: false, c: .physical, l: true, o: [(displayName: "Black", search: "Black", value: 0),(displayName: "Blue", search: "Blue", value: 1),(displayName: "Blue-brown", search: "Blue-brown", value: 2),(displayName: "Brown", search: "Brown", value: 3),(displayName: "Copper", search: "Copper", value: 4),(displayName: "Gold", search: "Gold", value: 5),(displayName: "Gray", search: "Gray", value: 6),(displayName: "Green", search: "Green", value: 7),(displayName: "Hazlenut", search: "Hazlenut", value: 8),(displayName: "Mixed", search: "Mixed", value: 9),(displayName: "Pink", search: "Pink", value: 10),(displayName: "Yellow", search: "Yellow", value: 11),(displayName: "Any", search: "Any", value: 12)]))
        filteringOptions.append(filterOption(n: "Grooming needs", f: "animalGroomingNeeds", d: false, c: .physical, l: true, o: [(displayName: "Not Required", search: "Not Required", value: 0),(displayName: "Low", search: "Low", value: 1),(displayName: "Moderate", search: "Moderate", value: 2),(displayName: "High", search: "High", value: 3),(displayName: "Any", search: "Any", value: 4)]))
        filteringOptions.append(filterOption(n: "Shedding amount", f: "animalShedding", d: false, c: .physical, l: true, o: [(displayName: "Moderate", search: "Moderate", value: 0),(displayName: "None", search: "None", value: 1),(displayName: "High", search: "High", value: 2),(displayName: "Any", search: "Any", value: 3)]))
        filteringOptions.append(filterOption(n: "Tail type", f: "animalTailType", d: false, c: .physical, l: true, o: [(displayName: "Bare", search: "Bare", value: 0),(displayName: "Bob", search: "Bob", value: 1),(displayName: "Curled", search: "Curled", value: 2),(displayName: "Docked", search: "Docked", value: 3),(displayName: "Kinked", search: "Kinked", value: 4),(displayName: "Long", search: "Long", value: 5),(displayName: "Missing", search: "Missing", value: 6),(displayName: "Short", search: "Short", value: 7),(displayName: "Any", search: "Any", value: 8)]))
        filteringOptions.append(filterOption(n: "Color", f: "animalColor", d: false, c: .physical, l: true, o: [(displayName: "Black", search: "Black", value: 0),(displayName: "Black and White", search: "Black and White", value: 1),(displayName: "Tuxedo", search: "Tuxedo", value: 2),(displayName: "Blue", search: "Blue", value: 3),(displayName: "Salt & Pepper", search: "Salt & Pepper", value: 4),(displayName: "Brown or Chocolate", search: "Brown or Chocolate", value: 5),(displayName: "Brown Tabby", search: "Brown Tabby", value: 6),(displayName: "Calico or Dilute Calico", search: "Calico or Dilute Calico", value: 7),(displayName: "Cream", search: "Cream", value: 8),(displayName: "Ivory", search: "Ivory", value: 9),(displayName: "Gray", search: "Gray", value: 10),(displayName: "Gray Blue or Silver Tabby", search: "Gray Blue or Silver Tabby", value: 11),(displayName: "Red Tabby", search: "Red Tabby", value: 12),(displayName: "Spotted Tabby/Leopard Spotted", search: "Spotted Tabby/Leopard Spotted", value: 13),(displayName: "Tan", search: "Tan", value: 14),(displayName: "Fawn", search: "Fawn", value: 15),(displayName: "Tortoiseshell", search: "Tortoiseshell", value: 16),(displayName: "White", search: "White", value: 17),(displayName: "Any", search: "Any", value: 18)]))
        filteringOptions.append(filterOption(n: "Altered", f: "animalAltered", d: false, c: .physical, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "No", search: "No", value: 1),(displayName: "Any", search: "Any", value: 2)]))
        filteringOptions.append(filterOption(n: "Declawed", f: "animalDeclawed", d: false, c: .physical, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "No", search: "No", value: 1),(displayName: "Any", search: "Any", value: 2)]))
        filteringOptions.append(filterOption(n: "Has allergies", f: "animalHasAllergies", d: false, c: .physical, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Hearing impaired", f: "animalHearingImpaired", d: false, c: .physical, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Hypoallergenic", f: "animalHypoallergenic", d: false, c: .physical, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Microchipped", f: "animalMicrochipped", d: false, c: .physical, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "No", search: "No", value: 1),(displayName: "Any", search: "Any", value: 2)]))
        filteringOptions.append(filterOption(n: "Mixed breed", f: "animalMixedBreed", d: false, c: .physical, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "No", search: "No", value: 1),(displayName: "Any", search: "Any", value: 2)]))
        filteringOptions.append(filterOption(n: "Ongoing medical?", f: "animalOngoingMedical", d: false, c: .physical, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Special diet", f: "animalSpecialDiet", d: false, c: .physical, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Has special needs", f: "animalSpecialneeds", d: false, c: .physical, o: [(displayName: "Yes", search: "Yes", value: 0),(displayName: "No", search: "No", value: 1),(displayName: "Any", search: "Any", value: 2)]))
        
            classify()
    }
    
    func classify() {
        var s = 0
        adminList = []
        compatibilityList = []
        personalityList = []
        physicalList = []
        for o in filteringOptions {
            switch o.classification {
            case .admin:
                adminList.append(o)
                break
            case .compatibility:
                compatibilityList.append(o)
                break
            case .personality:
                personalityList.append(o)
                break
            case .physical:
                physicalList.append(o)
                break
            }
            o.sequence = s
            s += 1
        }
    }
    
    func getFilters() -> [filter] {
        var filters: [filter] = []
        for o in filteringOptions {
            if o.list == true {
                var choosenValues: [String] = []
                for c in o.choosenListValues {
                    var i = 1
                    for opt in o.options {
                        if c == opt.value && i != o.options.count {
                            choosenValues.append(opt.search!)
                        }
                        i += 1
                    }
                }
                if choosenValues.count != 0 {filters.append(["fieldName": o.fieldName!, "operation": "equals", "criteria": choosenValues])}
            } else {
                if o.choosenValue != o.options.count - 1 && o.choosenValue != -1 {
                    for opt in o.options {
                        if opt.value == o.choosenValue {
                            filters.append(["fieldName": o.fieldName!, "operation": "equals", "criteria": opt.search!])
                        }
                    }
                }
            }
        }
        return filters
    }
    
    func storeFilters() {
        
    }
    
    func displayFilter() -> String {
        var display: String = ""
        var showOptions: Bool = false
        for o in filteringOptions {
            if o.choosenValue != o.options.count - 1 && o.choosenValue != -1 {
                for opt in o.options {
                    if opt.value! == o.choosenValue && o.display! {
                        if display == "" {
                            display = opt.search!
                        } else {
                            display += " ● " + opt.search!
                        }
                    } else if opt.value! == o.choosenValue && !o.display! {
                        showOptions = true
                    }
                }
            }
        }
        if showOptions {
            if display == "" {
                display = "Options"
            } else {
                display += " ● Options"
            }
        }
        if display == "" {display = "None"}
        return display
    }
    
    func reset() {
        for o in filteringOptions {
            o.choosenValue = o.optionsArray().count - 1
            if o.list == true {
                o.choosenListValues = []
            }
        }
    }
}