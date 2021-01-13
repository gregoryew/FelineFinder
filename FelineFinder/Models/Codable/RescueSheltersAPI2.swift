//
//  RescueSheltersAPI2.swift
//  Feline Finder
//
//  Created by gregoryew1 on 9/30/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import UIKit

struct RescueShelterAPI2: Codable {
    var orgID: String?
    var orgName: String?
    var orgAddress: String?
    var orgCity: String?
    var orgState: String?
    var orgLocation: String?
    var orgCountry: String?
    var orgPhone: String?
    var orgFax: String?
    var orgEmail: String?
    var orgWebsite: String?
    var orgAdoptionUrl: String?
    var orgUrl: String?
}

struct RescueSheltersAPI2: Codable {
    var status: String?
    var messages: messages?
    var foundRows: Int?
    var data: [Int: RescueShelterAPI2]
}
