//
//  PetFinderAPI.swift
//  FelineFinder
//
//  Created by Gregory Williams on 7/4/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit

class PetFinderPetList: PetList {
    override func loadSinglePet(petID: String, completion: (Pet) -> Void) -> Void {
        super.loadSinglePet(petID, completion: completion)
        if let p2 = PetsGlobal[petID] {
            //Supposed to refresh the PetFinder data every 24 hours
            let hoursSinceCreation = NSCalendar.currentCalendar().components(NSCalendarUnit.Hour, fromDate: p2.dateCreated, toDate: NSDate(), options: []).hour
            if hoursSinceCreation < 24 {
                completion(p2)
                return
            }
        }
        
        if Utilities.isNetworkAvailable() {
            let rsTransGet: RSTransaction = RSTransaction(transactionType: RSTransactionType.GET, baseURL: Utilities.petFinderAPIURL(), path: "pet.get", parameters: ["key" : Utilities.apiKey(), "id":splitPetID(petID), "format":"json"])
            let rsRequest: RSTransactionRequest = RSTransactionRequest()
            rsRequest.dataFromRSTransaction(rsTransGet, completionHandler: { (response : NSURLResponse!, responseData: NSData!, error: NSError!) -> Void in
                if error == nil {
                    var json = JSON(data: responseData)
                    let p = json[PetTags.PETFINDER_TAG][PetTags.PET_TAG]
                    let cachedPet = self.createPet(p)
                    PetsGlobal[petID] = cachedPet
                    completion(cachedPet)
                } else {
                    //If there was an error, log it
                    Utilities.displayAlert("Error Retrieving Pet Data", errorMessage: error.description)
                    print("Error : \(error)")
                }
            })
        }
    }
    
    override func loadPets(tv: UITableView, bn: Breed, zipCode: String, completion: (p: PetList) -> Void) -> Void {
        super.loadPets(tv, bn: bn, zipCode: zipCode, completion: completion)
        var params = [String: String]()
        var i = 0
        
        loading = true
        
        dateCreated = NSDate() //Reset the cache time
        
        if (Utilities.isNetworkAvailable() == false) {
            return
        }
        
        params = addParams(bn.BreedName, zipCode: zipCode)
        
        let rsTransGet: RSTransaction = RSTransaction(transactionType: RSTransactionType.GET, baseURL: Utilities.petFinderAPIURL(), path: "pet.find", parameters: params)
        let rsRequest: RSTransactionRequest = RSTransactionRequest()
        rsRequest.dataFromRSTransaction(rsTransGet, completionHandler: { (response : NSURLResponse!, responseData: NSData!, error: NSError!) ->
            Void in
            if error == nil {
                var json = JSON(data: responseData)
                
                if let lo = json[PetTags.PETFINDER_TAG][PetTags.LASTOFFSET_TAG][PetTags.T_TAG].string {
                    self.lastOffset = lo
                } else {
                    self.lastOffset = ""
                }
                
                while i < json[PetTags.PETFINDER_TAG][PetTags.PETS_TAG][PetTags.PET_TAG].count {
                    let p = json[PetTags.PETFINDER_TAG][PetTags.PETS_TAG][PetTags.PET_TAG][i]
                    let cachedPet = self.createPet(p)
                    self.Pets.append(cachedPet)
                    PetsGlobal[cachedPet.petID] = cachedPet
                    i += 1
                }
                
                DatabaseManager.sharedInstance.fetchDistancesFromZipCode (self.Pets) { (zC) -> Void in
                    let zipCodes = zC
                    var i  = 0
                    print ("p= " + String(self.Pets.count))
                    while i < self.Pets.count {
                        print ("i=" + String(i))
                        if self.Pets[i].zipCode.isNumber == true {
                            if let dist = zipCodes[self.Pets[i].zipCode]?.distance {
                                self.Pets[i].distance = dist
                            }
                        } else {
                            self.Pets[i].distance = -1
                        }
                        i += 1
                    }
                }
                
                //distances.removeAll()
                self.assignDistances()
                self.loading = false
                completion(p: self)
            } else {
                //If there was an error, log it
                Utilities.displayAlert("Error Retrieving Pet Data", errorMessage: error.description)
                print("Error : \(error)")
            }
        })
    }
    
