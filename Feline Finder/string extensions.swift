//
//  string extensions.swift
//  FelineFinder
//
//  Created by Gregory Williams on 7/3/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation

extension String {
    
    subscript (i: Int) -> Character {
        let index1 = self.startIndex.advancedBy(i)
        //let index = self.startIndex.advanceBy(i)
        return self[index1]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let index1 = self.startIndex.advancedBy(r.startIndex)
        let index2 = self.startIndex.advancedBy(r.endIndex)
        return substringWithRange(index1...index2)
        //return substringWithRange(Range(start: index1, end: index2))
    }
    
    func URLEncodedString() -> String? {
        let customAllowedSet =  NSCharacterSet.URLQueryAllowedCharacterSet()
        let escapedString = self.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)
        return escapedString
    }
    
    static func queryStringFromParameters(parameters: Dictionary<String,String>) -> String? {
        if (parameters.count == 0)
        {
            return nil
        }
        var queryString : String? = nil
        for (key, value) in parameters {
            if let encodedKey = key.URLEncodedString() {
                if let encodedValue = value.URLEncodedString() {
                    if queryString == nil
                    {
                        queryString = "?"
                    }
                    else
                    {
                        queryString! += "&"
                    }
                    queryString! += encodedKey + "=" + encodedValue
                }
            }
        }
        return queryString
    }
    
    var isNumber : Bool {
            get{
                return !self.isEmpty && self.rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet) == nil
        }
    }
}
