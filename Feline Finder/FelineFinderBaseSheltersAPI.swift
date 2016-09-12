//
//  FelineFinderBaseSheltersAPI.swift
//  Feline Finder
//
//  Created by Gregory Williams on 9/1/16.
//  Copyright © 2016 Gregory Williams. All rights reserved.
//

import Foundation

//var Shelters = RescueGroupShelterList()
//var Shelters = PetFinderShelterList()
var Shelters = RescueGroupShelterList()
var PetFinderShelters = PetFinderShelterList()

struct shelter {
    let dateCreated = NSDate()
    let id: String
    let name: String
    let address1: String
    let address2: String
    let city: String
    let state: String
    let zipCode: String
    let country: String
    let latitude: Double
    let longitude: Double
    let phone: String
    let fax: String
    let email: String
    init (i: String, n: String, a1: String, a2: String, c: String, s: String, z: String, lat: Double, lng:Double, c2: String, p: String, f: String, e: String) {
        id = i
        name = n
        address1 = a1
        address2 = a2
        city = c
        state = s
        zipCode = z
        country = c2
        latitude = lat
        longitude = lng
        phone = p
        fax = f
        email = e
    }
}

class ShelterList {
    var loading: Bool = true
    var sh = [String: shelter]()
    var dateCreated = NSDate()
    var lastOffset: String = ""
    
    var count: Int {
        return sh.count
    }
    
    func loadSingleShelter(shelterID: String, completion: (shelter) -> Void) -> Void {
    }
    
    func loadShelters(zc: String) {
     }
}
