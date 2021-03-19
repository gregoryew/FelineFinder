//
//  User.swift
//  FelineFinder
//
//  Created by Gregory Williams on 3/16/21.
//

import Foundation

struct User: Codable {
    let userId: String
    let token: String
    init(userId: UUID, token: String) {
        self.userId = userId.uuidString
        self.token = token
    }
}
