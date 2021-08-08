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
    var title = ""
    init (url: String, id: String, title: String) {
        self.pictureURL = url
        self.videoID = id
        self.title = title
    }
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
    var title: String?
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

enum NetworkErr: Error {
    case url
    case server
}

class YouTubeAPI {
            
    static func getYouTubeVideos(playList: String) -> Result<[YouTubeVideo]?, NetworkErr> {
        let path =  "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet,status&maxResults=49&playlistId=\(playList)&key=\(YouTubeAPIKey)"

        guard let _ = URL(string: path) else {
            return .failure(.url)
        }
        
        switch URLSession.makeAPICall(url: path) {
        case .failure(let err):
            return .failure(err)
        case .success(let data):
            var videos: [YouTubeVideo] = []
            
            do {
                let youTubeVideos = try JSONDecoder().decode(youtubeapi.self, from: data!)
                for item in youTubeVideos.items ?? [] {
                    if let snippet = item.snippet, let thumbnails = snippet.thumbnails, let d = thumbnails.default, let u = d.url, let r = snippet.resourceId, let vid = r.videoId, let title = snippet.title {
                        videos.append(YouTubeVideo(url: u, id: vid, title: title))
                    }
                }
            } catch _ {
            }
            
            return .success(videos)
        }
    }
}

