//
//  RescueGroupFilter.swift
//  FelineFinder
//
//  Created by Gregory Williams on 3/18/21.
//

import Foundation

struct RescueGroupQuery: Codable {
    var data: DataStruct
}

struct DataStruct: Codable {
    var filterRadius: filterRadiusStruct
    var filters: [filtersStruct]
}

struct filterRadiusStruct: Codable {
    var postalcode: String
    var miles: Int
}

struct filtersStruct: Codable {
    var fieldName: String
    var operation: String
    var criteria: [String]
}