    func addParams(bn: String, zipCode: String) -> [String: String] {
        
        let bn2 = bn.stringByReplacingOccurrencesOfString("\n", withString: "")
        
        var params: [String: String]
        
        if bn2 == "All Breeds" {
            params = ["key":Utilities.apiKey(), "animal":"cat", "count":"25", "location":zipCode, "format":"json"]
        } else {
            params = ["key":Utilities.apiKey(), "animal":"cat", "count":"25", "breed":bn2, "location":zipCode, "format":"json"]
        }
        
        if lastOffset != "" {
            params["offset"] = lastOffset
        }
        /*
        if nSex != UISegmentedControlNoSegment {
            if nSex == 0 {
                params["sex"] = "M"
            } else if nSex == 1 {
                params["sex"] = "F"
            } else {
                print("pet has a sex not in the list.")
            }
        }
        
        if nAge != UISegmentedControlNoSegment {
            switch nAge {
            case 0:
                params["age"] = "Baby"
            case 1:
                params["age"] = "Young"
            case 2:
                params["age"] = "Adult"
            case 3:
                params["age"] = "Senior"
            default:
                print("pet has an age not in the list.")
            }
        }
        
        if nSize != UISegmentedControlNoSegment {
            switch nSize {
            case 0:
                params["size"] = "S"
            case 1:
                params["size"] = "M"
            case 2:
                params["size"] = "L"
            case 3:
                params["size"] = "X"
            default:
                print("pet has a size not in the list.")
            }
        }
        */
        return params
    }
    
    func decodeOption(optName: String) -> String {
        switch optName {
            case "altered": return "Spayed / Neutered"
            case "noClaws": return "No Claws"
            case "hasShots": return "Has Current Shots"
            case "housebroken": return "Housebroken"
            case "housetrained": return "Housetrained"
            case "noCats": return "Not Good With Cats"
            case "noDogs": return "Not Good With Dogs"
            case "noKids": return "Not Good With Kids"
            case "specialNeeds": return "Has Special Needs"
            default: return ""
        }
    }
    
