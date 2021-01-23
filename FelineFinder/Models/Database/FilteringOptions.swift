//
//  FilteringOptions.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/28/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import Foundation

class listOption {
    var displayName: String?
    var search: String?
    var value: Int?
    init (displayName: String?, search: String?, value: Int?)  {
        self.displayName = displayName
        self.search = search
        self.value = value
    }
}

class filterOption {
    let name: String?
    var choosenValue: Int? = -1
    let fieldName: String?
    let display: Bool?
    let list: Bool?
    let classification: catClassification
    var sequence: Int = 0
    var options: [listOption] = []
    var choosenListValues:[Int] = []
    var imported: Bool = false
    var filterType: FilterType
    
    init (n: String, f: String, d: Bool, c: catClassification, o: [listOption], ft: FilterType) {
        name = n
        fieldName = f
        options = o
        choosenValue = o.count - 1 //The Any Value
        display = d
        list = false
        classification = c
        self.filterType = ft
    }
    
    init (n: String, f: String, d: Bool, c: catClassification, l: Bool, o: [listOption], ft: FilterType) {
        name = n
        fieldName = f
        options = o
        choosenValue = o.count - 1 //The Any Value
        display = d
        list = l
        classification = c
        self.filterType = ft
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
                if classification == .saves {
                    display = "None"
                } else {
                    display = "Any"
                }
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
    case saves
    case breed
    case sort
    case admin
    case compatibility
    case personality
    case physical
    case basic
}

class filterOptionsListV5 {
    var savesOption: filterOption?
    var saves: [listOption] = []
    var breedOption: filterOption?
    var notBreedOption: filterOption?
    var breedChoices: [listOption] = []
    var filteringOptions: [filterOption] = []
    var adminList: [filterOption] = []
    var compatibilityList: [filterOption] = []
    var personalityList: [filterOption] = []
    var physicalList: [filterOption] = []
    var sortByList: [filterOption] = []
    var basicList: [filterOption] = []
    func load(_ tv: UITableView?) {
        if filteringOptions.count > 0 {return}

        var saveList: [(FilterID: Int, FilterName: String)] = []
        DatabaseManager.sharedInstance.fetchFilterOptions() { (filterNames) -> Void in
            saveList = filterNames
            var i = 0
            for s in saveList {
                self.saves.append(listOption(displayName: s.FilterName, search: String(s.FilterID), value: i))
                i += 1
            }
            self.filteringOptions.append(filterOption(n: "Saved Searches", f: " Saved Searches", d: false, c:.saves, l: true, o: self.saves, ft: FilterType.Advanced))

            self.classify()
            
            /*
            if (tv != nil) {
                DispatchQueue.main.async(execute: {
                    tv?.reloadData()
                })
            }
            */
        }
        
        //breed
        var breedsList: Dictionary<String, [Breed]> = [:]
        DatabaseManager.sharedInstance.fetchBreeds(false) { (breeds) -> Void in
            breedsList = breeds
            var i = 0
            let titles: [String] = breedsList.keys.sorted{$0 < $1}
            for t in titles {
                let data = breedsList[t]
                var j = 0
                while j < data!.count {
                    let b = data![j]
                    self.breedChoices.append(listOption(displayName: b.BreedName, search: String(b.RescueBreedID), value: i))
                    i += 1
                    j += 1
                }
            }
            
            self.breedChoices.append(listOption(displayName: "Any", search: "0", value: self.breedChoices.count))
            
            self.filteringOptions.append(filterOption(n: "Breed", f: "breedPrimaryId", d: false, c:.breed, l: true, o: self.breedChoices, ft: FilterType.Advanced))
            
            self.filteringOptions.append(filterOption(n: "Not These", f: "breedPrimaryIdNot", d: false, c:.breed, l: true, o: self.breedChoices, ft: FilterType.Advanced))
            
            self.classify()
/*
            if (tv != nil) {
                DispatchQueue.main.async(execute: {
                    tv?.reloadData()
                })
            }
*/
        }
        
        
        //sort
        filteringOptions.append(filterOption(n: "Sort By", f: "sortBy", d: false, c:.sort, o: [listOption(displayName: "Most Recent", search: "No", value: 1), listOption(displayName: "Distance", search: "distance", value: 0)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Distance", f: "distance", d: false, c:.sort, o: [listOption(displayName: "5", search: "5", value: 0), listOption(displayName: "20", search: "20", value: 1), listOption(displayName: "50", search: "50", value: 2), listOption(displayName: "100", search: "100", value: 3), listOption(displayName: "200", search: "200", value: 4), listOption(displayName: "Any", search: "Any", value: 5)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Updated Since", f: "date", d: false, c:.sort, o: [listOption(displayName: "Day", search: "0", value: 0), listOption(displayName: "Week", search: "Week", value: 1), listOption(displayName: "Month", search: "Month", value: 2), listOption(displayName: "Year", search: "Year", value: 3), listOption(displayName: "Any", search: "Any", value: 4)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Find Type", f: "Find Type", d: false, c:.sort, o: [listOption(displayName: "Simple", search: "Simple", value: 0), listOption(displayName: "Advanced", search: "Advanced", value: 1)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "While Your Away", f: "While Your Away", d: false, c:.sort, o: [listOption(displayName: "Search Daily?", search: "", value: 1), listOption(displayName: "Don't Search?", search: "", value: 0)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Only With Videos?", f: "Only With Videos", d: false, c:.sort, o: [(displayName: "Yes", search: "Yes", value: 0), (displayName: "No", search: "No", value: 1)], ft: FilterType.Advanced))

        
        //admin
        filteringOptions.append(filterOption(n: "Adoption pending", f: "isAdoptionPending", d: false, c:.admin, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "No", search: "No", value: 1), listOption(displayName: "Any", search: "Any", value: 2)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Courtesy Listing", f: "isCourtesyListing", d: false, c:.admin, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "No", search: "No", value: 1), listOption(displayName: "Any", search: "Any", value: 2)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Found", f: "isFound", d: false, c:.admin, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "No", search: "No", value: 1), listOption(displayName: "Any", search: "Any", value: 2)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Needs a Foster", f: "isNeedingFoster", d: false, c:.admin, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "No", search: "No", value: 1),listOption(displayName: "Any", search: "Any", value: 2)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Allow sponsorship", f: "isSponsorable", d: false, c:.admin, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "No", search: "No", value: 1),listOption(displayName: "Any", search: "Any", value: 2)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Current on vaccations", f: "isCurrentVaccinations", d: false, c:.admin, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "No", search: "No", value: 1),listOption(displayName: "Any", search: "Any", value: 2)], ft: FilterType.Advanced))
        
        //compatibiity
        //filteringOptions.append(filterOption(n: "Apartment OK", f: "animalApartment", d: false, c: .compatibility, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Requires a Yard", f: "isYardRequired", d: false, c: .compatibility, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "No", search: "No", value: 1),listOption(displayName: "Any", search: "Any", value: 2)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "In/Outdoor", f: "indoorOutdoor", d: false, c: .compatibility, o: [listOption(displayName: "Indoor", search: "Indoor Only", value: 0),listOption(displayName: "Both", search: "Indoor/Outdoor", value: 1),listOption(displayName: "Outdoor", search: "Outdoor Only", value: 2),listOption(displayName: "Any", search: "Any", value: 3)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Cold sensitive", f: "animalNoCold", d: false, c: .compatibility, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Heat sensitive", f: "animalNoHeat", d: false, c: .compatibility, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "OK with dogs", f: "isDogsOk", d: false, c: .compatibility, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "No", search: "No", value: 1),listOption(displayName: "Any", search: "Any", value: 2)], ft: FilterType.Advanced))
 /*
        filteringOptions.append(filterOption(n: "Not good with large dogs", f: "animalNoLargeDogs", d: false, c: .compatibility, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Not good with female dogs", f: "animalNoFemaleDogs", d: false, c: .compatibility, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)]))
        filteringOptions.append(filterOption(n: "Not good with male dogs", f: "animalNoMaleDogs", d: false, c: .compatibility, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)]))
*/
        filteringOptions.append(filterOption(n: "OK with cats", f: "isCatsOk", d: false, c: .compatibility, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "No", search: "No", value: 1),listOption(displayName: "Any", search: "Any", value: 2)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Seniors", f: "isSeniorsOk", d: false, c: .compatibility, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Adults", f: "adultSexesOk", d: false, c: .compatibility, o: [listOption(displayName: "All", search: "All", value: 0),listOption(displayName: "Men", search: "Men Only", value: 1),listOption(displayName: "Women", search: "Women Only", value: 2),listOption(displayName: "Any", search: "Any", value: 3)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Farm Animals", f: "isFarmAnimalsOk", d: false, c: .compatibility, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "OK with kids", f: "isKidsOk", d: false, c: .compatibility, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "No", search: "No", value: 1),listOption(displayName: "Any", search: "Any", value: 2)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Older kids only", f: "animalOlderKidsOnly", d: false, c: .compatibility, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Owner experience needed", f: "ownerExperience", d: false, c: .compatibility, o: [listOption(displayName: "None", search: "None", value: 0),listOption(displayName: "Species", search: "Species", value: 1),listOption(displayName: "Breed", search: "Breed", value: 2),listOption(displayName: "Any", search: "Any", value: 3)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Fence Needs", f: "fenceNeeds", d: false,  c: .compatibility, l: false, o: [listOption(displayName: "None", search: "Not required", value: 0),listOption(displayName: "Any Type", search: "Any Type", value: 1),listOption(displayName: "3 foot", search: "3 foot", value: 2), listOption(displayName: "6 foot", search: "6 foot", value: 3), listOption(displayName: "Any", search: "Any", value: 4)], ft: FilterType.Advanced))
        
        //Personality
        filteringOptions.append(filterOption(n: "New People", f: "newPeopleReaction", d: false,  c: .personality, l: true, o: [listOption(displayName: "Cautious", search: "Cautious", value: 0),listOption(displayName: "Friendly", search: "Friendly", value: 1),listOption(displayName: "Protective", search: "Protective", value: 2),listOption(displayName: "Aggressive", search: "Aggressive", value: 3),listOption(displayName: "Any", search: "Any", value: 4)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Activity Level", f: "activityLevel", d: false, c: .personality, l: false, o: [listOption(displayName: "None", search: "Not Active", value: 0),listOption(displayName: "Low", search: "Slightly Active", value: 1),listOption(displayName: "Medium", search: "Moderately Active", value: 2),listOption(displayName: "High", search: "Highly Active", value: 3),listOption(displayName: "Any", search: "Any", value: 4)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Energy level", f: "energyLevel", d: false,  c: .personality, l: false, o: [listOption(displayName: "Low", search: "Low", value: 0),listOption(displayName: "Medium", search: "Moderate", value: 1),listOption(displayName: "High", search: "High", value: 2), listOption(displayName: "Any", search: "Any", value: 3)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Exercise Needs", f: "exerciseNeeds", d: false,  c: .personality,l: false, o: [listOption(displayName: "Not Req", search: "Not Required", value: 0),listOption(displayName: "Low", search: "Low", value: 1),listOption(displayName: "Medium", search: "Moderate", value: 2),listOption(displayName: "High", search: "High", value: 3),listOption(displayName: "Any", search: "Any", value: 4)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Obedience training", f: "obedienceTraining", d: false,  c: .personality, l: false, o: [listOption(displayName: "Needs", search: "Needs Training", value: 0),listOption(displayName: "Basic", search: "Has Basic Training", value: 1),listOption(displayName: "Well", search: "Well Trained", value: 2),listOption(displayName: "Any", search: "Any", value: 3)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Likes to vocalize", f: "vocalLevel", d: false,  c: .personality, l: false, o: [listOption(displayName: "Quiet", search: "Quiet", value: 0),listOption(displayName: "Some", search: "Some", value: 1),listOption(displayName: "Lots", search: "Lots", value: 2), listOption(displayName: "Any", search: "Any", value: 3)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Affectionate", f: "animalAffectionate", d: false,  c: .personality, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Crate trained", f: "animalCratetrained", d: false,  c: .personality, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Eager to please", f: "animalEagerToPlease", d: false,  c: .personality, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Tries to escape", f: "animalEscapes", d: false,  c: .personality, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Even-tempered", f: "animalEventempered", d: false,  c: .personality, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Likes to fetch", f: "animalFetches", d: false,  c: .personality, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Gentle", f: "animalGentle", d: false,  c: .personality, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Does well in a car", f: "animalGoodInCar", d: false, c: .personality, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Goofy", f: "animalGoofy", d: false,  c: .personality, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Housetrained", f: "isHousetrained", d: false,  c: .personality, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "No", search: "No", value: 1),listOption(displayName: "Any", search: "Any", value: 2)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Independent/aloof", f: "animalIndependent", d: false,  c: .personality, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Intelligent", f: "animalIntelligent", d: false,  c: .personality, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Lap pet", f: "animalLap", d: false,  c: .personality, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Leash trained", f: "animalLeashtrained", d: false,  c: .personality, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Companion Cat?", f: "animalNeedsCompanionAnimal", d: false,  c: .personality, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Obedient", f: "animalObedient", d: false,  c: .personality, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Playful", f: "animalPlayful", d: false,  c: .personality, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Likes toys", f: "animalPlaysToys", d: false,  c: .personality, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Predatory", f: "animalPredatory", d: false,  c: .personality, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Territorial", f: "animalProtective", d: false,  c: .personality, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Likes to swim", f: "animalSwims", d: false,  c: .personality, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Timid / shy", f: "animalTimid", d: false,  c: .personality, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))

        //physical
        filteringOptions.append(filterOption(n: "Age", f: "ageGroup", d: true, c: .physical, l: true, o: [listOption(displayName: "Baby", search: "Baby", value: 0),listOption(displayName: "Young", search: "Young", value: 1),listOption(displayName: "Adult", search: "Adult", value: 2), listOption(displayName: "Senior", search: "Senior", value: 3), listOption(displayName: "Any", search: "Any", value: 4)], ft: FilterType.Simple))
        filteringOptions.append(filterOption(n: "Ear type", f: "ear", d: false, c: .physical, l: true, o: [listOption(displayName: "Cropped", search: "Cropped", value: 0),listOption(displayName: "Droopy", search: "Droopy", value: 1),listOption(displayName: "Erect", search: "Erect", value: 2),listOption(displayName: "Long", search: "Long", value: 3),listOption(displayName: "Missing", search: "Missing", value: 4),listOption(displayName: "Notched", search: "Notched", value: 5),listOption(displayName: "Rose", search: "Rose", value: 6),listOption(displayName:         "Semi-erect", search: "Semi-erect", value: 7),listOption(displayName: "Tipped", search: "Tipped", value: 8),listOption(displayName: "Natural/Uncropped", search: "Natural/Uncropped", value: 9),listOption(displayName: "Any", search: "Any", value: 10)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Color", f: "colorDetails", d: false, c: .physical, l: true, o: [listOption(displayName: "Black", search: "Black", value: 0),listOption(displayName: "Black and White", search: "Black and White", value: 1),listOption(displayName: "Tuxedo", search: "Tuxedo", value: 2),listOption(displayName: "Blue", search: "Blue", value: 3),listOption(displayName: "Salt & Pepper", search: "Salt & Pepper", value: 4),listOption(displayName: "Brown or Chocolate", search: "Brown or Chocolate", value: 5),listOption(displayName: "Brown Tabby", search: "Brown Tabby", value: 6),listOption(displayName: "Calico or Dilute Calico", search: "Calico or Dilute Calico", value: 7),listOption(displayName: "Cream", search: "Cream", value: 8),listOption(displayName: "Ivory", search: "Ivory", value: 9),listOption(displayName: "Gray", search: "Gray", value: 10),listOption(displayName: "Gray Blue or Silver Tabby", search: "Gray Blue or Silver Tabby", value: 11),listOption(displayName: "Red Tabby", search: "Red Tabby", value: 12),listOption(displayName: "Spotted Tabby/Leopard Spotted", search: "Spotted Tabby/Leopard Spotted", value: 13),listOption(displayName: "Tan", search: "Tan", value: 14),listOption(displayName: "Fawn", search: "Fawn", value: 15),listOption(displayName: "Tortoiseshell", search: "Tortoiseshell", value: 16),listOption(displayName: "White", search: "White", value: 17),listOption(displayName: "Any", search: "Any", value: 18)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Eye color", f: "eyeColor", d: false, c: .physical, l: true, o: [listOption(displayName: "Black", search: "Black", value: 0),listOption(displayName: "Blue", search: "Blue", value: 1),listOption(displayName: "Blue-brown", search: "Blue-brown", value: 2),listOption(displayName: "Brown", search: "Brown", value: 3),listOption(displayName: "Copper", search: "Copper", value: 4),listOption(displayName: "Gold", search: "Gold", value: 5),listOption(displayName: "Gray", search: "Gray", value: 6),listOption(displayName: "Green", search: "Green", value: 7),listOption(displayName: "Hazlenut", search: "Hazlenut", value: 8),listOption(displayName: "Mixed", search: "Mixed", value: 9),listOption(displayName: "Pink", search: "Pink", value: 10),listOption(displayName: "Yellow", search: "Yellow", value: 11),listOption(displayName: "Any", search: "Any", value: 12)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Tail type", f: "tailType", d: false, c: .physical, l: true, o: [listOption(displayName: "Bare", search: "Bare", value: 0),listOption(displayName: "Bob", search: "Bob", value: 1),listOption(displayName: "Curled", search: "Curled", value: 2),listOption(displayName: "Docked", search: "Docked", value: 3),listOption(displayName: "Kinked", search: "Kinked", value: 4),listOption(displayName: "Long", search: "Long", value: 5),listOption(displayName: "Missing", search: "Missing", value: 6),listOption(displayName: "Short", search: "Short", value: 7),listOption(displayName: "Any", search: "Any", value: 8)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Size", f: "sizeGroup", d: true, c: .physical, l: true, o: [listOption(displayName: "Small", search: "Small", value: 0),listOption(displayName: "Medium", search: "Medium", value: 1),listOption(displayName: "Large", search: "Large", value: 2),listOption(displayName: "X-Large", search: "X-Large", value: 3),listOption(displayName: "Any", search: "Any", value: 4)], ft: FilterType.Simple))
        filteringOptions.append(filterOption(n: "Sex", f: "sex", d: true, c: .physical, l: false, o: [listOption(displayName: "Male", search: "Male", value: 0),listOption(displayName: "Female", search: "Female", value: 1),listOption(displayName: "Any", search: "Any", value: 2)], ft: FilterType.Simple))
        filteringOptions.append(filterOption(n: "Coat Length", f: "coatLength", d: false, c: .physical, l: false, o: [listOption(displayName: "Short", search: "Short", value: 0),listOption(displayName: "Medium", search: "Medium", value: 1),listOption(displayName: "Long", search: "Long", value: 2), listOption(displayName: "Any", search: "Any", value: 3)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Grooming needs", f: "groomingNeeds", d: false, c: .physical, l: false, o: [listOption(displayName: "Not Req", search: "Not Required", value: 0),listOption(displayName: "Low", search: "Low", value: 1),listOption(displayName: "Medium", search: "Moderate", value: 2),listOption(displayName: "High", search: "High", value: 3),listOption(displayName: "Any", search: "Any", value: 4)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Shedding amount", f: "sheddingLevel", d: false, c: .physical, l: false, o: [listOption(displayName: "Some", search: "Moderate", value: 0),listOption(displayName: "None", search: "None", value: 1),listOption(displayName: "High", search: "High", value: 2),listOption(displayName: "Any", search: "Any", value: 3)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Altered", f: "isAltered", d: false, c: .physical, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "No", search: "No", value: 1),listOption(displayName: "Any", search: "Any", value: 2)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Declawed", f: "isDeclawed", d: false, c: .physical, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "No", search: "No", value: 1),listOption(displayName: "Any", search: "Any", value: 2)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Has allergies", f: "animalHasAllergies", d: false, c: .physical, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Hearing impaired", f: "animalHearingImpaired", d: false, c: .physical, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Hypoallergenic", f: "animalHypoallergenic", d: false, c: .physical, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Microchipped", f: "isMicrochipped", d: false, c: .physical, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "No", search: "No", value: 1),listOption(displayName: "Any", search: "Any", value: 2)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Mixed breed", f: "isBreedMixed", d: false, c: .physical, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "No", search: "No", value: 1),listOption(displayName: "Any", search: "Any", value: 2)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Ongoing medical?", f: "animalOngoingMedical", d: false, c: .physical, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        //filteringOptions.append(filterOption(n: "Special diet", f: "animalSpecialDiet", d: false, c: .physical, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "Any", search: "Any", value: 1)], ft: FilterType.Advanced))
        filteringOptions.append(filterOption(n: "Has special needs", f: "isSpecialNeeds", d: false, c: .physical, o: [listOption(displayName: "Yes", search: "Yes", value: 0),listOption(displayName: "No", search: "No", value: 1),listOption(displayName: "Any", search: "Any", value: 2)], ft: FilterType.Advanced))
        
            classify()
    }
    
    func classify() {
        var s = 0
        adminList = []
        compatibilityList = []
        personalityList = []
        physicalList = []
        sortByList = []
        basicList = []
        for o in filteringOptions {
            switch o.classification {
            case .breed:
                if o.name == "Breed" {
                    breedOption = o
                } else {
                    notBreedOption = o
                }
            case .saves:
                savesOption = o
            case .admin:
                adminList.append(o)
            case .compatibility:
                compatibilityList.append(o)
            case .personality:
                personalityList.append(o)
            case .physical:
                physicalList.append(o)
            case .sort:
                sortByList.append(o)
            default: break
            }
            if o.filterType == FilterType.Simple {
                basicList.append(o)
            }
            o.sequence = s
            s += 1
        }
    }
    
    func getFilters() -> [filter] {
        var filters: [filter] = []
        for o in filteringOptions {
            if o.classification == .saves {continue}
            if o.fieldName == "sortBy" {
                if o.choosenValue! == 0 {
                    sortFilter = "animals.updatedDate"
                } else {
                    sortFilter = "animals.distance"
                }
                continue
            }
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
                if o.name == "Not These" { //Breeds to filter out
                    if choosenValues.count != 0 {filters.append(["fieldName": "animals.breedPrimaryId", "operation": "notequals", "criteria": choosenValues])}
                } else {
                    if choosenValues.count != 0 {filters.append(["fieldName": "animals." + o.fieldName!, "operation": "equals", "criteria": choosenValues])}
                }
            } else {
                if (o.choosenValue == o.options.count - 1 || o.choosenValue == -1) {
                    if o.fieldName == "animals.distance" {
                        distance = "4000" //If any distance choosen then default to largest value
                    } else if o.fieldName == "date" {
                        updated = Date()
                    }
                } else if o.choosenValue != o.options.count - 1 && o.choosenValue != -1 {
                    for opt in o.options {
                        if opt.value == o.choosenValue {
                            if o.fieldName == "distance" {
                                distance = opt.search!
                            } else if o.fieldName == "Find Type" {
                              continue
                            } else if o.fieldName == "date" {
                                var minus = DateComponents()
                                switch o.choosenValue! {
                                case 0: //Day
                                    minus.day = -1
                                case 1: //Week
                                    minus.day = -7
                                case 2: //Month
                                    minus.month = -1
                                case 3: //Year
                                    minus.year = -1
                                default:
                                    minus.year = -1
                                }
                                
                                let userCalendar = Calendar.current
                                
                                updated = userCalendar.date(byAdding: minus, to: Date())!
                                
                                /*
                                if o.choosenValue! != 3 {
                                    updated = userCalendar.date(byAdding: minus, to: Date())!
                                } else {
                                    updated = rescueGroupsLastQueried
                                    rescueGroupsLastQueried = Date()
                                    UserDefaults.standard.set(rescueGroupsLastQueried, forKey: "rescueGroupsLastQueriedString")
                                }
                                */
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "MM/dd/yyyy"
                                let d = dateFormatter.string(from: updated)
                                
                                filters.append(["fieldName": "animals.updatedDate", "operation": "greaterthan", "criteria": d])
                            } else {
                                if (opt.search != "") {
                                    if opt.search == "Yes" {
                                        filters.append(["fieldName": "animals." + o.fieldName!, "operation": "equals", "criteria": true])
                                    } else if opt.search == "No" {
                                        filters.append(["fieldName": "animals." + o.fieldName!, "operation": "notequals", "criteria": true])
                                    } else {
                                        filters.append(["fieldName": "animals." + o.fieldName!, "operation": "equals", "criteria": opt.search!])
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return filters
    }
    
    func storeFilters(_ saveID: Int, saveName: String) {
        DatabaseManager.sharedInstance.saveFilterOptions(saveID, name: saveName, filterOptions: self)
    }
    
    //func retrieveSavedFilterValues(_ savedID: Int, filterOptions: filterOptionsList, choosenListValues: [Int]) {

    func retrieveSavedFilterValues(_ savedID: Int, filterOptions: filterOptionsListV5) {
        DatabaseManager.sharedInstance.fetchFFilterOptions(savedID, filterOptions: filterOptions, completion: {(filterOption) -> Void in
            filterOptions.filteringOptions = filterOption
            filterOptions.filteringOptions[0].choosenListValues = filterOption[0].choosenListValues
            if filterOption[4].fieldName == "Find Type" {
                if filterOption[4].choosenValue == 1 {
                    filterType = FilterType.Advanced
                } else {
                    filterType = FilterType.Simple
                }
            }
            })
    }
    
    func deleteSavedFilterValues(_ savedID: Int) {
        DatabaseManager.sharedInstance.deleteFilterOptions(savedID: savedID)
        filterOptions.filteringOptions[0].options = filterOptions.filteringOptions[0].options.filter{$0.search != String(savedID)}
        //filterOptions.reset()
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
                    } else if opt.value! == o.choosenValue && !o.display! && o.classification != .saves {
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
    
    func setFilter(name: String, value: [Int]) {
        for f in filteringOptions {
            if f.fieldName == name {
                if f.list! {
                    for o in f.options {
                        if (Int(value[0]) == Int(o.search!)) {
                            f.choosenValue = Int(o.search!)
                            break
                        }
                    }
                    //f.choosenValue = value[0]
                    f.choosenListValues = value
                } else {
                    f.choosenValue = value[0]
                }
                f.imported = true
            }
        }
    }
    
    func importQuestions() {
        var filterName: String = ""
        filterOptions.reset()
        for q in questionList.Questions {
            if q.getAnswer().Name == "Doesn't Matter" {
                continue
            }
            switch q.QuestionID {
            case 3: //Energy Level
                filterName = "animalEnergyLevel"
                switch q.getAnswer().LowRange {
                case 1: //Lazy
                    setFilter(name: filterName, value: [0])
                case 2, 3: //Moderate, Medium
                    setFilter(name: filterName, value: [1])
                case 4, 5: //High
                    setFilter(name: filterName, value: [2])
                default: break
                }
            case 1: //Fun Loving
                filterName = "animalPlayful"
                switch q.getAnswer().LowRange {
                case 3, 4, 5: //
                    setFilter(name: filterName, value: [0])
                default:
                    setFilter(name: filterName, value: [1])
                }
            case 5: //Talkative
                filterName = "animalVocal"
                switch q.getAnswer().LowRange {
                case 1: //Mostly Silent
                    setFilter(name: filterName, value: [0])
                case 2, 3: //Talk a bit, average
                    setFilter(name: filterName, value: [1])
                case 4, 5: //Somewhat Talkative, Chatty Cathy
                    setFilter(name: filterName, value: [2])
                default: break
                }
            case 6: //Handling
                filterName = "animalTimid"
                switch q.getAnswer().LowRange {
                case 1, 2:
                    setFilter(name: filterName, value: [0]) //Timid Shy Yes
                default: break
                }
            case 7: //Intelligence
                filterName = "animalIntelligent"
                switch q.getAnswer().LowRange {
                case 3, 4, 5:
                    setFilter(name: filterName, value: [0]) //Intelligent Yes
                default: break
                }
            case 8: //Indoors/Outdoors
                filterName = "animalIndoorOutdoor"
                switch q.getAnswer().LowRange {
                case 1: //Indoors
                    setFilter(name: filterName, value: [0]) //Indoors
                case 2: //Both
                    setFilter(name: filterName, value: [1]) //Both
                case 3: //Outdoors
                    setFilter(name: filterName, value: [2]) //Outdoors
                default: break
            }
            case 15: //Health
                filterName = "animalGeneralAge"
                switch q.getAnswer().LowRange {
                case 5: //Longest
                    setFilter(name: filterName, value: [0]) //Baby
                case 4: //Above Average
                    setFilter(name: filterName, value: [1]) //Young
                case 3: //Average
                    setFilter(name: filterName, value: [2]) //Adult
                case 2, 1: //Below Average, Shortest
                    setFilter(name: filterName, value: [3]) //Senior
                default: break
                }
            case 9: //Grooming
                filterName = "animalGroomingNeeds"
                switch q.getAnswer().LowRange {
                case 1: //Not Required
                    setFilter(name: filterName, value: [0]) //Not required
                case 2: //A little
                    setFilter(name: filterName, value: [1]) //Low
                case 3, 4: //Average, Some
                    setFilter(name: filterName, value: [2]) //Moderate
                case 5: //High
                    setFilter(name: filterName, value: [3]) //High
                default: break
                }
            case 10: //Ok with pets
                switch q.getAnswer().LowRange {
                case 1: //Doesn't tolerate pets
                    setFilter(name: "animalOKWithCats", value: [1])
                    setFilter(name: "animalOKWithDogs", value: [1])
                case 2: //Tolerates Them
                    setFilter(name: "animalOKWithCats", value: [1])
                    setFilter(name: "animalOKWithDogs", value: [1])
                case 3, 4: //
                    setFilter(name: "animalOKWithCats", value: [0])
                    setFilter(name: "animalOKWithDogs", value: [0])
                case 5: //
                    setFilter(name: "animalOKWithCats", value: [0])
                    setFilter(name: "animalOKWithDogs", value: [0])
                default: break
            }
            case 11: //OK With Children
                switch q.getAnswer().LowRange {
                case 1: //Doesn't tolerate
                    setFilter(name: "animalOKWithKids", value: [1])
                    setFilter(name: "animalOlderKidsOnly", value: [0])
                case 2, 3: //Tolerates, Average
                    setFilter(name: "animalOKWithKids", value: [0])
                    setFilter(name: "animalOlderKidsOnly", value: [0])
                case 4, 5: //well, Very Well
                    setFilter(name: "animalOKWithKids", value: [0])
                    setFilter(name: "animalOlderKidsOnly", value: [1])
                default: break
                }
            case 13: //Hair Type
                filterName = "animalCoatLength"
                switch q.getAnswer().LowRange {
                case 1: //Hairless
                    break //This does not match anything
                case 2, 3: //Short, Rex
                    setFilter(name: filterName, value: [0]) //Short
                case 4: //Medium
                    setFilter(name: filterName, value: [1]) //Medium
                case 5: //Long Hair
                    setFilter(name: filterName, value: [2]) //Long
                case 6: //Long/Short Hair
                    setFilter(name: filterName, value: [0, 2]) //Long Short Hair
                default: break
                }
            case 14: //Size
                filterName = "animalGeneralSizePotential"
                switch q.getAnswer().LowRange {
                case 1: //Small
                    setFilter(name: filterName, value: [0]) //Small
                case 2: //Average
                    setFilter(name: filterName, value: [1]) //Medium
                case 3: //Biggish
                    setFilter(name: filterName, value: [2, 3]) //Large
                default: break
                }
            default: break
            }
        }
        classify()
    }
    
    func reset() {
        for o in filteringOptions {
            o.choosenValue = o.optionsArray().count - 1
            if o.list == true {
                o.choosenListValues = []
            }
            o.imported = false
        }
        currentFilterSave = "Touch Here To Load/Save..."
    }
}
