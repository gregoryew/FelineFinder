//
//  FelineFinderBaseSheltersAPI.swift
//  Feline Finder
//
//  Created by Gregory Williams on 9/1/16.
//  Copyright © 2016 Gregory Williams. All rights reserved.
//

import Foundation

var Shelters = RescueGroupShelterList()

struct shelter {
    let dateCreated = Date()
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
    let adoptionUrl: String
    let url: String
    init (i: String, n: String, a1: String, a2: String, c: String, s: String, z: String, lat: Double, lng:Double, c2: String, p: String, f: String, e: String, aw: String, url: String) {
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
        adoptionUrl = aw
        self.url = url
    }
}

//var globalShelterCache = [String: shelter]()

class ShelterList {
    var loading: Bool = true
    var dateCreated = Date()
    var lastOffset: String = ""
    
    var count: Int {
        return globalShelterCache.count
    }
    
    func loadSingleShelter(_ shelterID: String, completion: @escaping (shelter) -> Void) -> Void  {
    }
    
    func loadShelters(_ zc: String) {
     }
}
