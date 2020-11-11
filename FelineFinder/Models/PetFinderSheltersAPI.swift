//
//  PetFinderSheltersAPI.swift
//  FelineFinder
//
//  Created by Gregory Williams on 7/5/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation

class PetFinderShelterList: ShelterList {
/*
    override func loadSingleShelter(_ shelterID: String, completion: @escaping (shelter) -> Void) -> Void {
        super.loadSingleShelter(shelterID, completion: completion)
        /*
        if let s = globalShelterCache[shelterID] {
            print("shelter in cache = |\(shelterID)|")
            //Supposed to refresh the PetFinder data every 24 hours
            let hoursSinceCreation = (Calendar.current as NSCalendar).components(NSCalendar.Unit.hour, from: s.dateCreated as Date, to: Date(), options: []).hour
            if hoursSinceCreation! < 24 {
                print("returning cached shelter = |\(shelterID)|")
                completion(s)
                return
            }
        }
        */
        if Utilities.isNetworkAvailable() {
            let rsTransGet: RSTransaction = RSTransaction(transactionType: RSTransactionType.get, baseURL: Utilities.petFinderAPIURL(), path: "shelter.get", parameters: ["key" :Utilities.apiKey(), "id":shelterID, "format":"json"])
            let rsRequest: RSTransactionRequest = RSTransactionRequest()
            rsRequest.dataFromRSTransaction(rsTransGet, completionHandler: { (response : URLResponse!, responseData: Data!, error: NSError!) -> Void in
                if error == nil {
                    let json = JSON(data: responseData)
                    let s = json[ShelterTags.PETFINDER_TAG][ShelterTags.SHELTER_TAG]
                    let cachedShelter = self.createShelter(s)
                    //sh[cachedShelter.id] = cachedShelter
                    print("fetched shelter = |\(shelterID)|")
                    completion(cachedShelter)
                } else {
                    //If there was an error, log it
                    Utilities.displayAlert("Error Retrieving Shelter Data", errorMessage: error.description)
                    print("Error : \(String(describing: error))")
                }
            } as RSTransactionRequest.dataFromRSTransactionCompletionClosure)
        }
    }
    
    override func loadShelters(_ zc: String) {
        super.loadShelters(zc)
        //var s: shelter?
        var i = 0
        
        loading = true
        
        dateCreated = Date()
        
        if (Utilities.isNetworkAvailable() == false) {
            return
        }
     
        let rsTransGet: RSTransaction = RSTransaction(transactionType: RSTransactionType.get, baseURL: Utilities.petFinderAPIURL(), path: "shelter.find", parameters: ["key" :Utilities.apiKey(), "location":zc, "format":"json"])
        let rsRequest: RSTransactionRequest = RSTransactionRequest()
        rsRequest.dataFromRSTransaction(rsTransGet, completionHandler: { (response : URLResponse!, responseData: Data!, error: NSError!) ->
            Void in
            if error == nil {
                let json = JSON(data: responseData)
                if let lo = json[ShelterTags.PETFINDER_TAG][ShelterTags.LASTOFFSET_TAG][ShelterTags.T_TAG].string {
                    self.lastOffset = lo
                } else {
                    self.lastOffset = ""
                }
                
                while i < json[ShelterTags.PETFINDER_TAG][ShelterTags.SHELTERS_TAG][ShelterTags.SHELTER_TAG].count {
                    let s = json[ShelterTags.PETFINDER_TAG][ShelterTags.SHELTERS_TAG][ShelterTags.SHELTER_TAG][i]
                    let cachedShelter = self.createShelter(s)
                    //sh[cachedShelter.id] = cachedShelter
                    self.loading = false
                    i += 1
                }
            } else {
                //If there was an error, log it
                Utilities.displayAlert("Error Retrieving Shelter Data", errorMessage: error.description)
                print("Error : \(String(describing: error))")
            }
        } as RSTransactionRequest.dataFromRSTransactionCompletionClosure)
    }
    
    func addValue(_ tagName: String, value: JSON) -> String
    {
        if let v = value[tagName][ShelterTags.T_TAG].string {
            return v
        } else {
            return ""
        }
    }
    
    func createShelter(_ s: JSON) -> shelter {
        let id = addValue(ShelterTags.ID_TAG, value: s)
        let name = addValue(ShelterTags.NAME_TAG, value: s)
        let address1 = addValue(ShelterTags.ADRESS1_TAG, value: s)
        let address2 = addValue(ShelterTags.ADRESS2_TAG, value: s)
        let city = addValue(ShelterTags.CITY_TAG, value: s)
        let state = addValue(ShelterTags.STATE_TAG, value: s)
        let zipCode = addValue(ShelterTags.ZIP_TAG, value: s)
        let country = addValue(ShelterTags.COUNTRY_TAG, value: s)
        let phone = addValue(ShelterTags.PHONE_TAG, value: s)
        let fax = addValue(ShelterTags.FAX_TAG, value: s)
        let email = addValue(ShelterTags.EMAIL_TAG, value: s)
        
        var latitude: Double?
        var longitude: Double?
        
        if let lat = s[ShelterTags.LATITUDE_TAG][ShelterTags.T_TAG].string {
            latitude = NSString(string: lat).doubleValue
        }
        else {
            latitude = 0.0
        }
        if let lng = s[ShelterTags.LONGITUDE_TAG][ShelterTags.T_TAG].string {
            longitude = NSString(string: lng).doubleValue
        }
        else {
            longitude = 0.0
        }

        return shelter(i: id, n: name, a1: address1, a2: address2, c: city, s: state, z: zipCode, lat: latitude!, lng: longitude!, c2: country, p: phone, f: fax, e: email)
    }
 */
}

struct ShelterTags {
    static let PETFINDER_TAG = "petfinder"
    static let SHELTERS_TAG = "shelters"
    static let SHELTER_TAG = "shelter"
    static let ID_TAG = "id"
    static let T_TAG = "$t"
    static let NAME_TAG = "name"
    static let ADRESS1_TAG = "address1"
    static let ADRESS2_TAG = "address2"
    static let CITY_TAG = "city"
    static let STATE_TAG = "state"
    static let ZIP_TAG = "zip"
    static let COUNTRY_TAG = "country"
    static let LATITUDE_TAG = "latitude"
    static let LONGITUDE_TAG = "longitude"
    static let PHONE_TAG = "phone"
    static let FAX_TAG = "fax"
    static let EMAIL_TAG = "email"
    static let LASTOFFSET_TAG = "lastOffset"
}


