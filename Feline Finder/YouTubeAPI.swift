//
//  YouTubeVideoList.swift
//
//  Created by gregoryew1 on 8/9/17.
//  Copyright © 2017 gregoryew1. All rights reserved.
//

import UIKit

struct YouTubeVideo {
    var pictureURL = ""
    var videoID = ""
    init (url: String, id: String) {
        pictureURL = url
        videoID = id
    }
}

class YouTubeAPI {
    
    var status = ""
    var task: URLSessionTask?
    let youTubeAPIKey = "AIzaSyAncgYuV4FLT8ScN8K2Tp5oZQBHXVdFTgw"
    
    func performGetRequest(targetURL: NSURL!, completion: @escaping (_ data: Data?, _ HTTPStatusCode: Int, _ error: Error?) -> Void) {
        let request = NSMutableURLRequest(url: targetURL as URL)
        request.httpMethod = "GET"
        
        let sessionConfiguration = URLSessionConfiguration.default
        
        let session = URLSession(configuration: sessionConfiguration)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data: Data!, response: URLResponse!, error: Error!) -> Void in
            completion(data as Data?, (response as! HTTPURLResponse).statusCode, nil)
        })
        
        task.resume()
    }
    
    func getYouTubeVideos(playList: String, completion: @escaping ([YouTubeVideo], _ error: Error?) -> Void) {
        //PLrrwGtN2q9fDIt62ltVoOU4GmUOB4TlWo
        let t = NSURL(string: "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=49&playlistId=\(playList)&key=\(youTubeAPIKey)")
        var videos: [YouTubeVideo] = []
        var u = ""
        var id = ""
        performGetRequest(targetURL: t, completion: ({ (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                do {
                    if let data = data,
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let items = json["items"] as? [[String: Any]] {
                        for item in items {
                            
                            u = (((item["snippet"] as! Dictionary<String, AnyObject>)["thumbnails"] as! Dictionary<String, AnyObject>)["default"] as! Dictionary<String, AnyObject>)["url"] as! String
                            
                            id = ((item["snippet"] as! Dictionary<String, AnyObject>)["resourceId"] as! Dictionary<String, AnyObject>)["videoId"] as! String
                            
                            videos.append(YouTubeVideo(url: u, id: id))
                        }
                    }
                }
                catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
                completion(videos, error)
            }
        }))
    }
}

