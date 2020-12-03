//
//  PetImage.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/20/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import Foundation

struct PetImage: Codable {
    var URL: String
    var height: Int
    var width: Int
    init (url: String, h: Int, w: Int) {
        URL = url
        height = h
        width = w
    }
}

struct PetImages: Codable {
    var ImageArray: [PetImage]
}
