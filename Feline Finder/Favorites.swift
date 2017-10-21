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

class FavoritesList {
    var iCloudKeyStore: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default
    var Favorites = [String:Favorite]()
    var keys = [String]()
    var loaded: Bool = false
    var breeds = [String:[String]]()
    var totalBreeds: Int = 0
    var breedKeys = [String]()
    var status = ""
    
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
    
    func loadFavoritePets(completion: @escaping (_ f: FavoritesList) -> Void) -> Void {
        loaded = false
        
        if (Utilities.isNetworkAvailable() == false) {
            return
        }
        
        if IDs.count == 0 {return}
        
        var i = 0
        var catIDs: [String] = []
        while i < IDs.count {
            if Favorites[IDs[i]]?.breed != "" {
                i += 1
            } else {
            if IDs[i].hasSuffix("_PetFinder") ||  IDs[i].hasSuffix("_RescueGroup") {
                catIDs.append(IDs[i].components(separatedBy: "_")[0])
            } else {
                catIDs.append(IDs[i])
            }
            i += 1
            }
        }
        
        var filters:[filter] = []
        
        filters.append(["fieldName": "animalSpecies" as AnyObject, "operation": "equals" as AnyObject, "criteria": "cat" as AnyObject])
        filters.append(["fieldName": "animalID" as AnyObject, "operation": "equals" as AnyObject, "criteria": catIDs as AnyObject])
        
        let json = ["apikey":"0doJkmYU","objectType":"animals","objectAction":"publicSearch", "search": ["calcFoundRows": "Yes", "filters": filters, "fields": ["animalID", "animalName", "animalPrimaryBreed", "animalPictures", "animalStatus"]]] as [String : Any]
        
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            
            let myURL = URL(string: "https://api.rescuegroups.org/http/v2.json")!
            let request = NSMutableURLRequest(url: myURL)
            request.httpMethod = "POST"
            
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            request.httpBody = jsonData
            
            var animalID = ""
            var animalName = ""
            var animalPrimaryBreed = ""
            var animalPictures: [picture] = [picture]()
            var animalStatus = ""
            //self.Favorites = [:]
            
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
                data, response, error in
                if error != nil {
                    print("Get Error")
                    Utilities.displayAlert("Sorry There Was A Problem", errorMessage: "An error occurred while trying to display pet data.")
                } else {
                    //var error:NSError?
                    do {
                        let jsonObj:AnyObject =  try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as! NSDictionary
                        if let dict = jsonObj as? [String: AnyObject] {
                            for (key, data) in dict {
                                if key == "status" {
                                    self.status = data as! String
                                    print("Status = |\(self.status)|")
                                } else if key == "data" {
                                    if let d = data as? [String: AnyObject] {
                                        for (_, data2) in d {
                                            if let d2 = data2 as? [String: AnyObject] {
                                                for (key3, data3) in d2 {
                                                    switch key3 {
                                                        case "animalID":
                                                            animalID = data3 as! String
                                                            break
                                                        case "animalName":
                                                            animalName = data3 as! String
                                                            break
                                                        case "animalPrimaryBreed":
                                                            animalPrimaryBreed = data3 as! String
                                                            break
                                                        case "animalPictures":
                                                            animalPictures = parsePictures(data3 as! [AnyObject])
                                                            break
                                                        case "animalStatus":
                                                            animalStatus = data3 as! String
                                                            break
                                                        default: break
                                                    }
                                                }
                                                var animalPicture = ""
                                                for img: picture in animalPictures {
                                                    if img.idnum == 1 && img.size == "pnt" {
                                                        animalPicture = img.URL
                                                        break
                                                    }
                                                }
                                                self.Favorites[animalID + "_RescueGroup"] = Favorite(id: animalID, n: animalName, i: animalPicture, b: animalPrimaryBreed, d: DataSource.RescueGroup, s: animalStatus)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        self.loaded = true
                        completion(self)
                    } catch let error as NSError {
                        // error handling
                        Utilities.displayAlert("Sorry There Was A Problem", errorMessage: error.description)
                        print(error.localizedDescription)
                    }
                }
            })
            task.resume() } catch { }
    }

    
    func assignStatus(_ tv: UITableView, completion: @escaping (_ favorites: [String: Favorite]) -> Void) {
        
        loadFavoritePets(completion: {(f) in
        self.Favorites = f.Favorites
        self.calcualateBreeds()
            _ = 0
        /*
        var catIDs: [String] = []
        while i < self.keys.count {
            if !self[i].petID.hasSuffix("_PetFinder") {
                catIDs.append(self[i].petID.components(separatedBy: "_")[0])
            }
            i += 1
        }
        */
        
            /*
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
            let task = URLSession.shared.dataTask( with: request as URLRequest, completionHandler: { [unowned self]
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
                                                    if self.Favorites[petID + "_RescueGroup"] != nil {
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
                        */
                        completion(self.Favorites)
        })
                       /*
                    } catch let error as NSError {
                        // error handling
                        print(error.localizedDescription)
                    }
                }
            }) 
            task.resume()
        } catch { }
        })
    */
    }
    
    func countBreedsInSection(_ section: Int) -> Int {
        if breedKeys.count == 0 {return 0}
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
            guard breedKeys.count > 0 else {return Favorite(id: "", n: "", i: "", b: "", d: DataSource.RescueGroup, s: "")}
            return self[breeds[breedKeys[section]]![index]]
        }
    }
    
    subscript (petID: String) -> Favorite {
        get {
            if let f = Favorites[petID] {
                return f
            } else {
                return Favorite(id: "", n: "", i: "", b: "", d: DataSource.RescueGroup, s: "")
            }
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
        let pID = checkPetID(petID, ds: DataSource.RescueGroup)
        let f = Favorite(id: pID, n: "", i: "", b: "", d: DataSource.RescueGroup, s: "")
        Favorites[pID] = f
        
        if (!keys.contains(pID)) {
            keys.append(pID)
            IDs = keys
            storeIDs()
        }
        
        //DatabaseManager.sharedInstance.addFavorite(pID, f: f)
        
        //calcualateBreeds()
    }
    
    func removeFavorite(_ petID: String, dataSource: DataSource) {
        let pID = checkPetID(petID, ds: DataSource.RescueGroup)
        Favorites.removeValue(forKey: pID)
        var i = 0
        
        while i < keys.count {
            if (keys[i] == pID) {
                keys.remove(at: i)
            }
            i += 1
        }
        
        IDs = keys
        
        storeIDs()
        
        //DatabaseManager.sharedInstance.removeFavorite(pID)
        
        //calcualateBreeds()
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
    
    func LoadFavoritesDB() {
        //self.Favorites = [:]
        self.keys = []
        DatabaseManager.sharedInstance.fetchFavorites(keys, favorites: Favorites) { (favorites, keys) -> Void in
            self.Favorites = favorites
            self.keys = keys
        }
        
        loadIDs()
        
        calcualateBreeds()
        
        loaded = true
    }
    
    func LoadFavorites() {
        //self.Favorites = [:]
        //self.keys = []
        for f in self.Favorites {
            let pID = checkPetID(f.value.petID, ds: DataSource.RescueGroup)
            if !IDs.contains(pID) {
                removeFavorite(pID, dataSource: DataSource.RescueGroup)
            }
        }
        
        self.loadIDs()
        
        for id in IDs {
            let pID = checkPetID(id, ds: DataSource.RescueGroup)
            if self.Favorites[pID] == nil {
                if !keys.contains(pID) {
                    self.keys.append(pID)
                }
                self.Favorites[pID] = Favorite(id: pID, n: "", i: "", b: "", d: DataSource.RescueGroup, s: "")
            }
        }

        self.loaded = true

        /*
        loadFavoritePets() { (f) -> Void in
            self.calcualateBreeds()
            self.loaded = true
        }
        */
    }
    
    func loadIDs() {
        let keyStore = NSUbiquitousKeyValueStore()
        if let id = keyStore.array(forKey: "FavoriteIDs") {
            IDs = id as! [String]
        } else {
            return
        }
    }
    
    func storeIDs() {
        let keyStore = NSUbiquitousKeyValueStore()
        keyStore.set(IDs, forKey: "FavoriteIDs")
        keyStore.synchronize()
    }
}

var IDs:[String] = []

extension Array where Element : Equatable{
    
    public mutating func mergeElements<C : Collection>(newElements: C) where C.Iterator.Element == Element{
        let filteredList = newElements.filter({!self.contains($0)})
        self.append(contentsOf: filteredList)
    }
}
