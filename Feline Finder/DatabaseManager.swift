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
        let documentsPath : AnyObject = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as AnyObject
        let dbPath = documentsPath.appending("/CatFinder.db")
        dbQueue = FMDatabaseQueue(path: dbPath as String)
    

    }
        
    func presentDBErrorMessage(_ errorMessage: String) {
        let message: String = "Error occured on database: \(errorMessage)"
        let dbErrorAlert: UIAlertController = UIAlertController(title: "Database Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        dbErrorAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        AppDelegate().sharedInstance().window?.rootViewController?.present(dbErrorAlert, animated: true, completion: nil)
    }
    
    
    func deg2rad(_ deg:Double) -> Double {
        return deg * M_PI / 180
    }
    
    func rad2deg(_ rad:Double) -> Double {
        return rad * 180.0 / M_PI
    }
    
    func distance(_ lat1:Double, lon1:Double, lat2:Double, lon2:Double, unit:String) -> Double {
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
    
    func fetchDistancesFromZipCode(_ pets: [Pet], completion: @escaping (_ zipCodes: Dictionary<String, zipCoordinates>) -> Void) {
        
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase?) -> Void in
            
            var zips: String = "'" + zipCode + "'"
            var zipC: Dictionary<String, zipCoordinates> = [:]
            var start: zipCoordinates?
            
            for p in pets {
                zips += ",'" + p.zipCode + "'"
            }
            
            let querySQL = "select distinct PostalCode, Latitude, Longitude from ZipCodes where PostalCode in (" + zips + ")"
            
            if let results = db?.executeQuery(querySQL, withArgumentsIn: []) {
                while results.next() == true {
                    let zip = results.string(forColumn: "PostalCode")
                    let lat = results.double(forColumn: "Latitude")
                    let long = results.double(forColumn: "Longitude")
                    let zC = zipCoordinates(z: zip!, latitude: lat, longitude: long, d: 0)
                    if zip == zipCode {
                        start = zC
                    }
                    zipC[zip!] = zC
                }
                results.close()
            } else {
                self.presentDBErrorMessage((db?.lastErrorMessage())!)
            }
            
            for (_, value) in zipC {
                if value.zipCode.isNumber == true {
                zipC[value.zipCode]!.distance = self.distance(start!.lat, lon1: start!.long, lat2: value.lat, lon2: value.long, unit: "M")
                }
            }
            
            completion(zipC)
        }
    }

    func getRescueBreedID(_ completion: @escaping (_ rescueBreeds: Dictionary<String, String>) -> Void) {
        var rb: Dictionary<String, String> = [:]
        var breedName: String = ""
        var breedID: String = ""
        let json = ["apikey":"0doJkmYU","objectType":"animalBreeds","objectAction":"publicSearch", "search": ["resultStart": "0", "resultLimit":"1000", "resultSort": "breedName", "resultOrder": "asc", "filters": [["fieldName": "breedSpecies", "operation": "equals", "criteria": "cat"]], "fields": ["breedID","breedName","breedSpecies","breedSpeciesID"]]] as [String : Any]
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            
            let myURL = URL(string: "https://api.rescuegroups.org/http/v2.json")!
            let request = NSMutableURLRequest(url: myURL)
            request.httpMethod = "POST"
            
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
                data, response, error in
                if error != nil {
                    print("Get Error")
                } else {
                    //var error:NSError?
                    do {
                        let jsonObj:AnyObject =  try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as! NSDictionary
                        
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
                        completion(rb)
                    } catch let error as NSError {
                        // error handling
                        print(error.localizedDescription)
                    }
                }
            }) 
            task.resume() } catch { }
    }
    
    //Breed List
    func fetchBreeds(_ results: Bool, completion: @escaping (_ breeds: Dictionary<String, [Breed]>) -> Void) {
        var rb:Dictionary<String, String> = [:]
        getRescueBreedID{(rescueBreeds) -> Void in
        rb = rescueBreeds
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase?) -> Void in
            
            var querySQL = ""
            
            if (results == true) {
                querySQL = "SELECT case when c = 100 then '      Purrfect Match' when c < 100 and c >= 80 then '     Great Match' when c < 80 and c >= 60 then '    Good Match' when c < 60 and c >= 40 then '   Maybe Match' when c < 40 and c >= 20 then '  Probably Not' else ' Does Not Match' end Letter, BreedID, BreedName, BreedHTMLURL, Description, PictureHeadShotName, FullSizedPicture, cast (c as Int) c, YouTubeURL, Cats101URL from BreedMatches order by c desc, BreedName"
            }
            else {
                querySQL = "SELECT substr(BreedName, 1, 1) Letter, BreedID, BreedName, BreedHTMLURL, Description, PictureHeadShotName, FullSizedPicture, YouTubeURL, Cats101URL, -1.0 c from Breed order by BreedName"
            }
            
            var breeds: Dictionary<String, [Breed]> = [:]
            
            if let results = db?.executeQuery(querySQL, withArgumentsIn: []) {
                
                while results.next() == true {
                    let letter = results.string(forColumn: "Letter")
                    let id = results.int(forColumn: "BreedID")
                    var name = results.string(forColumn: "BreedName")
                    let url = results.string(forColumn: "BreedHTMLURL")
                    let pict = results.string(forColumn: "PictureHeadShotName")
                    let percentMatch = results.int(forColumn: "c")
                    let description = results.string(forColumn: "Description")
                    let fullpict = results.string(forColumn: "FullSizedPicture")
                    let youTubeURL = results.string(forColumn: "YouTubeURL")
                    let cats101URL = results.string(forColumn: "Cats101URL")
                    name = name?.replacingOccurrences(of: "\n", with: "")
                    let breed: Breed?
                    if let rID = rb[name!] {
                        breed = Breed(id: id, name: name!, url: url!, picture: pict!, percentMatch: percentMatch, desc: description!, fullPict: fullpict!, rbID: rID, youTubeURL: youTubeURL!, cats101: cats101URL!)
                    } else {
                        breed = Breed(id: id, name: name!, url: url!, picture: pict!, percentMatch: percentMatch, desc: description!, fullPict: fullpict!, rbID: "", youTubeURL: youTubeURL!, cats101: cats101URL!)
                    }
                    if var title = breeds[letter!] {
                        title.append(breed!)
                        breeds[letter!] = title
                    } else {
                        var title: [Breed] = []
                        title.append(breed!)
                        breeds[letter!] = title
                    }
                }

            results.close()
            } else {
                self.presentDBErrorMessage((db?.lastErrorMessage())!)
            }
            
            let breedsArray = breeds
            completion(breedsArray)
        }
        }
    }
    
    //Breed Stats
    func fetchBreedStatList(_ breedID: Int, percentageMatch: Double, completion: @escaping (_ breedStats: [BreedStats]) -> Void) {
        
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase?) -> Void in
            
            var querySQL = ""
            
            if percentageMatch == -1 {
                querySQL = "SELECT BreedID, TraitShortDesc, c from BreedTraitStats where BreedID = ?"
            } else {
                querySQL = "SELECT BreedID, TraitShortDesc, c, l, h from BreedTraitValuesViewAnswers where BreedID = ?"
            }
            
            var breedStats: [BreedStats] = []
            
            if let results = db?.executeQuery(querySQL, withArgumentsIn: [breedID]) {
            
                while results.next() == true {
                    let i = results.int(forColumn: "BreedID")
                    let d = results.string(forColumn: "TraitShortDesc")
                    let p = results.double(forColumn: "c")
                    var l: Double
                    var h: Double
                    var v: String
                    v = BreedStats.getDescription(d!, p: p)
                    if percentageMatch != -1 {
                        l = results.double(forColumn: "l")
                        h = results.double(forColumn: "h")
                    } else {
                        l = 0
                        h = 0
                    }
                    let breedStat = BreedStats(id: i, desc: d!, percent: p, lowRange: l, highRange: h, value: v);
                    breedStats.append(breedStat);
                }
            
                results.close()
                
            } else {
                self.presentDBErrorMessage((db?.lastErrorMessage())!)
            }
            
            let breedStatsArray = breedStats
            completion(breedStatsArray)
        }
    }
    
    //Questions
    func fetchQuestions(_ completion: @escaping (_ questions: [Question]) -> Void) {
        
        var choices: [Choice] = []
        var questions: [Question] = []
        
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase?) -> Void in
            
            let querySQL = "SELECT ChoicesID, QuestionID, Name, LowRange, HighRange, [Order] from QuestionChoices order by QuestionID, [Order]"
            
            if let results = db?.executeQuery(querySQL, withArgumentsIn: []) {
                while results.next() == true {
                    let choiceid = results.int(forColumn: "ChoicesID")
                    let questionid = results.int(forColumn: "QuestionID")
                    let name = results.string(forColumn: "Name")
                    let lowRange = results.int(forColumn: "LowRange")
                    let highRange = results.int(forColumn: "HighRange")
                    let order = results.int(forColumn: "Order")
                    let choice = Choice(questionid: questionid, choiceid: choiceid, name: name!, lowRange: lowRange, highRange: highRange, order: order);
                    choices.append(choice);
                }
                results.close()
            } else {
                self.presentDBErrorMessage((db?.lastErrorMessage())!)
            }
            
            let querySQL2 = "SELECT QuestionID, Name, Description, [Order], ImageName from Questions order by [Order]"
            
            if let results2 = db?.executeQuery(querySQL2, withArgumentsIn: []) {
                while results2.next() == true {
                    let id = results2.int(forColumn: "QuestionID");
                    let name = results2.string(forColumn: "Name");
                    let description = results2.string(forColumn: "Description");
                    let order = results2.int(forColumn: "Order");
                    let imageName = results2.string(forColumn: "ImageName")
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
                self.presentDBErrorMessage((db?.lastErrorMessage())!)
            }
                
            let questionsArray = questions
            completion(questionsArray)
        }
    }
    
    func writeAnswers(_ questions: [Question]) {
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase?) -> Void in
            if (!(db?.executeStatements("delete from QuestionAnswers"))!) {
                self.presentDBErrorMessage((db?.lastErrorMessage())!)
            }
            for question in questions
            {
                let answer = question.getAnswer()
                if (!(db?.executeUpdate("INSERT INTO QuestionAnswers (QuestionID, QuestionChoiceID) VALUES (?, ?)", withArgumentsIn: [(Int)(question.QuestionID), (Int)(answer.ChoiceID)]))!)
                {
                    self.presentDBErrorMessage((db?.lastErrorMessage())!)
                }
            }
        }
    }
    
    func readAnswers(_ questions: [Question], id: Int) {
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase?) -> Void in
            if (!(db?.executeStatements("delete from QuestionAnswers"))!) {
                self.presentDBErrorMessage((db?.lastErrorMessage())!)
            }
            if (!(db?.executeUpdate("INSERT INTO QuestionAnswers (QuestionID, QuestionChoiceID) select QuestionID, ChoicesID from SavedSearchList where SavedSearchID = ?", withArgumentsIn: [id]))!) {
                self.presentDBErrorMessage((db?.lastErrorMessage())!)
            }
        }
    }
    
    func setAnswer(_ questions: [Question], index: Int, choiceID: Int) -> [Question]{
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
    
    func setAnswers(_ questions: [Question], completion: (_ questions: [Question]) -> Void) {
            var _questions = questions
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase?) -> Void in
            let querySQL = "select QuestionID, QuestionChoiceID from QuestionAnswers"
            var questionID: Int = 0
            var choiceID: Int = 0
            if let results = db?.executeQuery(querySQL, withArgumentsIn: []) {
                while results.next() == true {
                    questionID = Int(results.int(forColumn: "QuestionID"))
                    choiceID = Int(results.int(forColumn: "QuestionChoiceID"))
                    _questions = self.setAnswer(_questions, index: questionID, choiceID: choiceID)
                }
                results.close()
            } else {
                self.presentDBErrorMessage((db?.lastErrorMessage())!)
            }
        }
        completion(_questions)
    }
    
    //Saved Searches
    func fetchAnswers(_ answers: Bool, completion: @escaping (_ keys: [Int32], _ ssds: [SavedSearchDetail]) -> Void) {
        
        var querySQL: String = ""
        
        var ssd = [SavedSearchDetail]()
        var keys = [Int32]()
        
        if (answers == true) {
            querySQL = "SELECT DISTINCT SavedSearchID, SavedSearchDetailID, Question, QuestionID, QuestionOrder, Choice, ChoicesID from AnswersList order by QuestionOrder"
        }
        else {
            querySQL = "SELECT DISTINCT SavedSearchID, SavedSearchDetailID, Question, QuestionID, QuestionOrder, Choice, ChoicesID from SavedSearchList order by QuestionOrder"
        }
        
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase?) -> Void in
            
            if let results = db?.executeQuery(querySQL, withArgumentsIn: []) {
                while results.next() == true {
                    let SavedSearchID = results.int(forColumn: "SavedSearchID")
                    let SavedSearchDetailID = results.int(forColumn: "SavedSearchDetailID")
                    let question = results.string(forColumn: "Question")
                    let questionid = results.int(forColumn: "QuestionID")
                    let questionOrder2 = results.int(forColumn: "QuestionOrder")
                    let choice = results.string(forColumn: "Choice")
                    let choiceID = results.int(forColumn: "ChoicesID")
                    keys.append(SavedSearchID)
                    let ssd2 = SavedSearchDetail(Id: SavedSearchID, DetID: SavedSearchDetailID, q: question!, o: questionOrder2, c: choice!, qID: questionid, cID: choiceID)
                    ssd.append(ssd2)
                }
                results.close()
            } else {
                self.presentDBErrorMessage((db?.lastErrorMessage())!)
            }
            
            let ssdArray = ssd
            let keysArray = keys
            completion(keysArray, ssdArray)
        }
    }
    
    func loadSavedSearches( _ ss: [Int32:SavedSearch], ssd: [SavedSearchDetail], completion: (_ ss: [Int32:SavedSearch]) -> Void) {
        var _ss = ss
        let querySQL = "SELECT SavedSearchID, SearchName, TimeStamp from SavedSearch"
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase?) -> Void in
            if let results = db?.executeQuery(querySQL, withArgumentsIn: []) {
                while results.next() == true {
                    let id2 = results.int(forColumn: "SavedSearchID")
                    let name = results.string(forColumn: "SearchName")
                    let TimeStamp = results.string(forColumn: "TimeStamp")
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
                self.presentDBErrorMessage((db?.lastErrorMessage())!)
            }
        }
        let ssArray = _ss
        completion(ssArray)
    }
    
    func savedSearches(_ answers: Bool, ID: Int, SearchName: String, SDS: [SavedSearchDetail], completion: (_ rowID: Int) -> Void) {
        var _ID = ID
        var rowID: Int = 0
        
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase?) -> Void in
            let querySQL2 = "select count(*) c, SavedSearchID from SavedSearch where SearchName = ?"
            if let results = db?.executeQuery(querySQL2, withArgumentsIn: [SearchName]) {
                while results.next() == true {
                    let c = Int(results.int(forColumn: "c"))
                    if c > 0 {
                        _ID = Int(results.int(forColumn: "SavedSearchID"))
                    } else {
                        _ID = -1
                    }
                }
                results.close()
            } else {
                self.presentDBErrorMessage((db?.lastErrorMessage())!)
            }
            if (!(db?.executeUpdate("DELETE FROM SavedSearchDetail WHERE SavedSearchID = ?", withArgumentsIn: [_ID]))!) {
                self.presentDBErrorMessage((db?.lastErrorMessage())!)
            }
            if (!(db?.executeUpdate("DELETE FROM SavedSearch WHERE SavedSearchID = ?", withArgumentsIn: [_ID]))!) {
                self.presentDBErrorMessage((db?.lastErrorMessage())!)
            }
            if (!(db?.executeUpdate("INSERT INTO SavedSearch (SearchName) VALUES (?)", withArgumentsIn: [SearchName]))!) {
                self.presentDBErrorMessage((db?.lastErrorMessage())!)
            }
            let querySQL = "select max(SavedSearchID) rowID from SavedSearch"
            if let results = db?.executeQuery(querySQL, withArgumentsIn: []) {
                while results.next() == true {
                    rowID = Int(results.int(forColumn: "rowID"))
                }
                results.close()
            } else {
                self.presentDBErrorMessage((db?.lastErrorMessage())!)
            }
            for SD in SDS {
                if (!(db?.executeUpdate("INSERT INTO SavedSearchDetail (SavedSearchID, QuestionID, QuestionChoiceID) VALUES (?,?,?)", withArgumentsIn: [rowID, Int(SD.QuestionID), Int(SD.QuestionChoiceID)]))!) {
                    self.presentDBErrorMessage((db?.lastErrorMessage())!)
                }
            }
        }
        completion(rowID)
    }
    
    func deleteSearch(_ ID: Int) {
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase?) -> Void in
            if (!(db?.executeUpdate("DELETE FROM SavedSearchDetail WHERE SavedSearchID = ?", withArgumentsIn: [ID]))!) {
                self.presentDBErrorMessage((db?.lastErrorMessage())!)
            }
            if (!(db?.executeUpdate("DELETE FROM SavedSearch WHERE SavedSearchID = ?", withArgumentsIn: [ID]))!) {
                self.presentDBErrorMessage((db?.lastErrorMessage())!)
            }
        }
    }
    
    //Favorites
    func addFavorite(_ petID: String, f: Favorite) {
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase?) -> Void in
            if (!(db?.executeUpdate("INSERT INTO Favorites (PetID, PetName, ImageName, Breed, DataSource) VALUES (?, ?, ?, ?, ?)", withArgumentsIn: [f.petID + "_" + f.FavoriteDataSource.rawValue, f.petName, f.imageName, f.breed, f.FavoriteDataSource.rawValue]))!) {
                self.presentDBErrorMessage((db?.lastErrorMessage())!)
            }
        }
    }
    
    func removeFavorite(_ petID: String) {
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase?) -> Void in
            if (!(db?.executeUpdate("DELETE FROM Favorites WHERE PetID = ?", withArgumentsIn: [petID]))!) {
                self.presentDBErrorMessage((db?.lastErrorMessage())!)
            }
        }
    }
    
    func checkPetID(_ petID: String, ds: DataSource) -> String {
        var pID: String = petID
        if pID.range(of: "_") == nil {
            pID = pID + "_" +  ds.rawValue
        }
        return pID
    }
    
    func fetchFavorites(_ keys: [String], favorites: [String:Favorite], completion: @escaping (_ favorites: [String:Favorite], _ keys: [String]) -> Void) {
        
        var _keys = keys
        var _favorites = favorites
        
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase?) -> Void in
            
            let querySQL = "SELECT PetID, PetName, ImageName, Breed, DataSource FROM Favorites"
            
            if let results = db?.executeQuery(querySQL, withArgumentsIn: []) {
            
                while results.next() == true {
                    var PetID = results.string(forColumn: "PetID")
                    let PetName = results.string(forColumn: "PetName")
                    let ImageName = results.string(forColumn: "ImageName")
                    let breed = results.string(forColumn: "Breed")
                    let DS = results.string(forColumn: "DataSource")
                    //let DSEnum: DataSource = (DS == "PetFinder" ? .PetFinder : .RescueGroup)
                    let DSEnum: DataSource = .RescueGroup
                    PetID = self.checkPetID(PetID!, ds: DSEnum)
                    if (!_keys.contains(PetID!)) {
                        _keys.append(PetID!)
                    }
                    _favorites[PetID!] = (Favorite(id: PetID!, n: PetName!, i: ImageName!, b: breed!, d: DSEnum, s: ""))
                }
            
                results.close()
            } else {
                self.presentDBErrorMessage((db?.lastErrorMessage())!)
            }
            
            let favoritesDict = _favorites
            let keysArray = _keys
            completion(favoritesDict, keysArray)
        }
    }
    
    func fetchFilterOptions(_ completion: @escaping (_ filterNames: [(FilterID: Int, FilterName: String)]) -> Void) {
        
        var filterNames: [(FilterID: Int, FilterName: String)] = []
        
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase?) -> Void in
            
            let querySQL = "SELECT FilterNameID, Name FROM PetListFilter"
            
            if let results = db?.executeQuery(querySQL, withArgumentsIn: []) {
                while results.next() == true {
                    let FilterNameID = results.int(forColumn: "FilterNameID")
                    let FilterName = results.string(forColumn: "Name")
                    filterNames.append((FilterID: Int(FilterNameID), FilterName: FilterName!))
                }
                results.close()
            } else {
                self.presentDBErrorMessage((db?.lastErrorMessage())!)
            }
            completion(filterNames)
        }
    }
    
    func fetchFFilterOptions(_ filterID: Int, filterOptions: filterOptionsList, completion: @escaping (_ filterOptions: [filterOption]) -> Void) {
        
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase?) -> Void in
            
            let querySQL = "SELECT FilterName, FilterValue FROM PetListFilterDetails where NameID = ?"
            
            for o in filterOptions.filteringOptions {
                o.choosenValue = o.optionsArray().count - 1
                o.choosenListValues = []
            }
            
            if let results = db?.executeQuery(querySQL, withArgumentsIn: [filterID]) {
                
                while results.next() == true {
                    let FilterName = results.string(forColumn: "FilterName")
                    let FilterValue = results.string(forColumn: "FilterValue")
                    print("\(FilterName)=\(FilterValue)")
                    for o in filterOptions.filteringOptions {
                        if o.fieldName == FilterName {
                            if o.list == true {
                                if FilterValue != "" {
                                    o.choosenListValues = (FilterValue?.components(separatedBy: ",").map{Int($0)!})!
                                    print(o.choosenListValues)
                                } else {
                                    o.choosenListValues = []
                                }
                                break
                            } else {
                                o.choosenValue = Int(FilterValue!)
                                print(o.choosenValue ?? 0)
                                break
                            }
                        }
                    }
                }
                results.close()
                completion(filterOptions.filteringOptions)
            } else {
                self.presentDBErrorMessage((db?.lastErrorMessage())!)
            }
        }
    }
    
    func saveFilterOptions(_ oldNameID: Int, name: String, filterOptions: filterOptionsList) -> Void {
        DatabaseManager.sharedInstance.dbQueue!.inDatabase { (db: FMDatabase?) -> Void in
            if oldNameID != 0 {
                if (!(db?.executeUpdate("DELETE FROM PetListFilterDetails WHERE FilterID = ?", withArgumentsIn: [oldNameID]))!){
                    self.presentDBErrorMessage((db?.lastErrorMessage())!)
                }
                if (!(db?.executeUpdate("DELETE FROM PetListFilter WHERE FilterNameID = ?", withArgumentsIn: [oldNameID]))!) {
                    self.presentDBErrorMessage((db?.lastErrorMessage())!)
                }
            }
            if (!(db?.executeUpdate("INSERT INTO PetListFilter (Name) VALUES (?)", withArgumentsIn: [name]))!) {
                self.presentDBErrorMessage((db?.lastErrorMessage())!)
            }
            if let results = db?.executeQuery("SELECT MAX(FilterNameID) MaxNameID FROM PetListFilter", withArgumentsIn: []) {
                while results.next() == true {
                    NameID = Int(results.int(forColumn: "MaxNameID"))
                }
                results.close()
            }
            for o in filterOptions.filteringOptions {
                var FilterValue: String = ""
                if o.classification == .saves {o.choosenListValues.append(NameID)}
                if o.list == true {
                    FilterValue = o.choosenListValues.map{String($0)}.joined(separator: ",")
                } else {
                    FilterValue = String(o.choosenValue!)
                }
                if (!(db?.executeUpdate("INSERT INTO PetListFilterDetails(NameID, FilterName, FilterValue) Values(?,?,?)", withArgumentsIn: [NameID, o.fieldName!, FilterValue]))!) {
                    self.presentDBErrorMessage((db?.lastErrorMessage())!)
                }
            }
        }
    }
}
