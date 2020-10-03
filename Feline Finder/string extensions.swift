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
        let index1 = self.index(self.startIndex, offsetBy: i)
        //let index = self.startIndex.advanceBy(i)
        return self[index1]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return mid(r.startIndex, amount: r.count - 1)
    }
    
    func URLEncodedString() -> String? {
        let customAllowedSet =  CharacterSet.urlQueryAllowed
        let escapedString = self.addingPercentEncoding(withAllowedCharacters: customAllowedSet)
        return escapedString
    }
    
    static func queryStringFromParameters(_ parameters: Dictionary<String,String>) -> String? {
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
                return !self.isEmpty && self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
        }
    }
    
    // LEFT
    // Returns the specified number of chars from the left of the string
    // let str = "Hello"
    // print(str.left(3))         // Hel
    func left(_ to: Int) -> String {
        return "\(self[..<self.index(startIndex, offsetBy: to)])"
    }

    // RIGHT
    // Returns the specified number of chars from the right of the string
    // let str = "Hello"
    // print(str.left(3))         // llo
    func right(_ from: Int) -> String {
        return "\(self[self.index(startIndex, offsetBy: self.count-from)...])"
    }

    // MID
    // Returns the specified number of chars from the startpoint of the string
    // let str = "Hello"
    // print(str.left(2,amount: 2))         // ll
    func mid(_ from: Int, amount: Int) -> String {
        let x = "\(self[self.index(startIndex, offsetBy: from)...])"
        return x.left(amount)
    }
    
    func chopPrefix(_ count: Int = 1) -> String {
        return self.right(self.count - count)
    }
    
    func chopSuffix(_ count: Int = 1) -> String {
        return self.left(self.count - count)
    }
}
