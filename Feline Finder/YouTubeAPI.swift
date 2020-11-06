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

enum NetworkError: Error {
    case url
    case server
}

struct defaults: Decodable {
    var url: String?
}

struct thumbNail: Decodable {
    var `default`: defaults?
}

struct resourceId: Decodable {
    var videoId: String?
}

struct snippet: Decodable {
    var thumbnails: thumbNail?
    var resourceId: resourceId?
}

struct status: Decodable {
    var privacyStatus: String?
}

struct item: Decodable {
    var status: status?
    var snippet: snippet?
}

struct youtubeapi: Decodable {
    var items: [item]?
}

let youTubeAPIKey = "AIzaSyAncgYuV4FLT8ScN8K2Tp5oZQBHXVdFTgw"

class YouTubeAPI {
    
    var status = ""
    var task: URLSessionTask?
    
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
        let t = NSURL(string: "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet,status&maxResults=49&playlistId=\(playList)&key=\(youTubeAPIKey)")
 //let t = NSURL(string: "https://www.googleapis.com/youtube/v3/playlistItems?maxResults=49&playlistId=\(playList)&key=\(youTubeAPIKey)")
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
                            
                            print("privacyStatus ===> ", ((item["status"] as! Dictionary<String, AnyObject>)["privacyStatus"] as! String))
                            
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
    
    static func makeAPICall(url: String) -> Result<Data?, NetworkError> {
        guard let url = URL(string: url) else {
            return .failure(.url)
        }
        var result: Result<Data?, NetworkError>!
        
        let semaphore = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let data = data {
                result = .success(data)
            } else {
                result = .failure(.server)
            }
            semaphore.signal()
        }.resume()
        _ = semaphore.wait(wallTimeout: .distantFuture)
        return result
    }
    
    static func getYouTubeVideos2(playList: String) -> Result<[YouTubeVideo]?, NetworkError> {
        let path =  "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet,status&maxResults=49&playlistId=\(playList)&key=\(youTubeAPIKey)"

        guard let _ = URL(string: path) else {
            return .failure(.url)
        }
        
        switch makeAPICall(url: path) {
        case .failure(let err):
            return .failure(err)
        case .success(let data):
            var videos: [YouTubeVideo] = []
            
            do {
                let youTubeVideos = try JSONDecoder().decode(youtubeapi.self, from: data!)
                for item in youTubeVideos.items ?? [] {
                    if let snippet = item.snippet, let thumbnails = snippet.thumbnails, let d = thumbnails.default, let u = d.url, let r = snippet.resourceId, let vid = r.videoId {
                    videos.append(YouTubeVideo(url: u, id: vid))
                    }
                }
            } catch _ {
            }
            
            return .success(videos)
        }
    }
}

