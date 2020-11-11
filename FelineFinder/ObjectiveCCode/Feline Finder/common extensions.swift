//
//  common extensions.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/27/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import Foundation

public extension Collection {

    /// Convert self to JSON String.
    /// Returns: the pretty printed JSON string or an empty string if any error occur.
    func json() -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
            return String(data: jsonData, encoding: .utf8) ?? "{}"
        } catch {
            print("json serialization error: \(error)")
            return "{}"
        }
    }
}

public extension Date {
    static func setToDateTime (dateString: String = "", formatString: String = "yyyy-MM-dd") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatString
        return dateFormatter.date(from: dateString)!
    }
}



let INITIAL_DATE = Date.setToDateTime(dateString: "1900-01-01")
let ALL_BREEDS = "All Breeds"
let FAVORITES = "FAVORITES"


