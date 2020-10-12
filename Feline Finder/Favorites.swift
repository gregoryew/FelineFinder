//
//  Favorites.swift
//  FelineFinder
//
//  Created by Gregory Williams on 8/23/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation

struct rgpicture: Codable {
    var type: String?
    var fileSize: String?
    var resolutionX: String?
    var resolutionY: String?
    var url: String?
}

struct pictures: Codable {
    var mediaID: String?
    var mediaOrder: String?
    var lastUpdated: String?
    var fileSize: String?
    var resolutionX: String?
    var resolutionY: String?
    var fileNameFullsize: String?
    var fileNameThumbnail: String?
    var urlSecureFullSize: String?
    var urlSecureThumbnail: String?
    var urlInsecureFullSize: String?
    var urlInsecureThumbnail: String?
    var original: rgpicture?
    var large: rgpicture?
    var small: rgpicture?
}

struct data: Codable {
    var animalID: String?
    var animalName: String?
    var animalPrimaryBreed: String?
    var animalPictures: [pictures]?
    var animalStatus: String?
}

struct output: Codable {
    var status: String?
    var messages: [String: [String]?]?
    var foundRows: Int?
    var data: [String: data]?
}

struct Favorite {
    var petID: String
    var petName: String
    var imageName: String
    var breed: String
    var FavoriteDataSource: DataSource
    var Status: String
}

class FavoritesList {
    var iCloudKeyStore: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default
    var Favorites = [String:Favorite]()
    var IDs:[String] = []
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
            guard breedKeys.count > 0 else {return Favorite(petID: "", petName: "", imageName: "", breed: "", FavoriteDataSource: DataSource.RescueGroup, Status: "")}
            return self[breeds[breedKeys[section]]![index]]
        }
    }
    
    subscript (petID: String) -> Favorite {
        get {
            if let f = Favorites[petID] {
                return f
            } else {
                return Favorite(petID: "", petName: "", imageName: "", breed: "", FavoriteDataSource: DataSource.RescueGroup, Status: "")
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
        let f = Favorite(petID: pID, petName: "", imageName: "", breed: "", FavoriteDataSource: DataSource.RescueGroup, Status: "")
        Favorites[pID] = f
        
        if (!keys.contains(pID)) {
            keys.append(pID)
            IDs = keys
        }
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
    
    func LoadFavorites(tv: UITableView?) {
        loaded = false
        
        if (Utilities.isNetworkAvailable() == false) {
            return
        }
                
        loadIDs()
                
        var i = 0
        var catIDs: [String] = []
        while i < IDs.count {
            if IDs[i].hasSuffix("_PetFinder") ||  IDs[i].hasSuffix("_RescueGroup") {
                catIDs.append(IDs[i].components(separatedBy: "_")[0])
            } else {
                catIDs.append(IDs[i])
            }
            i += 1
        }
        
        if catIDs.count == 0 {return}

        let session = URLSession.shared
        let url = URL(string: "https://api.rescuegroups.org/http/v2.json")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var filters:[filter] = []
        
        filters.append(["fieldName": "animalSpecies" as AnyObject, "operation": "equals" as AnyObject, "criteria": "cat" as AnyObject])
        filters.append(["fieldName": "animalID" as AnyObject, "operation": "equals" as AnyObject, "criteria": catIDs as AnyObject])
        
        let json = ["apikey":"0doJkmYU","objectType":"animals","objectAction":"publicSearch", "search": ["resultLimit":catIDs.count, "calcFoundRows": "Yes", "filters": filters, "fields": ["animalID", "animalName", "animalPrimaryBreed", "animalPictures", "animalStatus"]]] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
        
        let task = session.uploadTask(with: request, from: jsonData) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                let favorites = try! decoder.decode(output.self, from: data)
                self.Favorites = [:]
                self.keys = []
                for (id, data) in favorites.data! {
                    self.Favorites[id + "_RescueGroup"] = Favorite(petID: data.animalID ?? "0", petName: data.animalName ?? "", imageName: data.animalPictures![0].small!.url!, breed: data.animalPrimaryBreed ?? "", FavoriteDataSource: DataSource.RescueGroup, Status: data.animalStatus ?? "")
                    self.keys.append(id + "_RescueGroup")
                }
                self.calcualateBreeds()
                if let tv = tv {
                    DispatchQueue.main.async {
                        tv.reloadData()
                    }
                }
                self.loaded = true
            }
        }

        task.resume()
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

extension Array where Element : Equatable{
    
    public mutating func mergeElements<C : Collection>(newElements: C) where C.Iterator.Element == Element{
        let filteredList = newElements.filter({!self.contains($0)})
        self.append(contentsOf: filteredList)
    }
}
