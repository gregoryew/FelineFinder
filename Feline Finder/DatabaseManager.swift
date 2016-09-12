//
//  DatabaseManager.swift
//  FelineFinder
//
//  Created by Gregory Williams on 8/23/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation

struct zipCoordinates {
    let zipCode: String
    let lat: Double
    let long: Double
    var distance: Double
    init (z: String, latitude: Double, longitude: Double, d: Double) {
        zipCode = z
        lat = latitude
        long = longitude
        distance = d
    }
}

class DatabaseManager {
    static let sharedInstance = DatabaseManager()
    var dbQueue: FMDatabaseQueue?
    
    init() {
        //let filemanager = NSFileManager.defaultManager()
        let documentsPath : AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0]
        let dbPath: NSString = documentsPath.stringByAppendingString("/CatFinder.db")
        dbQueue = FMDatabaseQueue(path: dbPath as String)
    

    }
        
    func presentDBErrorMessage(errorMessage: String) {
        let message: String = "Error occured on database: \(errorMessage)"
        let dbErrorAlert: UIAlertController = UIAlertController(title: "Database Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        dbErrorAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        AppDelegate().sharedInstance().window?.rootViewController?.presentViewController(dbErrorAlert, animated: true, completion: nil)
    }
    
    
    func deg2rad(deg:Double) -> Double {
        return deg * M_PI / 180
    }
    
    func rad2deg(rad:Double) -> Double {
        return rad * 180.0 / M_PI
    }
    
    func distance(lat1:Double, lon1:Double, lat2:Double, lon2:Double, unit:String) -> Double {
        let theta = lon1 - lon2
        var dist = sin(deg2rad(lat1)) * sin(deg2rad(lat2)) + cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * cos(deg2rad(theta))
        dist = acos(dist)
        dist = rad2deg(dist)
        dist = dist * 60 * 1.1515
        if (unit == "K") {
            dist = dist * 1.609344
        }
        else if (unit == "N") {
            dist = dist * 0.8684
        }
        return dist
    }
    
    func fetchDistancesFromZipCode(pets: [Pet], completion: (zipCodes: Dictionary<String, zipCoordinates>) -> Void) {
        
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase!) -> Void in
            
            var zips: String = "'" + zipCode + "'"
            var zipC: Dictionary<String, zipCoordinates> = [:]
            var start: zipCoordinates?
            
            for p in pets {
                zips += ",'" + p.zipCode + "'"
            }
            
            let querySQL = "select distinct PostalCode, Latitude, Longitude from ZipCodes where PostalCode in (" + zips + ")"
            
            if let results = db.executeQuery(querySQL, withArgumentsInArray: []) {
                while results.next() == true {
                    let zip = results.stringForColumn("PostalCode")
                    let lat = results.doubleForColumn("Latitude")
                    let long = results.doubleForColumn("Longitude")
                    let zC = zipCoordinates(z: zip, latitude: lat, longitude: long, d: 0)
                    if zip == zipCode {
                        start = zC
                    }
                    zipC[zip] = zC
                }
                results.close()
            } else {
                self.presentDBErrorMessage(db.lastErrorMessage())
            }
            
            for (_, value) in zipC {
                if value.zipCode.isNumber == true {
                zipC[value.zipCode]!.distance = self.distance(start!.lat, lon1: start!.long, lat2: value.lat, lon2: value.long, unit: "M")
                }
            }
            
            completion(zipCodes: zipC)
        }
    }

    func getRescueBreedID(completion: (rescueBreeds: Dictionary<String, String>) -> Void) {
        var rb: Dictionary<String, String> = [:]
        var breedName: String = ""
        var breedID: String = ""
        let json = ["apikey":"0doJkmYU","objectType":"animalBreeds","objectAction":"publicSearch", "search": ["resultStart": "0", "resultLimit":"1000", "resultSort": "breedName", "resultOrder": "asc", "filters": [["fieldName": "breedSpecies", "operation": "equals", "criteria": "cat"]], "fields": ["breedID","breedName","breedSpecies","breedSpeciesID"]]]
        do {
            
            let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
            
            let myURL = NSURL(string: "https://api.rescuegroups.org/http/v2.json")!
            let request = NSMutableURLRequest(URL: myURL)
            request.HTTPMethod = "POST"
            
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            request.HTTPBody = jsonData
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                data, response, error in
                if error != nil {
                    print("Get Error")
                } else {
                    //var error:NSError?
                    do {
                        let jsonObj:AnyObject =  try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as! NSDictionary
                        
                        if let dict = jsonObj as? [String: AnyObject] {
                            for (key, data) in dict {
                                if key == "data" {
                                    if let d = data as? [String: AnyObject] {
                                        for (_, data2) in d {
                                            if data2 is [String: String] {
                                                for (key2, data3) in (data2 as? [String: String])! {
                                                    if key2 == "breedID" {breedID = data3}
                                                    if key2 == "breedName" {breedName = data3}
                                                }
                                                rb[breedName] = breedID
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        completion(rescueBreeds: rb)
                    } catch let error as NSError {
                        // error handling
                        print(error.localizedDescription)
                    }
                }
            }
            task.resume() } catch { }
    }
    
    //Breed List
    func fetchBreeds(results: Bool, completion: (breeds: Dictionary<String, [Breed]>) -> Void) {
        var rb:Dictionary<String, String> = [:]
        getRescueBreedID{(rescueBreeds) -> Void in
        rb = rescueBreeds
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase!) -> Void in
            
            var querySQL = ""
            
            if (results == true) {
                querySQL = "SELECT case when c = 100 then '      Purrfect Match' when c < 100 and c >= 80 then '     Great Match' when c < 80 and c >= 60 then '    Good Match' when c < 60 and c >= 40 then '   Maybe Match' when c < 40 and c >= 20 then '  Probably Not' else ' Does Not Match' end Letter, BreedID, BreedName, BreedHTMLURL, Description, PictureHeadShotName, FullSizedPicture, cast (c as Int) c from BreedMatches order by c desc, BreedName"
            }
            else {
                querySQL = "SELECT substr(BreedName, 1, 1) Letter, BreedID, BreedName, BreedHTMLURL, Description, PictureHeadShotName, FullSizedPicture, -1.0 c from Breed order by BreedName"
            }
            
            var breeds: Dictionary<String, [Breed]> = [:]
            
            if let results = db.executeQuery(querySQL, withArgumentsInArray: []) {
                
                while results.next() == true {
                    let letter = results.stringForColumn("Letter")
                    let id = results.intForColumn("BreedID")
                    var name = results.stringForColumn("BreedName")
                    let url = results.stringForColumn("BreedHTMLURL")
                    let pict = results.stringForColumn("PictureHeadShotName")
                    let percentMatch = results.intForColumn("c")
                    let description = results.stringForColumn("Description")
                    let fullpict = results.stringForColumn("FullSizedPicture")
                    name = name.stringByReplacingOccurrencesOfString("\n", withString: "")
                    let breed: Breed?
                    if let rID = rb[name] {
                        breed = Breed(id: id, name: name!, url: url!, picture: pict!, percentMatch: percentMatch, desc: description, fullPict: fullpict, rbID: rID)
                    } else {
                        breed = Breed(id: id, name: name!, url: url!, picture: pict!, percentMatch: percentMatch, desc: description, fullPict: fullpict, rbID: "")
                    }
                    if var title = breeds[letter] {
                        title.append(breed!)
                        breeds[letter] = title
                    } else {
                        var title: [Breed] = []
                        title.append(breed!)
                        breeds[letter] = title
                    }
                }

            results.close()
            } else {
                self.presentDBErrorMessage(db.lastErrorMessage())
            }
            
            let breedsArray = breeds
            completion(breeds: breedsArray)
        }
        }
    }
    
    //Breed Stats
    func fetchBreedStatList(breedID: Int, percentageMatch: Double, completion: (breedStats: [BreedStats]) -> Void) {
        
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase!) -> Void in
            
            var querySQL = ""
            
            if percentageMatch == -1 {
                querySQL = "SELECT BreedID, TraitShortDesc, c from BreedTraitStats where BreedID = ?"
            } else {
                querySQL = "SELECT BreedID, TraitShortDesc, c, l, h from BreedTraitValuesViewAnswers where BreedID = ?"
            }
            
            var breedStats: [BreedStats] = []
            
            if let results = db.executeQuery(querySQL, withArgumentsInArray: [breedID]) {
            
                while results.next() == true {
                    let i = results.intForColumn("BreedID")
                    let d = results.stringForColumn("TraitShortDesc")
                    let p = results.doubleForColumn("c")
                    var l: Double
                    var h: Double
                    var v: String
                    v = BreedStats.getDescription(d!, p: p)
                    if percentageMatch != -1 {
                        l = results.doubleForColumn("l")
                        h = results.doubleForColumn("h")
                    } else {
                        l = 0
                        h = 0
                    }
                    let breedStat = BreedStats(id: i, desc: d!, percent: p, lowRange: l, highRange: h, value: v);
                    breedStats.append(breedStat);
                }
            
                results.close()
                
            } else {
                self.presentDBErrorMessage(db.lastErrorMessage())
            }
            
            let breedStatsArray = breedStats
            completion(breedStats: breedStatsArray)
        }
    }
    
    //Questions
    func fetchQuestions(completion: (questions: [Question]) -> Void) {
        
        var choices: [Choice] = []
        var questions: [Question] = []
        
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase!) -> Void in
            
            let querySQL = "SELECT ChoicesID, QuestionID, Name, LowRange, HighRange, [Order] from QuestionChoices order by QuestionID, [Order]"
            
            if let results = db.executeQuery(querySQL, withArgumentsInArray: []) {
                while results.next() == true {
                    let choiceid = results.intForColumn("ChoicesID")
                    let questionid = results.intForColumn("QuestionID")
                    let name = results.stringForColumn("Name")
                    let lowRange = results.intForColumn("LowRange")
                    let highRange = results.intForColumn("HighRange")
                    let order = results.intForColumn("Order")
                    let choice = Choice(questionid: questionid, choiceid: choiceid, name: name!, lowRange: lowRange, highRange: highRange, order: order);
                    choices.append(choice);
                }
                results.close()
            } else {
                self.presentDBErrorMessage(db.lastErrorMessage())
            }
            
            let querySQL2 = "SELECT QuestionID, Name, Description, [Order], ImageName from Questions order by [Order]"
            
            if let results2 = db.executeQuery(querySQL2, withArgumentsInArray: []) {
                while results2.next() == true {
                    let id = results2.intForColumn("QuestionID");
                    let name = results2.stringForColumn("Name");
                    let description = results2.stringForColumn("Description");
                    let order = results2.intForColumn("Order");
                    let imageName = results2.stringForColumn("ImageName")
                    var currentQuestionChoices = [Choice]()
                
                    for choice in choices {
                        if (choice.QuestionID == id) {
                            currentQuestionChoices.append(choice)
                        }
                    }
                
                    let question = Question(id: id, name: name!, description: description!, order: order, choices: currentQuestionChoices, image: imageName!);
                    questions.append(question);
                }
                results2.close()
            } else {
                self.presentDBErrorMessage(db.lastErrorMessage())
            }
                
            let questionsArray = questions
            completion(questions: questionsArray)
        }
    }
    
    func writeAnswers(questions: [Question]) {
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase!) -> Void in
            if (!db.executeStatements("delete from QuestionAnswers")) {
                self.presentDBErrorMessage(db.lastErrorMessage())
            }
            for question in questions
            {
                let answer = question.getAnswer()
                if (!db.executeUpdate("INSERT INTO QuestionAnswers (QuestionID, QuestionChoiceID) VALUES (?, ?)", withArgumentsInArray: [(Int)(question.QuestionID), (Int)(answer.ChoiceID)]))
                {
                    self.presentDBErrorMessage(db.lastErrorMessage())
                }
            }
        }
    }
    
    func readAnswers(questions: [Question], id: Int) {
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase!) -> Void in
            if (!db.executeStatements("delete from QuestionAnswers")) {
                self.presentDBErrorMessage(db.lastErrorMessage())
            }
            if (!db.executeUpdate("INSERT INTO QuestionAnswers (QuestionID, QuestionChoiceID) select QuestionID, ChoicesID from SavedSearchList where SavedSearchID = ?", withArgumentsInArray: [id])) {
                self.presentDBErrorMessage(db.lastErrorMessage())
            }
        }
    }
    
    func setAnswer(questions: [Question], index: Int, choiceID: Int) -> [Question]{
        var q: Int = 0
        var _questions = questions
        var i = 0
        
        while i < _questions.count {
            if (Int(_questions[i].QuestionID) == index) {
                q = i
                break;
            }
            i += 1
        }

        var question: Question = _questions[q]
        question.setAnswer(choiceID)
        _questions[q] = question
        return _questions
    }
    
    func setAnswers(questions: [Question], completion: (questions: [Question]) -> Void) {
            var _questions = questions
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase!) -> Void in
            let querySQL = "select QuestionID, QuestionChoiceID from QuestionAnswers"
            var questionID: Int = 0
            var choiceID: Int = 0
            if let results = db.executeQuery(querySQL, withArgumentsInArray: []) {
                while results.next() == true {
                    questionID = Int(results.intForColumn("QuestionID"))
                    choiceID = Int(results.intForColumn("QuestionChoiceID"))
                    _questions = self.setAnswer(_questions, index: questionID, choiceID: choiceID)
                }
                results.close()
            } else {
                self.presentDBErrorMessage(db.lastErrorMessage())
            }
        }
        completion(questions: _questions)
    }
    
    //Saved Searches
    func fetchAnswers(answers: Bool, completion: (keys: [Int32], ssds: [SavedSearchDetail]) -> Void) {
        
        var querySQL: String = ""
        
        var ssd = [SavedSearchDetail]()
        var keys = [Int32]()
        
        if (answers == true) {
            querySQL = "SELECT DISTINCT SavedSearchID, SavedSearchDetailID, Question, QuestionID, QuestionOrder, Choice, ChoicesID from AnswersList order by QuestionOrder"
        }
        else {
            querySQL = "SELECT DISTINCT SavedSearchID, SavedSearchDetailID, Question, QuestionID, QuestionOrder, Choice, ChoicesID from SavedSearchList order by QuestionOrder"
        }
        
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase!) -> Void in
            
            if let results = db.executeQuery(querySQL, withArgumentsInArray: []) {
                while results.next() == true {
                    let SavedSearchID = results.intForColumn("SavedSearchID")
                    let SavedSearchDetailID = results.intForColumn("SavedSearchDetailID")
                    let question = results.stringForColumn("Question")
                    let questionid = results.intForColumn("QuestionID")
                    let questionOrder2 = results.intForColumn("QuestionOrder")
                    let choice = results.stringForColumn("Choice")
                    let choiceID = results.intForColumn("ChoicesID")
                    keys.append(SavedSearchID)
                    let ssd2 = SavedSearchDetail(Id: SavedSearchID, DetID: SavedSearchDetailID, q: question!, o: questionOrder2, c: choice!, qID: questionid, cID: choiceID)
                    ssd.append(ssd2)
                }
                results.close()
            } else {
                self.presentDBErrorMessage(db.lastErrorMessage())
            }
            
            let ssdArray = ssd
            let keysArray = keys
            completion(keys: keysArray, ssds: ssdArray)
        }
    }
    
    func loadSavedSearches( ss: [Int32:SavedSearch], ssd: [SavedSearchDetail], completion: (ss: [Int32:SavedSearch]) -> Void) {
        var _ss = ss
        let querySQL = "SELECT SavedSearchID, SearchName, TimeStamp from SavedSearch"
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase!) -> Void in
            if let results = db.executeQuery(querySQL, withArgumentsInArray: []) {
                while results.next() == true {
                    let id2 = results.intForColumn("SavedSearchID")
                    let name = results.stringForColumn("SearchName")
                    let TimeStamp = results.stringForColumn("TimeStamp")
                    var details = [SavedSearchDetail]()
                
                    for ssd3 in ssd {
                        if (ssd3.SavedSearchID == id2) {
                            details.append(ssd3)
                        }
                    }
                
                    let ss3 = SavedSearch(id: id2, t: name!, ts: TimeStamp!, det: details)
                    _ss[id2] = ss3
                }
                results.close()
            } else {
                self.presentDBErrorMessage(db.lastErrorMessage())
            }
        }
        let ssArray = _ss
        completion(ss: ssArray)
    }
    
    func savedSearches(answers: Bool, ID: Int, SearchName: String, SDS: [SavedSearchDetail], completion: (rowID: Int) -> Void) {
        var _ID = ID
        var rowID: Int = 0
        
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase!) -> Void in
            let querySQL2 = "select count(*) c, SavedSearchID from SavedSearch where SearchName = ?"
            if let results = db.executeQuery(querySQL2, withArgumentsInArray: [SearchName]) {
                while results.next() == true {
                    let c = Int(results.intForColumn("c"))
                    if c > 0 {
                        _ID = Int(results.intForColumn("SavedSearchID"))
                    } else {
                        _ID = -1
                    }
                }
                results.close()
            } else {
                self.presentDBErrorMessage(db.lastErrorMessage())
            }
            if (!db.executeUpdate("DELETE FROM SavedSearchDetail WHERE SavedSearchID = ?", withArgumentsInArray: [_ID])) {
                self.presentDBErrorMessage(db.lastErrorMessage())
            }
            if (!db.executeUpdate("DELETE FROM SavedSearch WHERE SavedSearchID = ?", withArgumentsInArray: [_ID])) {
                self.presentDBErrorMessage(db.lastErrorMessage())
            }
            if (!db.executeUpdate("INSERT INTO SavedSearch (SearchName) VALUES (?)", withArgumentsInArray: [SearchName])) {
                self.presentDBErrorMessage(db.lastErrorMessage())
            }
            let querySQL = "select max(SavedSearchID) rowID from SavedSearch"
            if let results = db.executeQuery(querySQL, withArgumentsInArray: []) {
                while results.next() == true {
                    rowID = Int(results.intForColumn("rowID"))
                }
                results.close()
            } else {
                self.presentDBErrorMessage(db.lastErrorMessage())
            }
            for SD in SDS {
                if (!db.executeUpdate("INSERT INTO SavedSearchDetail (SavedSearchID, QuestionID, QuestionChoiceID) VALUES (?,?,?)", withArgumentsInArray: [rowID, Int(SD.QuestionID), Int(SD.QuestionChoiceID)])) {
                    self.presentDBErrorMessage(db.lastErrorMessage())
                }
            }
        }
        completion(rowID: rowID)
    }
    
    func deleteSearch(ID: Int) {
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase!) -> Void in
            if (!db.executeUpdate("DELETE FROM SavedSearchDetail WHERE SavedSearchID = ?", withArgumentsInArray: [ID])) {
                self.presentDBErrorMessage(db.lastErrorMessage())
            }
            if (!db.executeUpdate("DELETE FROM SavedSearch WHERE SavedSearchID = ?", withArgumentsInArray: [ID])) {
                self.presentDBErrorMessage(db.lastErrorMessage())
            }
        }
    }
    
    //Favorites
    func addFavorite(petID: String, f: Favorite) {
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase!) -> Void in
            if (!db.executeUpdate("INSERT INTO Favorites (PetID, PetName, ImageName, Breed, DataSource) VALUES (?, ?, ?, ?, ?)", withArgumentsInArray: [f.petID + "_" + f.FavoriteDataSource.rawValue, f.petName, f.imageName, f.breed, f.FavoriteDataSource.rawValue])) {
                self.presentDBErrorMessage(db.lastErrorMessage())
            }
        }
    }
    
    func removeFavorite(petID: String) {
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase!) -> Void in
            if (!db.executeUpdate("DELETE FROM Favorites WHERE PetID = ?", withArgumentsInArray: [petID])) {
                self.presentDBErrorMessage(db.lastErrorMessage())
            }
        }
    }
    
    func checkPetID(petID: String, ds: DataSource) -> String {
        var pID: String = petID
        if pID.rangeOfString("_") == nil {
            pID = pID + "_" +  ds.rawValue
        }
        return pID
    }
    
    func fetchFavorites(keys: [String], favorites: [String:Favorite], completion: (favorites: [String:Favorite], keys: [String]) -> Void) {
        
        var _keys = keys
        var _favorites = favorites
        
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase!) -> Void in
            
            let querySQL = "SELECT PetID, PetName, ImageName, Breed, DataSource FROM Favorites"
            
            if let results = db.executeQuery(querySQL, withArgumentsInArray: []) {
            
                while results.next() == true {
                    var PetID = results.stringForColumn("PetID")
                    let PetName = results.stringForColumn("PetName")
                    let ImageName = results.stringForColumn("ImageName")
                    let breed = results.stringForColumn("Breed")
                    let DS = results.stringForColumn("DataSource")
                    let DSEnum: DataSource = (DS == "PetFinder" ? .PetFinder : .RescueGroup)
                    PetID = self.checkPetID(PetID, ds: DSEnum)
                    if (!_keys.contains(PetID)) {
                        _keys.append(PetID)
                    }
                    _favorites[PetID] = (Favorite(id: PetID, n: PetName!, i: ImageName!, b: breed!, d: DSEnum, s: ""))
                }
            
                results.close()
            } else {
                self.presentDBErrorMessage(db.lastErrorMessage())
            }
            
            let favoritesDict = _favorites
            let keysArray = _keys
            completion(favorites: favoritesDict, keys: keysArray)
        }
    }
}