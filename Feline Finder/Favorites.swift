//
//  Favorites.swift
//  FelineFinder
//
//  Created by Gregory Williams on 8/23/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation

struct Favorite {
    var petID: String
    var petName: String
    var imageName: String
    var breed: String
    var FavoriteDataSource: DataSource
    var Status: String
    init (id: String, n: String, i: String, b: String, d: DataSource, s: String) {
        petID = id
        petName = n
        imageName = i
        breed = b
        FavoriteDataSource = d
        Status = s
    }
}

var Favorites = FavoritesList()

class FavoritesList {
    var Favorites = [String:Favorite]()
    var keys = [String]()
    var loaded: Bool = false
    var breeds = [String:[String]]()
    var totalBreeds: Int = 0
    var breedKeys = [String]()
    
    func calcualateBreeds() {
        breeds = [String:[String]]()
        totalBreeds = 0
        breedKeys = [String]()
        var i = 0
        
        while i < keys.count {
            let favBreed = self[i].breed
            if let _ = breeds[favBreed] {
                breeds[favBreed]!.append(keys[i])
            }
            else {
                breeds[favBreed] = [String]()
                breeds[favBreed]!.append(keys[i])
                breedKeys.append(favBreed)
                totalBreeds += 1
            }
            i += 1
        }
        breedKeys = breedKeys.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
    }
    
    func assignStatus(_ tv: UITableView, completion: @escaping (_ favorites: [String: Favorite]) -> Void) {
        
        var i = 0
        var catIDs: [String] = []
        while i < keys.count {
            if !self[i].petID.hasSuffix("_PetFinder") {
                catIDs.append(self[i].petID.components(separatedBy: "_")[0])
            }
            i += 1
        }
        
        if catIDs.count == 0 {return}
        
        let json = ["apikey":"0doJkmYU","objectType":"animals","objectAction":"publicSearch", "search": ["resultStart": "0", "resultLimit":String(catIDs.count), "resultSort": "animalLocationDistance", "resultOrder": "asc", "calcFoundRows": "Yes", "filters": [["fieldName": "animalSpecies", "operation": "equals", "criteria": "cat"],["fieldName": "animalID", "operation": "equals", "criteria": catIDs]], "fields": ["animalID","animalStatus","animalAdoptedDate","animalAvailableDate","animalAdoptionPending"]]] as [String : Any]
        
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            
            let myURL = URL(string: "https://api.rescuegroups.org/http/v2.json")!
            let request = NSMutableURLRequest(url: myURL)
            request.httpMethod = "POST"
            
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
                data, response, error in
                if error != nil {
                    print("Get Error")
                } else {
                    do {
                        let jsonObj:AnyObject =  try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as! NSDictionary
                        
                        if let dict = jsonObj as? [String: AnyObject] {
                            for (key, data) in dict {
                                if key == "data" {
                                    var petID: String = ""
                                    var status: String = ""
                                    var adoptedDate: String = ""
                                    var availableDate: String = ""
                                    var adoptionPending: String = ""
                                    
                                    if let dict2 = data as? [String: AnyObject] {
                                        for (_, data2) in dict2 {
                                            if let dict3 = data2 as? [String: AnyObject] {
                                                for (key, data3) in dict3 {
                                                    switch key {
                                                        case "animalID": petID = data3 as! String
                                                        case "animalStatus": status = data3 as! String
                                                        case "animalAdoptedDate": adoptedDate = data3 as! String
                                                        case "animalAvailableDate": availableDate = data3 as! String
                                                        case "animalAdoptionPending": adoptionPending = data3 as! String
                                                        default: break
                                                    }
                                                }
                                                if petID != "" {
                                                    if var FavoriteStatus = self.Favorites[petID + "_RescueGroup"] {
                                                        if adoptionPending == "Yes" {
                                                            self.Favorites[petID + "_RescueGroup"]?.Status = "Adoption Pending"
                                                        } else if status == "Adopted" {
                                                            self.Favorites[petID + "_RescueGroup"]?.Status = status + " " + adoptedDate
                                                        } else if status == "Available" {
                                                            self.Favorites[petID + "_RescueGroup"]?.Status = status + " " + availableDate
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        completion(self.Favorites)
                        
                    } catch let error as NSError {
                        // error handling
                        print(error.localizedDescription)
                    }
                }
            }) 
            task.resume()
        } catch { }
    }
    
    func countBreedsInSection(_ section: Int) -> Int {
        let b = breedKeys[section]
        let b2 = breeds[b]
        return b2!.count
    }
    
    subscript (index: Int) -> Favorite {
        get {
            let k: String = keys[index];
            return Favorites[k]!;
        }
    }
    
    subscript (section: Int, index: Int) -> Favorite {
        get {
            return self[breeds[breedKeys[section]]![index]]
        }
    }
    
    subscript (petID: String) -> Favorite {
        get {
            return Favorites[petID]!
        }
    }
    
    var count: Int {
        return Favorites.count
    }
    
    func checkPetID(_ petID: String, ds: DataSource) -> String {
        var pID: String = petID
        if pID.range(of: "_") == nil {
            pID = pID + "_" +  ds.rawValue
        }
        return pID
    }
    
    func addFavorite(_ petID: String, f: Favorite) {
        let pID = checkPetID(petID, ds: f.FavoriteDataSource)
        Favorites[pID] = f
        
        if (!keys.contains(pID)) {
            keys.append(pID)
        }
        
        DatabaseManager.sharedInstance.addFavorite(pID, f: f)
        
        calcualateBreeds()
    }
    
    func removeFavorite(_ petID: String, dataSource: DataSource) {
        let pID = checkPetID(petID, ds: dataSource)
        Favorites.removeValue(forKey: pID)
        var i = 0
        
        while i < keys.count {
            if (keys[i] == pID) {
                keys.remove(at: i)
            }
            i += 1
        }
        
        DatabaseManager.sharedInstance.removeFavorite(pID)
        
        calcualateBreeds()
    }
    
    func isFavorite(_ petID: String, dataSource: DataSource) -> Bool {
        let pID = checkPetID(petID, ds: dataSource)
        if let _ = Favorites[pID] {
            return true
        }
        else {
            return false
        }
    }
    
    func LoadFavorites() {
        self.Favorites = [:]
        self.keys = []
        DatabaseManager.sharedInstance.fetchFavorites(keys, favorites: Favorites) { (favorites, keys) -> Void in
            self.Favorites = favorites
            self.keys = keys
        }
        
        calcualateBreeds()
        
        loaded = true
    }
}
