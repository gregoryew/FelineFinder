//
//  OfflineQuery.swift
//  FelineFinder
//
//  Created by Gregory Williams on 3/16/21.
//

import Foundation

struct OfflineQuery: Codable {
    let userId: String
    let name: String
    let created: Date
    let query: String
    
    init(userID: UUID, name: String, created: Date, query: [String: Any]) {
        self.userId = userID.uuidString
        self.name = name
        self.created = Date()
        self.query = OfflineQuery.stringify(json: query, prettyPrinted: false)
    }
    
    static func stringify(json: Any, prettyPrinted: Bool = false) -> String {
        var options: JSONSerialization.WritingOptions = []
        if prettyPrinted {
          options = JSONSerialization.WritingOptions.prettyPrinted
        }

        do {
          let data = try JSONSerialization.data(withJSONObject: json, options: options)
          if let string = String(data: data, encoding: String.Encoding.utf8) {
            return string
          }
        } catch {
          print(error)
        }

        return ""
    }
}
