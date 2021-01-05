//
//  Favorites.swift
//  FelineFinder
//
//  Created by Gregory Williams on 8/23/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation

class FavoritesList {
    var iCloudKeyStore: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default
    var loaded: Bool = false
    var catIDs: [String] = []
            
    var count: Int {
        return catIDs.count
    }
    
    func checkPetID(_ petID: String, ds: DataSource) -> String {
        var pID: String = petID
        if pID.range(of: "_") == nil {
            pID = pID + "_" +  ds.rawValue
        }
        return pID
    }
    
    func addFavorite(_ petID: String) {
        var pID = petID
        
        if petID.hasSuffix("_PetFinder") ||  petID.hasSuffix("_RescueGroup") {
            pID = petID.components(separatedBy: "_")[0]
        }
        
        if (!catIDs.contains(pID)) {
            catIDs.append(pID)
        }
    }
    
    func removeFavorite(_ petID: String, dataSource: DataSource) {
        catIDs.removeAll { (ID) -> Bool in
            return ID == petID
        }
    }
    
    func isFavorite(_ petID: String, dataSource: DataSource) -> Bool {
        var pID = petID
        
        if pID.hasSuffix("_PetFinder") ||  pID.hasSuffix("_RescueGroup") {
            pID = pID.components(separatedBy: "_")[0]
        }
        
        return catIDs.contains(petID)
    }
    
    func LoadFavorites() {
        loaded = false
        
        if (Utilities.isNetworkAvailable() == false) {
            return
        }
                
        catIDs = loadIDs()
        
        var i = 0
        while i < catIDs.count {
            if catIDs[i].hasSuffix("_PetFinder") ||  catIDs[i].hasSuffix("_RescueGroup") {
                catIDs[i] = catIDs[i].components(separatedBy: "_")[0]
            }
            i += 1
        }
        
        loaded = true
    }
    
    func loadIDs() -> [String] {
        let keyStore = NSUbiquitousKeyValueStore()
        if let id = keyStore.array(forKey: "FavoriteIDs") {
            return id as! [String]
        } else {
            return []
        }
    }
    
    func storeIDs() {
        let keyStore = NSUbiquitousKeyValueStore()
        keyStore.set(catIDs, forKey: "FavoriteIDs")
        keyStore.synchronize()
    }
}

extension Array where Element : Equatable{
    
    public mutating func mergeElements<C : Collection>(newElements: C) where C.Iterator.Element == Element{
        let filteredList = newElements.filter({!self.contains($0)})
        self.append(contentsOf: filteredList)
    }
}
