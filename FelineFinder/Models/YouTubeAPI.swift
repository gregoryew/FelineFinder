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
    
    static func getYouTubeVideos(playList: String) -> Result<[YouTubeVideo]?, NetworkError> {
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

