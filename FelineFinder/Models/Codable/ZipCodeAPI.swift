//
//  ZipCodeAPI.swift
//  FelineFinder
//
//  Created by Gregory Williams on 8/18/21.
//

import UIKit

struct ZipCodeBaseResults: Codable {
    let postal_code: String?
    let country_code: String?
    let latitude: String?
    let longitude: String?
    let city: String?
    let state: String?
    let city_en: String?
    let state_en: String?
    let state_code: String?
    let province: String?
    let province_code: String?
}

struct queryType: Codable {
    let codes: [String]?
    let country: String?
}

struct ZipCodeBase: Codable {
    let query: queryType?
    let results: [String: [ZipCodeBaseResults]]
    let error: String?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            self.query = try container.decodeObject(queryType.self, forKey: .query, defaultValue: queryType(from: decoder))
        } catch {
            self.query = nil
        }
        do {
        self.error = try container.decode(String.self, forKey: .error)
        } catch {
            self.error = ""
        }
        do {
        self.results = try container.decodeObject([String : [ZipCodeBaseResults]].self, forKey: .results, defaultValue: [:])
        } catch {
            self.results = [:]
        }
    }
}

var previousInvalidZipCodes: [String] = []
var previousValidZipCodes: [String] = []

func validPostalCode(postalCode:String)->Bool{
    let postalcodeRegex = "([ABCEGHJKLMNPRSTVXY][0-9][ABCEGHJKLMNPRSTVWXYZ])\\ ?([0-9][ABCEGHJKLMNPRSTVWXYZ][0-9])"
    let pinPredicate = NSPredicate(format: "SELF MATCHES %@", postalcodeRegex)
    let bool = pinPredicate.evaluate(with: postalCode) as Bool
    return bool
}

func validateZipCode(localZipCode: String) -> Bool {
    
    var countryCode = "us"
    
    if localZipCode.count == 0 || localZipCode.count < 5 || localZipCode.count > 7 || previousInvalidZipCodes.contains(localZipCode) {
        return false
    }
    
    if !validPostalCode(postalCode: localZipCode) && (localZipCode.count == 6 || localZipCode.count == 7) {
        return false
    }
    
    if previousValidZipCodes.contains(localZipCode) {
        return true
    }
    
    if localZipCode.count == 5 {
        countryCode = "us"
    } else {
        countryCode = "ca"
    }
    
    let path = "https://app.zipcodebase.com/api/v1/search?apikey=\(ZipWiseAPIKey)&codes=\(zipCode.replacingOccurrences(of: " ", with: ""))&country=\(countryCode)"

    guard let _ = URL(string: path) else {
        Utilities.displayAlert("Bad URL", errorMessage: "Zipwise was pasted a bad url.")
        return false
    }
    
    switch URLSession.makeAPICall(url: path) {
    case .failure(_):
        return false
    case .success(let data):
        do {
            let results = try JSONDecoder().decode(ZipCodeBase.self, from: data!)
            if results.results.isEmpty {
                previousInvalidZipCodes.append(localZipCode)
                return false
            } else {
                previousValidZipCodes.append(localZipCode)
                return true
            }
        }
        catch {
            return false
        }
    }
}
