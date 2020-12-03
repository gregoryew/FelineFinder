//
//  SavedSearches.swift
//  FelineFinder
//
//  Created by Gregory Williams on 7/12/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation

struct SavedSearchDetail {
    var SavedSearchDetailID: Int32
    var SavedSearchID: Int32
    var Question: String
    var QuestionOrder: Int32
    var QuestionID: Int32
    var Choice: String
    var QuestionChoiceID: Int32
    init (Id: Int32, DetID: Int32, q: String, o: Int32, c: String, qID: Int32, cID: Int32) {
        SavedSearchID = Id
        SavedSearchDetailID = DetID
        Question = q
        QuestionOrder = o
        Choice = c
        QuestionID = qID
        QuestionChoiceID = cID
    }
}

struct SavedSearch {
    var SavedSearchID: Int32
    var Title: String
    var TimeStamp: String
    var SavedSearchDetails: [SavedSearchDetail]
    init (id: Int32, t: String, ts: String, det: [SavedSearchDetail]) {
        SavedSearchID = id
        Title = t
        TimeStamp = ts
        SavedSearchDetails = det
    }
}

var SavedSearches = SavedSeachesList()

class SavedSeachesList {
    var ss = [Int32:SavedSearch]()
    var ssd = [SavedSearchDetail]()
    var keys = [Int32]()
    var loaded: Bool = false
    
    var count: Int { return ss.count }
    
    subscript (index: Int) -> SavedSearch {
        get {
            if (index >= 0 && index < keys.count) || (keys.count != 0)   {
                return ss[keys[index]]!
            }
            else {
                return SavedSearch(id: 0, t: "", ts: "", det: [])
            }
        }
        set(newValue) {
            ss[keys[index]] = newValue
        }
    }
    
    func saveSearches(_ answers: Bool, ID: Int, SearchName: String) -> Int {
        var rID: Int = 0
        DatabaseManager.sharedInstance.savedSearches(answers, ID: ID, SearchName: SearchName, SDS: self[ID].SavedSearchDetails) { (rowID) -> Void in
            rID = rowID
        }
        return rID
    }
    
    func refresh() {
        ss = [Int32:SavedSearch]()
        ssd = [SavedSearchDetail]()
        keys = [Int32]()
        loaded = false
    }
    
    func loadSearches(_ answers: Bool) {
        loaded = false
        
        //var sn: String?
        
        DatabaseManager.sharedInstance.fetchAnswers(answers) { (keys, ssd) -> Void in
            self.keys = keys
            self.ssd = ssd
        }
        
        if (answers) {
            var details = [SavedSearchDetail]()
            for ssd3 in ssd {
                details.append(ssd3)
            }
            let ss3 = SavedSearch(id: 1, t: "Summary", ts: "", det: details)
            ss[1] = ss3
        }
        else {
            DatabaseManager.sharedInstance.loadSavedSearches(ss, ssd: ssd) {(ss) -> Void in
                self.ss = ss
            }
        }
        loaded = true
    }
}
