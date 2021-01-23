//
//  FitValues.swift
//  FelineFinder
//
//  Created by Gregory Williams on 1/13/21.
//

import Foundation

class FitValueList {
    var iCloudKeyStore: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default
    var loaded: Bool = false
    var values: [Int] = []
            
    var count: Int {
        return values.count
    }
    
    subscript(position: Int) -> Int {
        get {
            guard position >= 0 && position < values.count else {fatalError("Subscript for FitValues out of bounds")}
            return values[position]
        }
        set {
            guard position >= 0 && position < values.count else {fatalError("Subscript for FitValues out of bounds")}
            values[position] = newValue
        }
    }
    
    func removeValue(_ position: Int) {
        guard position >= 0 && position < values.count else {fatalError("Subscript for FitValues out of bounds")}
        values.remove(at: position)
    }
        
    func loadValues() {
        let keyStore = NSUbiquitousKeyValueStore()
        values = keyStore.array(forKey: "fitValues") as? [Int] ?? [Int](repeating: 0, count: 15)
    }
    
    func clear() {
        values = [Int](repeating: 0, count: 15)
        storeIDs()
    }
    
    func storeIDs() {
        let keyStore = NSUbiquitousKeyValueStore()
        keyStore.set(values, forKey: "fitValues")
        keyStore.synchronize()
    }
}
