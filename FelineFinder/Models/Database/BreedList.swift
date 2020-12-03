//
//  BreedList.swift
//  TestUIWebView
//
//  Created by Gregory Williams on 6/1/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation

struct breedPicture {
    var Name = ""
    var PictureURL = ""
    var PetID = ""
    
    init (name: String, picURL: String, petID: String) {
        Name = name
        PictureURL = picURL
        PetID = petID
    }
}

struct Breed {
    var BreedID: Int32
    var BreedName = ""
    var BreedHTMLURL = ""
    var PictureHeadShotName = ""
    var PercentMatch: Int32
    var Description: String
    var FullSizedPicture: String
    var RescueBreedID: String
    var YouTubeURL: String
    var cats101VideoURL: String = ""
    var YouTubePlayListID: String = ""
    var YouTubeVideos: [YouTubeVideo] = []
    var Picture: [breedPicture] = []
    var Percentage: Double = 0
    
    init (id: Int32, name: String, url: String, picture: String, percentMatch: Int32, desc: String, fullPict: String, rbID: String, youTubeURL: String, cats101: String, playListID: String) {
        BreedID = id
        BreedName = name
        BreedHTMLURL = url
        PictureHeadShotName = picture
        PercentMatch = percentMatch
        Description = desc
        FullSizedPicture = fullPict
        RescueBreedID = rbID
        YouTubeURL = youTubeURL
        cats101VideoURL = cats101
        YouTubePlayListID = playListID
    }
}

/* Old Code now being done with a database queue
class BreedList {
    var Breeds = [Breed]();

    var databasePath = "";

    func Count() -> Int {
        return Breeds.count
    }
    
    func getBreed(index: Int) -> Breed {
        return Breeds[index];
    }
    
    func getBreeds(results: Bool) {
        let documentsPath : AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0]
        let DBPath:NSString = documentsPath.stringByAppendingString("/CatFinder.db") as String
        
        let contactDB = FMDatabase(path: DBPath as String)
        
        if contactDB.open() {
            Breeds = [];
            
            var querySQL: String = ""
            
            if (results == true) {
                querySQL = "SELECT BreedID, BreedName, BreedHTMLURL, PictureHeadShotName, cast (c as Int) c from BreedMatches order by c desc, BreedName"
            }
            else {
                querySQL = "SELECT BreedID, BreedName, BreedHTMLURL, PictureHeadShotName, -1.0 c from Breed order by BreedSortOrder"
            }
            
            let results: FMResultSet? = contactDB.executeQuery(querySQL,
                withArgumentsInArray: [])
            
            //println("Error: \(contactDB.lastErrorMessage())")
            
            while results?.next() == true {
                let id = results?.intForColumn("BreedID");
                let name = results?.stringForColumn("BreedName");
                let url = results?.stringForColumn("BreedHTMLURL");
                let pict = results?.stringForColumn("PictureHeadShotName");
                let percentMatch = results?.intForColumn("c")
                let breed = Breed(id: id!, name: name!, url: url!, picture: pict!, percentMatch: percentMatch!);
                Breeds.append(breed);
            }
            contactDB.close()
            /*
            for (var i = 0; i < Breeds.count; ++i)
            {
                println(Breeds[i].BreedName)
            }
            */
        } else {
            println("Error: \(contactDB.lastErrorMessage())")
        }
    }
}
*/