    func createPet(p: JSON) -> Pet {
        var petID: String?
        var name: String?
        var breeds: Set<String> = Set<String>()
        var mix: Bool?
        var age: String?
        var sex: String?
        var size: String?
        var options: Set<String> = Set<String>()
        var description: String?
        var lastUpdated: String?
        var media = [picture]()
        var idnum: Int?
        var picSize: String?
        var URL: String?
        var sID: String?
        var zipCode: String?
        
        if let pID = p[PetTags.ID_TAG][PetTags.T_TAG].string{
            petID = pID
        } else {
            petID = ""
        }
        if let catName = p[PetTags.NAME_TAG][PetTags.T_TAG].string{
            name = catName
        }
        else {
            name = "Unknown cat name"
        }
        breeds = Set<String>()
        var c = p[PetTags.BREEDS_TAG]
        let c2 = c[PetTags.BREED_TAG].count
        if (c2 == 1) {
            if let bName = p[PetTags.BREEDS_TAG][PetTags.BREED_TAG][PetTags.T_TAG].string {
                breeds.insert(bName)
            }
        } else {
            var j = 0
            while j < c2 {
                if let bName = p[PetTags.BREEDS_TAG][PetTags.BREED_TAG][j][PetTags.T_TAG].string {
                    breeds.insert(bName)
                }
                j += 1
            }
        }
        if let isMix = p[PetTags.MIX_TAG][PetTags.T_TAG].string {
            if isMix == "yes" {
                mix = true
            } else {
                mix = false
            }
        } else {
            mix = true
        }
        if let s = p[PetTags.SEX_TAG][PetTags.T_TAG].string {
            if (s == "M") {
                sex = "Male"
            } else if (s == "F") {
                sex = "Female"
            } else {
                sex = "Unknown"
            }
        } else {
            sex = "Unknown"
        }
        //["S","M","L","XL"]
        if let s2 = p[PetTags.SIZE_TAG][PetTags.T_TAG].string {
            switch s2 {
            case "S": size = "Small"
            case "M": size = "Medium"
            case "L": size = "Large"
            case "XL": size = "Extra Large"
            default: size = "Unknown"
            }
        } else {
            size = "Unknown"
        }
        //["Baby","Young","Adult","Senior"]
        if let a = p[PetTags.AGE_TAG][PetTags.T_TAG].string {
            switch a {
            case "Baby": age = "Baby"
            case "Young": age = "Young"
            case "Adult": age = "Adult"
            case "Senior": age = "Senior"
            default: age = "Unknown"
            }
        } else {
            age = "Unknown"
        }
        options = Set<String>()
        if (p[PetTags.OPTIONS_TAG][PetTags.OPTION_TAG].count == 1)
        {
            if let optName = p[PetTags.OPTIONS_TAG][PetTags.OPTION_TAG][PetTags.T_TAG].string {
                options.insert(decodeOption(optName))
            }
        } else {
            var j = 0
            while j < p[PetTags.OPTIONS_TAG][PetTags.OPTION_TAG].count {
                if let optName = p[PetTags.OPTIONS_TAG][PetTags.OPTION_TAG][j][PetTags.T_TAG].string {
                    options.insert(decodeOption(optName))
                }
                j += 1
            }
        }
        if options.count == 0 {
            options.insert("None")
        }
        if let desc = p[PetTags.DESCRIPTION_TAG][PetTags.T_TAG].string {
            description = desc
        } else {
            description = ""
        }
        if let lastupd = p[PetTags.LASTUPDATE_TAG][PetTags.T_TAG].string {
            lastUpdated = lastupd
        } else {
            lastUpdated = ""
        }
        if let sid = p[PetTags.SHELTERID_TAG][PetTags.T_TAG].string {
            sID = sid
        } else {
            sID = ""
        }
        if let z = p[PetTags.CONTACT_TAG][PetTags.ZIP_TAG][PetTags.T_TAG].string {
            zipCode = z
        } else {
            zipCode = ""
        }
        media = [picture]()
        var j = 0
        while j < p[PetTags.MEDIA_TAG][PetTags.PHOTOS_TAG][PetTags.PHOTO_TAG].count {
            idnum = 0
            if let idn = p[PetTags.MEDIA_TAG][PetTags.PHOTOS_TAG][PetTags.PHOTO_TAG][j][PetTags.ATID_TAG].string {
                idnum = Int(idn)
            }
            //["pnt", "fpm", "x", "pn", "t"]
            picSize = ""
            if let ps = p[PetTags.MEDIA_TAG][PetTags.PHOTOS_TAG][PetTags.PHOTO_TAG][j][PetTags.ATSIZE_TAG].string {
                picSize = ps
            }
            URL = nil
            if let u = p[PetTags.MEDIA_TAG][PetTags.PHOTOS_TAG][PetTags.PHOTO_TAG][j][PetTags.T_TAG].string {
                URL = u
            }
            media.append(picture(i: idnum!, s: picSize!, u: URL!))
            j += 1
        }
        let cachedPet = Pet(pID: petID!, n: name!, b: breeds, m: mix!, a: age!, s: sex!, s2: size!, o: options, d: description!, lu: lastUpdated!, m2: media, s3: sID!, z: zipCode!, dis: 0)
        return cachedPet
    }
}

struct PetTags {
    static let PETFINDER_TAG = "petfinder"
    static let PETS_TAG = "pets"
    static let PET_TAG = "pet"
    static let ID_TAG = "id"
    static let T_TAG = "$t"
    static let NAME_TAG = "name"
    static let BREEDS_TAG = "breeds"
    static let BREED_TAG = "breed"
    static let MIX_TAG = "mix"
    static let SEX_TAG = "sex"
    static let SIZE_TAG = "size"
    static let AGE_TAG = "age"
    static let OPTIONS_TAG = "options"
    static let OPTION_TAG = "option"
    static let DESCRIPTION_TAG = "description"
    static let LASTUPDATE_TAG = "lastUpdate"
    static let SHELTERID_TAG = "shelterId"
    static let MEDIA_TAG = "media"
    static let PHOTOS_TAG = "photos"
    static let PHOTO_TAG = "photo"
    static let LASTOFFSET_TAG = "lastOffset"
    static let ATID_TAG = "@id"
    static let ATSIZE_TAG = "@size"
    static let CONTACT_TAG = "contact"
    static let ZIP_TAG = "zip"
}